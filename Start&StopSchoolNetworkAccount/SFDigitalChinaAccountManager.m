//
//  SFDigitalChinaAccountManager.m
//  WHU Mobile
//
//  Created by 孙培峰 on 5/16/14.
//  Copyright (c) 2014 黄 嘉恒. All rights reserved.
//

#import "SFDigitalChinaAccountManager.h"
#import <RegExCategories/RegExCategories.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSString+ZQ.h"

@interface SFDigitalChinaAccountManager ()<NSURLSessionDelegate>

@property (strong, nonatomic) NSString *param;
@property (strong, nonatomic) NSURLSession *session;

@end

@implementation SFDigitalChinaAccountManager

- (id)init
{
    self = [super init];
    if (self)
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)checkAvailabilityOfAccount:(NSString *)account password:(NSString *)password delegate:(__weak id<SFDigitalChinaDelegate>)delegate
{
    [self loginDigitalChinaWithAccount:account password:password delegate:delegate];
}

- (void)loginDigitalChinaWithAccount:(NSString *)account password:(NSString *)password delegate:(__weak id<SFDigitalChinaDelegate>)delegate
{
    [self fetchParamWithCompletionHandler:^{
        [self loginAccountManagingSystemWithAccount:account password:password delegate:delegate];
    }];
}


- (void)loginAccountManagingSystemWithAccount:(NSString *)userAccountID password:(NSString *)password delegate:(__weak id<SFDigitalChinaDelegate>)delegate
{
    NSString *md5EncryptedPassword = [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@DCN",password,_param]];
    md5EncryptedPassword = [md5EncryptedPassword uppercaseString];
    NSString *params = [NSString stringWithFormat:@"preday=true&isCharge=0&username=%@&password=%@&Submit=Submit",userAccountID,md5EncryptedPassword];
    NSLog(@"%@",params);
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/loginForPreday.jsp"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSISOLatin1StringEncoding]];
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"Over");
            NSString *completionString= [[NSString alloc]initWithData:data encoding:[NSString GBKStringEncoding]];
            NSLog(@"%@",completionString);
            if ([completionString rangeOfString:@"用户不存在"].location != NSNotFound)
            {
                NSLog(@"不是神码用户");
                [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseInvalidAccount error:nil];
            }
            else if ([completionString rangeOfString:@"用户名非法或密码不正确"].location != NSNotFound)
            {
                NSLog(@"用户名或密码错误");
                [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseWrongPassword error:nil];
            }
            else if ([completionString rangeOfString:@"预付包天用户自主启停"].location != NSNotFound)
            {
                NSLog(@"成功登录神码");
                [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseValidAccount error:nil];
            }
            else
            {
                NSLog(@"ERRor");
            }
        }
    }];
    [dataTask resume];
}


- (void)changeAccountStatusTo:(NSInteger)isSuspend userAccountID:(NSString *)userAccountID delegate:(__weak id<SFDigitalChinaDelegate>)delegate
{
    isSuspend > 1 ?isSuspend = 1:isSuspend;
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/work_preday.jsp"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"table=101&userName=%@&allowPreday=%ld&submit=submit",userAccountID,(long)isSuspend];
    NSData *data = [params dataUsingEncoding:NSUnicodeStringEncoding];
    [urlRequest setHTTPBody:data];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSISOLatin1StringEncoding]];
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSLog(@"成功登陆");
            NSString * completionString= [[NSString alloc]initWithData:data encoding:[NSString GBKStringEncoding]];
            NSLog(@"completionString: %@",completionString);
            if ([completionString rangeOfString:@"包天用户自主启停修改成功"].location != NSNotFound)
            {
                NSLog(@"检测到成功信息");
                switch (isSuspend)
                {
                    case 0:
                        [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseDidResume error:nil];
                        break;
                    case 1:
                        [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseDidSuspend error:nil];
                        break;
                    default:
                        break;
                }
            }
            else if ([completionString rangeOfString:@"error"].location != NSNotFound)
            {
                NSLog(@"启停操作失败！(不算是网络错误)");
                [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseFailed error:nil];
            }
        }
        else
        {
            [delegate digitalChinaAccountManageResponse:SFDigitalChinaAccountResponseFailed error:nil];
            NSLog(@"Error: %@", error);
        }
    }];

    [dataTask resume];
}

#pragma mark Config Kits

- (void)fetchParamWithCompletionHandler:(void (^)(void))completionHandler
{
    NSURL *url = [NSURL URLWithString:@"http://whu-sa.whu.edu.cn/user_preday.jsp"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLSessionDataTask * dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error == nil)
        {
            NSString *contentString= [[NSString alloc]initWithData:data encoding:NSISOLatin1StringEncoding];
            self.param = [contentString firstMatch:RX(@"(?<=<param name = \"param0\" value = \").*(?=\">)")];
            completionHandler();
        }
    }];
    [dataTask resume];
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString
{
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
