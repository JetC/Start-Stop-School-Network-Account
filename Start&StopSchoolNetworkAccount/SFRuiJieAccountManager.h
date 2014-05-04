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

@end

@interface SFRuiJieAccountManager : NSObject<NSURLSessionDelegate>

/**存放用户校园网账号 */
@property (strong, nonatomic) NSString *userAccountIDForSchoolNetwork;
/**存放用户校园网密码*/
@property (strong, nonatomic) NSString *userAccountPasswordForSchoolNetwork;
/**存放ViewController中返回的由用户输入的验证码*/
@property (strong, nonatomic) NSString *verificationCode;

@property (strong, nonatomic) id <SFRuiJieDelegate>ruijieDelegate;

+ (instancetype)sharedManager;
- (void)loadVerificationCodeImage;
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
