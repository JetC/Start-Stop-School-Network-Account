//
//  SFRuiJieAccountManager.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/1/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SFRuiJieDelegate

- (void)showVerificationCodeImage;
- (void)showSuccessAlertView;

@end

@interface SFRuiJieAccountManager : NSObject
/**存放验证码图片*/
@property (strong, nonatomic) UIImage *verificationCodeImage;
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




@end
