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

@end

@implementation SFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self loadVerificationCodeImage];
    
    
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
               [self fetchURLUsingGETWithString:@"https://whu-sb.whu.edu.cn:8443/selfservice/module/userself/web/self_resume.jsf"];
           }
           else
           {
               NSLog(@"Error: %@", error);
           }
       }];
    
    [dataTask resume];


}

- (void)fetchURLUsingGETWithString:(NSString *)urlString
{
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
                NSLog(@"%@",[[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8]);
                NSString *startAccountRecirved = [[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8];
                NSString *patternOfOperationVerificationCode = @"(?<=type=\"hidden\" name=\"UserOperationForm:operationVerifyCode\" value=\").*(?=\" />)";
                NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:patternOfOperationVerificationCode options:0 error:&error];
                NSArray* match = [reg matchesInString:startAccountRecirved options:NSMatchingCompleted range:NSMakeRange(0, [startAccountRecirved length])];
                NSLog(@"%@",match[0]);
                if (match.count != 0)
                {
                    for (NSTextCheckingResult *matc in match)
                    {
                        NSRange range = [matc range];
                        NSLog(@"%@",[startAccountRecirved substringWithRange:range]);
                    }  
                }
            }
            else
            {
                NSLog(@"Error: %@", error);
            }
        }];
    
    [dataTask resume];

}

- (void)fetchAllSavedCookie
{
    NSHTTPCookieStorage *cookieStorge = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorge cookies]) {
        NSLog(@"Once:%@", cookie);
    }
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"CookieName" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"CookieValue" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"CookieDomain" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"CookieOriginURL" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"CookiePath" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"CookieVersion" forKey:NSHTTPCookieVersion];
 
    
    for (NSHTTPCookie *cookie in [cookieStorge cookies])
    {
        NSLog(@"Twice:%@", cookie);
    }
}




@end
