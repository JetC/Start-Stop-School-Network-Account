//
//  SFDigitalChinaAccountManager.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTimeIntervalForVerificationCodeImage 3
#define kTimeIntervalForLogin 3
#define kTimeIntervalForFetchAuthorizationInfo 3
#define kTimeIntervalForChangeAccountStatus 3
#define kTimeIntervalForCheckAccountStatus 3

@protocol SFDigitalChinaDelegate <NSObject>


@end

@interface SFDigitalChinaAccountManager : NSObject<NSURLSessionDelegate>

typedef NS_ENUM(uint, SFDigitalChinaOperationWillBeDone)
{
    /**
     *  启用神码账号
     */
    SFDigitalChinaResumeAccount,
    /**
     *  暂停神码账号
     */
    SFDigitalChinaSuspendAccount,
    /**
     *  检查神码账号可用性(暂不可用)
     */
    SFDigitalChinaCheckAccountAvailability
};
- (void)loginAccountManagingSystemTo:(SFDigitalChinaOperationWillBeDone)digitalChinaOperationWillBeDone;
- (void)fetchParam;

@end
