//
//  SFDigitalChinaViewController.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFDigitalChinaViewController.h"

@implementation SFDigitalChinaViewController

- (IBAction)switchAccountStatus:(id)sender
{
    SFDigitalChinaAccountManager *digitalChinaAccountManager = [[SFDigitalChinaAccountManager alloc]init];
    [digitalChinaAccountManager switchAccountStatusToResumeOrSuspend:@"suspend"];
}
@end
