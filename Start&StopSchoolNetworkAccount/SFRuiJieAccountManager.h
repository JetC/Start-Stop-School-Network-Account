//
//  SFRuiJieAccountManager.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/1/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SFRuiJieDelegate

- (void)showVerificationCodeImage:(UIImage *)verificationCodeImage;
- (void)showSuccessAlertView;
- (void)showUserAccountStatus:(NSString *)userAccountStatus;
- (void)configLabelForWaiting;


@end

//TODO:失败回调，参考Wifi
@interface SFRuiJieAccountManager : NSObject<NSURLSessionDelegate>

/**
 *  通过CheckStatus判断得到的用户账户状态，分为Normal和Suspended两种
 */
@property (strong, nonatomic) id <SFRuiJieDelegate>ruijieDelegate;


+ (instancetype)sharedManager;
- (void)loadVerificationCodeImage;
- (void)setupUserAccountID:(NSString *)userAccountID andPassword:(NSString *)password VerificationCode:(NSString *)verificationCode;
- (void)switchAccountStatusToResumeOrSuspend:(NSString *)resumeOrSuspend;
- (void)checkUserAccountStatus;



/*
 已经是暂停状态时返回页面会显示：
 <span id="UserOperationForm:stateFlag">暂停</span>
 <span id="UserOperationForm:stateFlag">&#26242;&#20572;</span>
 
 
 已经是正常状态时返回页面会显示：
 <span id="UserOperationForm:stateFlag">正常</span>
 <span id="UserOperationForm:stateFlag">&#27491;&#24120;</span>
 */

@end
