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
               NSLog(@"1");
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
                NSLog(@"2");
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
        
//    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    for (NSHTTPCookie *cookie in [cookieStorge cookies])
    {
        NSLog(@"Twice:%@", cookie);
    }
}

//- (void)connection:(NSURLConnection *)connection // IN
//    didReceiveData:(NSData *)data                // IN
//{
//    NSString *reply = [[NSString alloc] initWithData:data
//                                            encoding:NSUTF8StringEncoding];
//    NSNumber *statusInfo =[[reply JSONValue] valueForKey:@"status"] ;
//    NSLog(@"reply=====%@",reply);
//    [reply release];
//    if ([statusInfo intValue]==1) {
//        //保存cookie
//        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)self.responseCopy;
//        NSDictionary *fields = [httpResponse allHeaderFields ];
//        NSLog(@"response头内容＝＝＝%@",[fields description]);
//        //取得cookie
//        if (self.cookie == nil) {
//            NSString *tempCookie =[[NSString alloc] initWithString: [fields valueForKey:@"Set-Cookie"]];
//            self.cookie=tempCookie;
//            [tempCookie release];
//            tempCookie=nil;
//        }
//        else{
//            self.cookie = [fields valueForKey:@"Set-Cookie"];
//        }
//        
//        NSLog(@"cookie = %@",self.cookie);
//        //接受cookie
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
//        NSLog(@"写入后:%@",[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies]);
//    }

+ (NSStringEncoding)GBKStringEncoding
{
    return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
}

@end
