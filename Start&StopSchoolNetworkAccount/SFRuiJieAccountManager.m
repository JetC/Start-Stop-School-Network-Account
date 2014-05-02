//
//  SFRuiJieAccountManager.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/1/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFRuiJieAccountManager.h"
#import "SFViewController.h"

@interface SFRuiJieAccountManager()<NSURLSessionDelegate>
/**
 *  标识是resume还是suspend操作，所有网络操作函数依赖于此（除了loadVerificationCodeImage）
 */
@property (strong, nonatomic) NSString *resumeOrSuspend;

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
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            if (_verificationCodeImage == nil)
            {
                _verificationCodeImage = [[UIImage alloc]init];
            }
            _verificationCodeImage = [UIImage imageWithData:data];
            NSLog(@"Load Verification Code Image Successfully!");
            [_ruijieDelegate showVerificationCodeImage];
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    
    [dataTask resume];
}


/**
 *  用于使头文件与本文件中方法名称不同，并且设置resumeOrSuspend状态
 *
 *  @param resumeOrSuspend 区分启、停操作，仅允许输入NSString类型的resume或suspend（不区分大小写）。
 */
- (void)switchAccountStatusToResumeOrSuspend:(NSString *)resumeOrSuspend
{
    _resumeOrSuspend = [resumeOrSuspend lowercaseString];
    [self loginAccountManagingSystem];
}

/**
 * 第一步：触发login锐捷系统操作，等到回调成功后会继续触发一系列函数直至完成启或停的操作
 */
- (void)loginAccountManagingSystem
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/scgroup/web/login_judge.jsf"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"act=add&name=%@&password=%@&verify=%@",_userAccountIDForSchoolNetwork,_userAccountPasswordForSchoolNetwork,_verificationCode];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"成功登陆");
            
//            [self checkUserAccountStatus];
            [self fetchAuthorizationInfo];
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    
    [dataTask resume];
}

/**
 *  第二步：在登录锐捷后返回的页面内调用正则表达式搜索进行启停操作时需要的字段
 */
- (void)fetchAuthorizationInfo
{
    NSString *urlString;
    if ([_resumeOrSuspend isEqual:@"resume"])
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf";
    }
    else if ([_resumeOrSuspend isEqual:@"suspend"])
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf";
    }
    else
    {
        NSLog(@"Resume||Suspend String ERROR!");
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"已接收到Input值");
            NSString *startAccountContentRecirvedString = [[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8];
            NSString *patternOfOperationVerificationCode = @"(?<=type=\"hidden\" name=\"UserOperationForm:operationVerifyCode\" value=\").*(?=\" />)";
            NSString *patternOfsubmitCodeId = @"(?<=name=\"submitCodeId\" value=\").*(?=\" />)";
            NSString *patternOfcom_sun_faces_VIEW = @"(?<=id=\"com.sun.faces.VIEW\" value=\").*(?=\" /><input)";
            _operationVerifyCode = [self analyseStringUsingRegularExpression:startAccountContentRecirvedString usingRegularExpression:patternOfOperationVerificationCode];
            _submitCodeId = [self analyseStringUsingRegularExpression:startAccountContentRecirvedString usingRegularExpression:patternOfsubmitCodeId];
            _comSunFacesVIEW = [self analyseStringUsingRegularExpression:startAccountContentRecirvedString usingRegularExpression:patternOfcom_sun_faces_VIEW];
            
            [self changeAccountStatus];
            
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    
    [dataTask resume];
    
}

/**
 *  第三步：通过POST实现启或停账户
 */
- (void)changeAccountStatus
{
    NSString *urlString;
    NSString *operationGB2312NameString;
    NSString *stringFromSusOrRes;
    NSString *operationChineseNameString;
    if ([_resumeOrSuspend  isEqualToString:@"resume"])
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf";
        operationGB2312NameString = @"%C8%B7%C8%CF%BB%D6%B8%B4";
        stringFromSusOrRes = @"res";
        operationChineseNameString = @"启用";
    }
    else if ([_resumeOrSuspend  isEqualToString:@"suspend"])
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf";
        operationGB2312NameString = @"%C8%B7%C8%CF%D4%DD%CD%A3";
        stringFromSusOrRes = @"sus";
        operationChineseNameString = @"停用";
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *suspendString = operationGB2312NameString;
    NSString *params = [NSString stringWithFormat:@"act=init&op=%@&UserOperationForm:targetUserId=%@&UserOperationForm:operationVerifyCode=%@&submitCodeId=%@&UserOperationForm:verify=%@&UserOperationForm:%@=%@&com.sun.faces.VIEW=%@&UserOperationForm=UserOperationForm",_resumeOrSuspend,_userAccountIDForSchoolNetwork,_operationVerifyCode,_submitCodeId,_verificationCode,stringFromSusOrRes,suspendString,_comSunFacesVIEW];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSString * completionString= [[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8];
        
        if ([completionString rangeOfString:@"alert"].location != NSNotFound)
        {
            NSLog(@"成功%@",operationChineseNameString);
//            NSLog(@"%@",completionString);
//            NSLog(@"%d",[completionString rangeOfString:@"alert"].location);
            [_ruijieDelegate showSuccessAlertView];
        }
        else
        {
            NSLog(@"%@失败请重试",operationChineseNameString);
        }
    }];
    [dataTask resume];
    NSLog(@"POST Over!");
    
    
}

#pragma mark Config Kits

/**
 *  通过传入正则表达式解析内容
 *
 *  @param sourceString      待分析内容
 *  @param regularExpression 正则表达式
 *
 *  @return 返回找到的字符串（仅有一个）
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


/**
 *  负责取消系统对自签名证书的安全限制
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

/**
 *  预备用此方法检查是否已经登录，尚未决定使用
 */
- (void)checkUserAccountStatus
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                       {
                                           NSLog(@"Opened Page");
                                       }];
    
    [dataTask resume];
}

@end