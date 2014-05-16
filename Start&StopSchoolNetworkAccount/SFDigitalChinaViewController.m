//
//  SFDigitalChinaViewController.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFDigitalChinaViewController.h"
@interface SFDigitalChinaViewController ()
@property (nonatomic, strong) SFDigitalChinaAccountManager *digitalChinaAccountManager;
@end
@implementation SFDigitalChinaViewController

- (void)viewDidLoad
{
    self.digitalChinaAccountManager = [[SFDigitalChinaAccountManager alloc]init];
}

- (IBAction)checkAccountAvailability:(id)sender
{
    [self.digitalChinaAccountManager checkAvailabilityOfAccount:@"201230" password:@"123456" delegate:self];
}

- (IBAction)resumeDigitalChinaAccount:(id)sender
{
    [self.digitalChinaAccountManager changeAccountStatusTo:0 userAccountID:@"201230" delegate:self];
}

- (IBAction)suspendDigitalChinaAccount:(id)sender
{
    [self.digitalChinaAccountManager changeAccountStatusTo:1 userAccountID:@"201230" delegate:self];
}


-(void)digitalChinaAccountManageResponse:(SFDigitalChinaAccountResponse)response error:(NSError *)error
{
    switch (response)
    {
        case SFDigitalChinaAccountResponseInvalidAccount:
            //不是神码帐号，需尝试锐捷登录
            break;
        case SFDigitalChinaAccountResponseDidResume:
            //启用成功
            break;
        case SFDigitalChinaAccountResponseDidSuspend:
            //停用成功
            break;
//        case SFDigitalChinaAccountInsufficientAccountBalance:
//            //被提示欠费，用不上这一条的话，请视帐号为已经是停用状态并提示用户
//            break;
        case SFDigitalChinaAccountResponseValidAccount:
            //确认了这个用户是神码的
            break;
        case SFDigitalChinaAccountResponseFailed:
            //网络错误
            break;
        default:
            break;
    }
    NSLog(@"1");
    NSLog(@"%d",response);
}
@end
