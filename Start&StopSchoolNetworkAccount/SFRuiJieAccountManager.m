//
//  SFRuiJieAccountManager.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/1/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFRuiJieAccountManager.h"
#import "SFViewController.h"

@interface SFRuiJieAccountManager()

@property (strong, nonatomic) NSString *userAccountState;
/**存放用户校园网账号 */
@property (strong, nonatomic) NSString *userAccountIDForSchoolNetwork;
/**存放用户校园网密码*/
@property (strong, nonatomic) NSString *userAccountPasswordForSchoolNetwork;
/**存放ViewController中返回的由用户输入的验证码*/
@property (strong, nonatomic) NSString *verificationCode;
/**
 *  标识是resume还是suspend操作，所有网络操作函数依赖于此（除了loadVerificationCodeImage）
 */
//@property (strong, nonatomic) NSString *resumeOrSuspend;

//以下3个是用于登录后的验证信息获取（最后那个应该是没必要的，不过谨慎起见保留）
@property (strong, nonatomic) NSString *operationVerifyCode;
@property (strong, nonatomic) NSString *comSunFacesVIEW;
@property (strong, nonatomic) NSString *submitCodeId;

@end

@implementation SFRuiJieAccountManager

+ (instancetype)sharedManager
{
    static SFRuiJieAccountManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    return sharedManager;
}


/**
 *  用于获取验证码图片，通过与ViewController的delegate展示图片给用户
 */
- (void)loadVerificationCodeImage
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/common/web/verifycode.jsp"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//7s后获取验证码的连接超时
//TODO: 第一次7s，之后如果再次尝试的话，要延长超时时限
    defaultConfigObject.timeoutIntervalForRequest = kTimeIntervalForVerificationCodeImage;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];

    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            UIImage *verificationCodeImage = [[UIImage alloc]initWithData:data];
            NSLog(@"Load Verification Code Image Successfully!");
            [_ruijieDelegate showVerificationCodeImage:verificationCodeImage];
        }
        else
        {
            NSLog(@"Error: %@", error);
            [self showAlertViewForNetworkError:error changeForTitle:nil changeForMessage:nil];
        }
    }];
    
    [dataTask resume];
}


/**
 *  用于使头文件与本文件中方法名称不同，并且设置ruijieOperationWillBeDoneAfterLogin状态
 *
 *  @param ruijieOperationWillBeDoneAfterLogin 决定了在登录锐捷系统后进行什么操作（启、停、检查账户状态）
 */
- (void)switchAccountStatusToResumeOrSuspend:(SFRuijieOperationWillBeDoneAfterLogin)ruijieOperationWillBeDone
{
    [_ruijieDelegate configLabelForWaiting];
    [self loginAccountManagingSystemTo:ruijieOperationWillBeDone];
}

/**
 *  启、停操作的第一步：登录锐捷系统
 *
 *  @param ruijieOperationWillBeDoneAfterLogin 决定了在登录锐捷系统后进行什么操作（启、停、检查账户状态）
 */
- (void)loginAccountManagingSystemTo:(SFRuijieOperationWillBeDoneAfterLogin)ruijieOperationWillBeDoneAfterLogin
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/scgroup/web/login_judge.jsf"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = kTimeIntervalForLogin;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"act=add&name=%@&password=%@&verify=%@",_userAccountIDForSchoolNetwork,_userAccountPasswordForSchoolNetwork,_verificationCode];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSString *stringFromData = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"%@",stringFromData);
            if ([stringFromData rangeOfString:@"self.location='../../../module/webcontent/web/index_self.jsf?'"].location != NSNotFound)
            {
                NSLog(@"成功登陆");
                switch (ruijieOperationWillBeDoneAfterLogin)
                {
                    case SFRuijieResumeAccount:
                        [self fetchAuthorizationInfoFor:SFRuijieResumeAccount];
                        break;
                    case SFRuijieSuspendAccount:
                        [self fetchAuthorizationInfoFor:SFRuijieSuspendAccount];
                        break;
                    case SFRuijieCheckAccountAvailability:
                        [self startCheckStatus];
                        break;
                    default:
                        break;
                }
            }
            else
            {
//TODO:根据返回的错误信息做到判断是哪部分出错
                NSLog(@"登录出错，检查下用户名密码验证码呀");
                [_ruijieDelegate showAlertViewWithTitle:@"所填信息错误" message:@"登录出错，检查下用户名密码验证码呀"cancelButtonTitle:@"Cancel"];
                [self loadVerificationCodeImage];
            }

        }
        else
        {
            NSLog(@"NetWork Error: %@", error);
            [self showAlertViewForNetworkError:error changeForTitle:nil changeForMessage:nil];
        }
    }];
    
    [dataTask resume];
}

/**
 *  第二步：在登录锐捷后返回的页面内调用正则表达式搜索进行启停操作时需要的字段
 */
- (void)fetchAuthorizationInfoFor:(SFRuijieOperationWillBeDoneAfterLogin)operationWillBeDone
{
    NSString *urlString;
    if (operationWillBeDone == SFRuijieResumeAccount)
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf";
    }
    else if (operationWillBeDone == SFRuijieSuspendAccount)
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf";
    }
    else
    {
        NSLog(@"Resume||Suspend  ERROR!");
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = kTimeIntervalForFetchAuthorizationInfo;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"已接收到Input值");
            NSString *startAccountContentRecirvedString = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];

            [self analyseRegularExpressionFromSourceString:startAccountContentRecirvedString];

            [self changeAccountStatusTo:operationWillBeDone];
        }
        else
        {
            NSLog(@"Error: %@", error);
            [self showAlertViewForNetworkError:error changeForTitle:nil changeForMessage:nil];
        }
    }];
    
    [dataTask resume];
    
}

/**
 *  第三步：通过POST实现启或停账户
 */
- (void)changeAccountStatusTo:(SFRuijieOperationWillBeDoneAfterLogin)operationWillBeDone
{
    NSString *urlString;
    NSString *operationGB2312NameString;
    NSString *stringFromSusOrRes;
    NSString *operationChineseNameString;
    NSString *resumeOrSuspend;
    if (operationWillBeDone == SFRuijieResumeAccount)
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf";
        operationGB2312NameString = @"%C8%B7%C8%CF%BB%D6%B8%B4";
        stringFromSusOrRes = @"res";
        operationChineseNameString = @"启用";
        resumeOrSuspend = @"resume";
    }
    else if (operationWillBeDone == SFRuijieSuspendAccount)
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf";
        operationGB2312NameString = @"%C8%B7%C8%CF%D4%DD%CD%A3";
        stringFromSusOrRes = @"sus";
        operationChineseNameString = @"停用";
        resumeOrSuspend = @"suspend";
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = kTimeIntervalForChangeAccountStatus;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *suspendString = operationGB2312NameString;
    NSString *params = [NSString stringWithFormat:@"act=init&op=%@&UserOperationForm:targetUserId=%@&UserOperationForm:operationVerifyCode=%@&submitCodeId=%@&UserOperationForm:verify=%@&UserOperationForm:%@=%@&com.sun.faces.VIEW=%@&UserOperationForm=UserOperationForm",resumeOrSuspend,_userAccountIDForSchoolNetwork,_operationVerifyCode,_submitCodeId,_verificationCode,stringFromSusOrRes,suspendString,_comSunFacesVIEW];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSASCIIStringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error == nil)
        {
            NSString * completionString= [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"%@",completionString);
            if ([completionString rangeOfString:@"alert"].location != NSNotFound)
            {
                NSLog(@"成功%@",operationChineseNameString);
                [self checkUserAccountStatus];
                [_ruijieDelegate showSuccessAlertView];
            }
            else if ([completionString rangeOfString:@"ÒÑ¾­´¦ÓÚÕý³£×´Ì¬,ÎÞÐèÔÙ½øÐÐ»Ö¸´!"].location != NSNotFound)
            {
                NSLog(@"账户已经是正常了吧？");
                [_ruijieDelegate showAlertViewWithTitle:@"账户已经是开启状态" message:@"伦家账户本来就是是正常了啦" cancelButtonTitle:nil];
            }
            else if ([completionString rangeOfString:@"ÒÑ¾­´¦ÓÚÔÝÍ£×´Ì¬,ÎÞÐèÔÙ½øÐÐÔÝÍ£!"].location != NSNotFound)
            {
                NSLog(@"账户已经停用了吧？");
                [_ruijieDelegate showAlertViewWithTitle:@"账户已经是暂停状态" message:@"伦家账户本来就已经是停用了啦" cancelButtonTitle:nil];
            }
            else
            {
                NSLog(@"%@失败请重试",operationChineseNameString);
            }
        }
        else
        {
            [self showAlertViewForNetworkError:error changeForTitle:nil changeForMessage:nil];
        }

    }];
    [dataTask resume];
    NSLog(@"POST Over!");
    
    
}

#pragma mark Config Kits

/**
 *  负责取消系统对自签名证书的安全限制
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

/**
 *  检查用户账户状态
 */
- (void)checkUserAccountStatus
{
    [self loginAccountManagingSystemTo:SFRuijieCheckAccountAvailability];
    [_ruijieDelegate configLabelForWaiting];
}
/**
 *  只是组件一部分，不要直接调用。使用前需要先登录锐捷，回调中调用此方法
 */
- (void)startCheckStatus
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = kTimeIntervalForCheckAccountStatus;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSLog(@"Opened Page");
        if (data.length > 10000)
        {
            NSString *completionString= [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"%@",completionString);
            NSRegularExpression *normalStateIndicatorString = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"<span id=\"UserOperationForm:stateFlag\">&#27491;&#24120;</span>"] options:0 error:nil];
            NSRegularExpression *suspendingStateIndicatorString = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"<span id=\"UserOperationForm:stateFlag\">&#26242;&#20572;</span>"] options:0 error:nil];
            NSInteger numberOfMatchesOfNormalStateString = [normalStateIndicatorString numberOfMatchesInString:completionString options:0 range:NSMakeRange(0, [completionString length])];
            NSInteger numberOfMatchesOfSuspendingStateString = [suspendingStateIndicatorString numberOfMatchesInString:completionString options:0 range:NSMakeRange(0, [completionString length])];

            NSLog(@"Normal Found %ld, Suspend Found %ld",(long)numberOfMatchesOfNormalStateString,(long)numberOfMatchesOfSuspendingStateString);
            if (numberOfMatchesOfNormalStateString > 0 && numberOfMatchesOfSuspendingStateString == 0)
            {
                _userAccountState = @"normal";
                [_ruijieDelegate showUserAccountStatus:@"normal"];

            }
            else if (numberOfMatchesOfNormalStateString == 0 && numberOfMatchesOfSuspendingStateString > 0)
            {
                _userAccountState = @"suspended";
                [_ruijieDelegate showUserAccountStatus:@"suspended"];

            }
            else
            {
                NSLog(@"ERROR Checking Account State,Page recieved may have Too Many Matches or NO match");
            }
        }
        else
        {
            NSLog(@"Error May Occur at Login");
            [self showAlertViewForNetworkError:error changeForTitle:nil changeForMessage:nil];
        }

    }];
    
    [dataTask resume];

}

- (void)setupUserAccountID:(NSString *)userAccountID andPassword:(NSString *)password VerificationCode:(NSString *)verificationCode
{
    _userAccountIDForSchoolNetwork = userAccountID;
    _userAccountPasswordForSchoolNetwork = password;
    _verificationCode = verificationCode;
}

/**
 *  通过传入的String，用内部保存的正则表达式分析，找出结果后放到实例变量中
 *
 *  @param sourceString 传入的内容String
 */
- (void)analyseRegularExpressionFromSourceString:(NSString *)sourceString
{
    NSString *patternOfOperationVerificationCode = @"(?<=type=\"hidden\" name=\"UserOperationForm:operationVerifyCode\" value=\").*(?=\" />)";
    NSString *patternOfsubmitCodeId = @"(?<=name=\"submitCodeId\" value=\").*(?=\" />)";
    NSString *patternOfcom_sun_faces_VIEW = @"(?<=id=\"com.sun.faces.VIEW\" value=\").*(?=\" /><input)";
    _operationVerifyCode = [self analyseStringUsingRegularExpression:sourceString usingRegularExpression:patternOfOperationVerificationCode];
    _submitCodeId = [self analyseStringUsingRegularExpression:sourceString usingRegularExpression:patternOfsubmitCodeId];
    _comSunFacesVIEW = [self analyseStringUsingRegularExpression:sourceString usingRegularExpression:patternOfcom_sun_faces_VIEW];
}

/**
 *  通过传入正则表达式解析内容
 *
 *  @param sourceString      待分析内容
 *  @param regularExpression 正则表达式
 *
 *  @return 返回找到的字符串（仅支持一个）
 */
- (NSString *)analyseStringUsingRegularExpression:(NSString *)sourceString usingRegularExpression:(NSString *)regularExpression
{
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray* match = [reg matchesInString:sourceString options:0 range:NSMakeRange(0, [sourceString length])];
    NSString *resultString = [[NSString alloc]init];
    if (match.count != 0)
    {
        for (NSTextCheckingResult *matc in match)
        {
            NSRange range = [matc range];
            NSLog(@"%@",[sourceString substringWithRange:range]);
            resultString = [sourceString substringWithRange:range];
        }
    }
    return resultString;
}


- (void)showAlertViewForNetworkError:(NSError *)networkError changeForTitle:(NSString *)changeForTitle changeForMessage:(NSString *)changeForMessage
{
    NSString *title = @"网络错误";
    NSString *message = [NSString stringWithFormat:@"%@",[networkError.userInfo objectForKey:@"NSLocalizedDescription"]];
    NSString *cancelButtonTitle = @"Cancel";
    if (changeForTitle != nil)
    {
        title = changeForTitle;
    }
    if (changeForMessage != nil)
    {
        message = changeForMessage;
    }
    [_ruijieDelegate showAlertViewWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
}



@end
