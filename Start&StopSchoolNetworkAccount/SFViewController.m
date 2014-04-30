//
//  SFViewController.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 4/28/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFViewController.h"

@interface SFViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *verificationCodeImageView;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextFieldView;
@property (weak, nonatomic) IBOutlet UIButton *startLoginButton;
@property (strong, nonatomic) NSString *verificationCode;
@property (strong, nonatomic) NSString *operationVerifyCode;
@property (strong, nonatomic) NSString *submitCodeId;
@property (strong, nonatomic) NSString *comSunFacesVIEW;
@property (strong, nonatomic) NSString *userAccountIDForSchoolNetwork;
@property (strong, nonatomic) NSString *userAccountPasswordForSchoolNetwork;

@end

@implementation SFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self loadVerificationCodeImage];
    _userAccountIDForSchoolNetwork = @"2012301130125";
    
}


- (void)loadVerificationCodeImage
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/common/web/verifycode.jsp"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            _verificationCodeImageView.image = [UIImage imageWithData:data];
            NSLog(@"Load Verification Code Image Successfully!");
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startLogin:(id)sender
{
    _verificationCode = [[NSString alloc]init];
    _verificationCode = _verificationCodeTextFieldView.text;
    [self login];
}


- (void)login
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/scgroup/web/login_judge.jsf"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"act=add&name=2012301130125&password=204765&verify=%@",_verificationCode];
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
               [self manageSchoolNetworkFor:@"suspend"];
               
           }
           else
           {
               NSLog(@"Error: %@", error);
           }
       }];
    
    [dataTask resume];


}

- (void)manageSchoolNetworkFor:(NSString *)resumeOrSuspend
{
    NSString *urlString = [[NSString alloc]init];
    if ([resumeOrSuspend isEqual:@"resume"])
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf";
    }
    else if ([resumeOrSuspend isEqual:@"suspend"])
    {
        urlString = @"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf";
    }
    else
    {
        NSLog(@"ERROR!");
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlString]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
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
                if ([resumeOrSuspend isEqual:@"resume"])
                {
                    [self resumeAccount];
                }
                else if ([resumeOrSuspend isEqual:@"suspend"])
                {
                    [self suspendAccount];
                }
                else
                {
                    NSLog(@"ERROR!");
                }
            }
            else
            {
                NSLog(@"Error: %@", error);
            }
        }];
    
    [dataTask resume];

}

- (void)resumeAccount
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *resString = @"%C8%B7%C8%CF%BB%D6%B8%B4";
    NSString *params = [NSString stringWithFormat:@"act=init&op=resume&UserOperationForm:targetUserId=%@&UserOperationForm:operationVerifyCode=%@&submitCodeId=%@&UserOperationForm:verify=%@&UserOperationForm:res=%@&com.sun.faces.VIEW=%@&UserOperationForm=UserOperationForm",_userAccountIDForSchoolNetwork,_operationVerifyCode,_submitCodeId,_verificationCode,resString,_comSunFacesVIEW];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSLog(@"POST Over!");
    }];
    [dataTask resume];

}

- (void)suspendAccount
{
    NSURL *url = [NSURL URLWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_suspend.jsf"];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *suspendString = @"%C8%B7%C8%CF%D4%DD%CD%A3";
    NSString *params = [NSString stringWithFormat:@"act=init&op=suspend&UserOperationForm:targetUserId=%@&UserOperationForm:operationVerifyCode=%@&submitCodeId=%@&UserOperationForm:verify=%@&UserOperationForm:sus=%@&com.sun.faces.VIEW=%@&UserOperationForm=UserOperationForm",_userAccountIDForSchoolNetwork,_operationVerifyCode,_submitCodeId,_verificationCode,suspendString,_comSunFacesVIEW];
    NSLog(@"SUSpend:%@",params);
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSLog(@"POST Over!");
    }];
    [dataTask resume];
    
}

- (NSString *)analyseStringUsingRegularExpression:(NSString *)sourceString usingRegularExpression:(NSString *)regularExpression
{
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray* match = [reg matchesInString:sourceString options:NSMatchingCompleted range:NSMakeRange(0, [sourceString length])];
    NSLog(@"%@",match[0]);
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


@end
