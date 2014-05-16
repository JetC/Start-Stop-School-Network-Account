//
//  SFDigitalChinaAccountManager.h
//  WHU Mobile
//
//  Created by 孙培峰 on 5/16/14.
//  Copyright (c) 2014 黄 嘉恒. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SFDigitalChinaAccountResponse)
{
    /**
     *  网络链接错误
     */
    SFDigitalChinaAccountResponseFailed,
    /**
     *  是神码账户，但密码错误
     */
    SFDigitalChinaAccountResponseWrongPassword,
    /**
     *  不存在的用户
     */
    SFDigitalChinaAccountResponseInvalidAccount,
    /**
     *  用户已确定存在
     */
    SFDigitalChinaAccountResponseValidAccount,
    /**
     *  正在登录神码帐号管理
     */
    SFDigitalChinaAccountResponseWillLogin,
    /**
     *  正在启用神码账号
     */
    SFDigitalChinaAccountResponseWillResume,
    /**
     *  已启用神码账号
     */
    SFDigitalChinaAccountResponseDidResume,
    /**
     *  正在停用神码账号
     */
    SFDigitalChinaAccountResponseWillSuspend,
    /**
     *  已停用神码账号
     */
    SFDigitalChinaAccountResponseDidSuspend,
};

@protocol SFDigitalChinaDelegate

- (void)digitalChinaAccountManageResponse:(SFDigitalChinaAccountResponse)response error:(NSError *)error;


@end

@interface SFDigitalChinaAccountManager : NSObject

- (void)changeAccountStatusTo:(NSInteger)isSuspend userAccountID:(NSString *)userAccountID delegate:(__weak id<SFDigitalChinaDelegate>)delegate;

- (void)checkAvailabilityOfAccount:(NSString *)account password:(NSString *)password delegate:(__weak id<SFDigitalChinaDelegate>)delegate;

@end

























