//
//  SFRuiJieAccountManager.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/1/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTimeIntervalForVerificationCodeImage 3
#define kTimeIntervalForLogin 3
#define kTimeIntervalForFetchAuthorizationInfo 3
#define kTimeIntervalForChangeAccountStatus 3
#define kTimeIntervalForCheckAccountStatus 3



@protocol SFRuiJieDelegate

- (void)showVerificationCodeImage:(UIImage *)verificationCodeImage;//使ViewController显示验证码图片
- (void)showUserAccountStatus:(NSString *)userAccountStatus;//显示用户账户的状态（正常还是暂停）
- (void)configLabelForWaiting;//当等待时显示请稍后等的内容
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;//显示AlertView


@end

//TODO:失败回调，参考Wifi
@interface SFRuiJieAccountManager : NSObject<NSURLSessionDelegate>

typedef NS_ENUM(uint, SFRuijieOperationWillBeDoneAfterLogin)
{
    /**
     *  启用锐捷账号
     */
    SFRuijieResumeAccount,
    /**
     *  停用锐捷账号
     */
    SFRuijieSuspendAccount,
    /**
     *  检查用户是否存在（判断是锐捷还是神码用户时先登录锐捷）
     */
    SFRuijieCheckAccountAvailability
};


/**
 *  通过CheckStatus判断得到的用户账户状态，分为Normal和Suspended两种
 */
@property (strong, nonatomic) id <SFRuiJieDelegate>ruijieDelegate;


+ (instancetype)sharedManager;

/**
 *  获取验证码，并通过Delegate的回调使验证码显示
 */
- (void)loadVerificationCodeImage;
/**
 *  记录登录所需三个信息
 *
 *  @param userAccountID    校园网用户名
 *  @param password         密码
 *  @param verificationCode 验证码
 */
- (void)setupUserAccountID:(NSString *)userAccountID andPassword:(NSString *)password VerificationCode:(NSString *)verificationCode;
/**
 *  改变用户账户状态或者检查状态
 *
 *  @param ruijieOperationWillBeDone 决定此方法的行为
 */
- (void)switchAccountStatusToResumeOrSuspend:(SFRuijieOperationWillBeDoneAfterLogin)ruijieOperationWillBeDone;




/*
 已经是暂停状态时返回页面会显示：
 <span id="UserOperationForm:stateFlag">暂停</span>
 <span id="UserOperationForm:stateFlag">&#26242;&#20572;</span>
 
 
 已经是正常状态时返回页面会显示：
 <span id="UserOperationForm:stateFlag">正常</span>
 <span id="UserOperationForm:stateFlag">&#27491;&#24120;</span>
 */

@end
