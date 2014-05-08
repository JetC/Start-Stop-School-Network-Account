//
//  SFViewController.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 4/28/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFViewController.h"
// !!!:怎么判断校园网状况
//TODO:mm
//FIXME:mm
//???:ooo

@interface SFViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userAccountIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userAccountPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (strong, nonatomic) IBOutlet UIImageView *verificationCodeImageView;
@property (weak, nonatomic) IBOutlet UIButton *resumeAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *suspendAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *userAccountStatusLabel;
@property (strong, nonatomic) NSString *userAccountID;
@property (strong, nonatomic) NSString *userAccountPassword;
@property (strong, nonatomic) NSString *userInputedVerificationCode;

@end

@implementation SFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SFRuiJieAccountManager sharedManager]  loadVerificationCodeImage];
    [SFRuiJieAccountManager sharedManager].ruijieDelegate = self;
    
}

-(void)showVerificationCodeImage:(UIImage *)verificationCodeImage
{
    if (_verificationCodeImageView == nil)
    {
        _verificationCodeImageView = [[UIImageView alloc]init];
    }

    _verificationCodeImageView.image = verificationCodeImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resumeAccount:(id)sender
{
    [self submitUserInputedInfo];
    [self setupUserIDAndPasswordAndVerificationCodeFor:SFRuijieResumeAccount];
}

- (IBAction)suspendAccount:(id)sender
{
    [self submitUserInputedInfo];
    [self setupUserIDAndPasswordAndVerificationCodeFor:SFRuijieSuspendAccount];

}
- (IBAction)checkAccountStatus:(id)sender
{
    [self submitUserInputedInfo];
    [self setupUserIDAndPasswordAndVerificationCodeFor:SFRuijieCheckAccountAvailability];
}


/**
 *  获取当前TextField中用户输入的验证码并传值给锐捷的Model
 */
- (void)submitUserInputedInfo
{
    _userInputedVerificationCode = _verificationCodeTextField.text;
    _userAccountID = _userAccountIDTextField.text;
    _userAccountPassword = _userAccountPasswordTextField.text;
}

- (void)configLabelForWaiting
{
    _userAccountStatusLabel.text = @"正在加载中啦啦啦( ˘•ω•˘ )";
}

- (void)showSuccessAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接成功" message:@"已经完成了锐捷的操作" delegate:nil cancelButtonTitle:@"好的呢！" otherButtonTitles: nil];
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [alertView show];
    }];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
    if (title == nil || [title  isEqual: @""])
    {
        title = @"提示";
    }
    if (cancelButtonTitle == nil || [cancelButtonTitle  isEqual: @""])
    {
        cancelButtonTitle = @"知道啦！";
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [alertView show];
    }];
}


- (void)showUserAccountStatus:(NSString *)userAccountStatus
{
    if ([userAccountStatus isEqualToString:@"normal"])
    {
        _userAccountStatusLabel.text = @"账户现在是启动状态";
    }
    else if([userAccountStatus isEqualToString:@"suspended"])
    {
        _userAccountStatusLabel.text = @"账户现在是停用状态";
    }
}

- (void)setupUserIDAndPasswordAndVerificationCodeFor:(SFRuijieOperationWillBeDoneAfterLogin)operationWillBeDone
{
    if (!([_userAccountID isEqualToString:@""] && [_userAccountPassword isEqualToString:@""] && [_userInputedVerificationCode isEqualToString:@""]))
    {
        [[SFRuiJieAccountManager sharedManager] setupUserAccountID:_userAccountID andPassword:_userAccountPassword VerificationCode:_userInputedVerificationCode];
        switch (operationWillBeDone)
        {
            case SFRuijieResumeAccount:
                [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:SFRuijieResumeAccount];
                break;
            case SFRuijieSuspendAccount:
                [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:SFRuijieSuspendAccount];
                break;
            case SFRuijieCheckAccountAvailability:
                [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:SFRuijieCheckAccountAvailability];
                break;

            default:
                break;
        }
    }
    else
    {
        [self showAlertViewWithTitle:@"输入错误" message:@"说好的用户名密码验证码呢>_<" cancelButtonTitle:@"啊 马上！"];
    }

//TODO:做到先检查用户名密码验证码再继续操作

}







@end
