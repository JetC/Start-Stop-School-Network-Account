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

@property (strong, nonatomic) IBOutlet UIImageView *verificationCodeImageView;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextFieldView;
@property (weak, nonatomic) IBOutlet UIButton *resumeAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *suspendAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *userAccountStatusLabel;
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
    [self submitVerificationCode];
    
    [self setupUserIDAndPasswordAndVerificationCode];
    [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:@"resume"];
}

- (IBAction)suspendAccount:(id)sender
{
    [self submitVerificationCode];
    [self setupUserIDAndPasswordAndVerificationCode];
    [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:@"suspend"];
}
- (IBAction)checkAccountStatus:(id)sender
{
    [self checkAccountStatus];
}

- (void)checkAccountStatus
{
    [self submitVerificationCode];
    
    [self setupUserIDAndPasswordAndVerificationCode];
    
    [[SFRuiJieAccountManager sharedManager]checkUserAccountStatus];
}

/**
 *  获取当前TextField中用户输入的验证码并传值给锐捷的Model
 */
- (void)submitVerificationCode
{
    _userInputedVerificationCode = _verificationCodeTextFieldView.text;
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

- (void)setupUserIDAndPasswordAndVerificationCode
{
    static NSInteger isFirstLoad = 0;
    if (isFirstLoad == 0)
    {
        [[SFRuiJieAccountManager sharedManager] setupUserAccountID:@"2012301130125" andPassword:@"204765" VerificationCode:_userInputedVerificationCode];
        isFirstLoad++;
    }

}







@end
