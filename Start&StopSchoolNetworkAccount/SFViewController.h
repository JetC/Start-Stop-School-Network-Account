//
//  SFViewController.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 4/28/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRuiJieAccountManager.h"

@interface SFViewController : UIViewController<UITextFieldDelegate,SFRuiJieDelegate>

-(void)showVerificationCodeImage:(UIImage *)verificationCodeImage;

@end
