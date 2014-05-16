//
//  SFDigitalChinaAccountManager.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFDigitalChinaAccountManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface SFDigitalChinaAccountManager ()

@property (strong, nonatomic)NSString *param;
@property (strong, nonatomic)NSString *hexMd5EncryptedPassword;

@end


@implementation SFDigitalChinaAccountManager

- (void)fetchParam
{
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/user_preday.jsp"];
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
            NSString *completionString= [[NSString alloc]initWithData:data encoding:NSISOLatin1StringEncoding];
            _param = [self analyseStringUsingRegularExpression:[NSString stringWithFormat:@"%@",completionString] usingRegularExpression:@"(?<=<param name = \"param0\" value = \").*(?=\">)"];
            [self loginAccountManagingSystemTo:SFDigitalChinaResumeAccount];
        }
    }];
    [dataTask resume];
}



- (void)loginAccountManagingSystemTo:(SFDigitalChinaOperationWillBeDone)digitalChinaOperationWillBeDoneAfterLogin
{
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/loginForPreday.jsp"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = kTimeIntervalForLogin;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];


    NSString *password = @"123456";
    NSString *md5EncryptedPassword = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@DCN",password,_param]];
    _hexMd5EncryptedPassword = [md5EncryptedPassword uppercaseString];
    NSString *params = [NSString stringWithFormat:@"preday=true&isCharge=0&username=2012302630057&password=%@&Submit=Submit",_hexMd5EncryptedPassword];
    NSLog(@"%@",params);

    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSISOLatin1StringEncoding]];

    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"Over");
            NSString *completionString= [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"%@",completionString);
            //Ô¤¸¶°üÌìÓÃ»§×ÔÖ÷ÆôÍ£正常登录后的返回

        }
    }];
    [dataTask resume];
}


- (void)changeAccountStatusTo:(SFDigitalChinaOperationWillBeDone)digitalChinaOperationWillBeDone
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
//    else if (digitalChinaOperationWillBeDone == SFDigitalChinaCheckAccountAvailability)
//    {
//
//    }
    else
    {
        NSLog(@"String Error!");
    }
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/work_preday.jsp"];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"table=101&userName=2012302630057&allowPreday=%ld&submit=submit",(long)isSuspend];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSISOLatin1StringEncoding]];
    [urlRequest setHTTPShouldHandleCookies:YES];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"成功登陆");
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
        }
        else
        {
            NSLog(@"Error: %@", error);
        }
    }];
    
    [dataTask resume];
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
            resultString = [sourceString substringWithRange:range];
        }
    }
    return resultString;
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString  UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];

    return result;
}

- (NSString *)getMd5_16Bit_String:(NSString *)srcString{
    //提取32位MD5散列的中间16位
    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8];//即9～25位
    return result;
}

@end
