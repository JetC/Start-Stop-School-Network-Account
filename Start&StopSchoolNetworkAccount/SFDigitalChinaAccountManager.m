//
//  SFDigitalChinaAccountManager.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFDigitalChinaAccountManager.h"

@implementation SFDigitalChinaAccountManager

- (void)loginAccountManagingSystemTo:(SFDigitalChinaOperationWillBeDone)digitalChinaOperationWillBeDone
{
    NSInteger isSuspend = 0;
    if (digitalChinaOperationWillBeDone == SFDigitalChinaResumeAccount)
    {
        isSuspend = 0;
    }
    else if (digitalChinaOperationWillBeDone == SFDigitalChinaSuspendAccount)
    {
        isSuspend = 1;
    }
    else if (digitalChinaOperationWillBeDone == SFDigitalChinaCheckAccountAvailability)
    {
    }
    else
    {
        NSLog(@"String Error!");
    }
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/work_preday.jsp"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"table=101&userName=2012301130125&allowPreday=%d&submit=submit",isSuspend];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSISOLatin1StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
//            NSLog(@"成功登陆");
            NSString * completionString= [[NSString alloc]initWithData:data encoding:NSISOLatin1StringEncoding];
            NSLog(@"completionString: %@",completionString);
            if ([completionString rangeOfString:@"success"].location != NSNotFound)
            {
                NSLog(@"检测到成功信息");
            }
            else if ([completionString rangeOfString:@"error : Êý¾Ý¿â³ö´í£¡"].location != NSNotFound)
            {
                NSLog(@"不是神码用户");
            }
            else if ([completionString rangeOfString:@"error"].location != NSNotFound)
            {
                NSLog(@"启停操作失败！");
            }
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
