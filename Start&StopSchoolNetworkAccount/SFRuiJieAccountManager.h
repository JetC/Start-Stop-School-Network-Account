//
//  SFRuiJieAccountManager.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/1/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFRuiJieAccountManager : NSObject

@property (strong, nonatomic) UIImage *verificationCodeImage;
@property (strong, nonatomic) NSString *userAccountIDForSchoolNetwork;
@property (strong, nonatomic) NSString *userAccountPasswordForSchoolNetwork;
@property (strong, nonatomic) NSString *verificationCode;


+ (instancetype)sharedManager;
- (void)loadVerificationCodeImage;
- (void)switchAccountStatusToResumeOrSuspend:(NSString *)resumeOrSuspend;


@end
