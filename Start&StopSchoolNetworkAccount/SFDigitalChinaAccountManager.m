//
//  SFDigitalChinaAccountManager.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFDigitalChinaAccountManager.h"

@implementation SFDigitalChinaAccountManager

-(void)switchAccountStatusToResumeOrSuspend:(NSString *)resumeOrSuspend
{
    NSInteger isSuspend;
    if ([[resumeOrSuspend lowercaseString]isEqualToString:@"resume"])
    {
        isSuspend = 0;
    }
    else if ([[resumeOrSuspend lowercaseString]isEqualToString:@"suspend"])
    {
        isSuspend = 1;
    }
    else
    {
        NSLog(@"String Error!");
    }
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/work_preday.jsp"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"table=101&userName=2012302630057&allowPreday=%d&submit=submit",isSuspend];
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
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    
    [dataTask resume];
}


@end
