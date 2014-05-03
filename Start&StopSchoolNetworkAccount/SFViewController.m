//
//  SFViewController.m
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 4/28/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import "SFViewController.h"
#import "SFRuiJieAccountManager.h"
// !!!:怎么判断校园网状况
//TODO: hhh
//???:ooo

@interface SFViewController ()<SFRuiJieDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *verificationCodeImageView;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextFieldView;
@property (weak, nonatomic) IBOutlet UIButton *resumeAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *suspendAccountButton;

@property (strong, nonatomic) NSString *userInputedVerificationCode;

@end

@implementation SFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SFRuiJieAccountManager sharedManager].userAccountIDForSchoolNetwork = @"2012301130125";
    [SFRuiJieAccountManager sharedManager].userAccountPasswordForSchoolNetwork = @"204765";
    [[SFRuiJieAccountManager sharedManager]  loadVerificationCodeImage];
    [SFRuiJieAccountManager sharedManager].ruijieDelegate = self;
    
}

-(void)showVerificationCodeImage
{
    if (_verificationCodeImageView == nil)
    {
        _verificationCodeImageView = [[UIImageView alloc]init];
    }

    _verificationCodeImageView.image = [SFRuiJieAccountManager sharedManager].verificationCodeImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resumeAccount:(id)sender
{
    [self submitVerificationCode];
    
    [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:@"resume"];
}

- (IBAction)suspendAccount:(id)sender
{
    [self submitVerificationCode];
    
    [[SFRuiJieAccountManager sharedManager] switchAccountStatusToResumeOrSuspend:@"suspend"];
}

/**
 *  获取当前TextField中用户输入的验证码并传值给锐捷的Model
 */
- (void)submitVerificationCode
{
    _userInputedVerificationCode = [[NSString alloc]init];
    _userInputedVerificationCode = _verificationCodeTextFieldView.text;
    [SFRuiJieAccountManager sharedManager].verificationCode = _userInputedVerificationCode;
}

- (void)showSuccessAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接成功" message:@"已经完成了锐捷的操作" delegate:nil cancelButtonTitle:@"好的呢！" otherButtonTitles: nil];
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [alertView show];
    }];
}


//
//+ (ZQWlan *)loginUsingUsername:(NSString *)username andPassword:(NSString *)password delegate:(id<ZQWlanDelegate>)delegate
//{
//    ZQWlan *wlan = [ZQWlan new];
//    //!!!
//    wlan.operationQueue = [[NSOperationQueue alloc] init];
//    
//    [NCDC addObserverForName:ZQWlanStatusDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//        [NCDC removeObserver:wlan];
//        
//        ZQWlanStatus status = [(NSNumber *)note.object integerValue];
//        
//        if (status==ZQWlanStatusNotWHU_WLAN) {
//            [delegate wlan:wlan connectResponse:ZQWlanResponseNotWHU_WLAN error:nil];
//        } else if (status==ZQWlanStatusDidLogin) {
//            [delegate wlan:wlan connectResponse:ZQWlanResponseDidLogin error:nil];
//        } else if (status==ZQWlanStatusDidNotLogin) {
//            
//            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//            config.timeoutIntervalForRequest = 15;
//            NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:wlan delegateQueue:nil];
//            
//            NSURL *loginURL = [NSURL URLWithString:@"https://wlan.whu.edu.cn/portal/login"];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
//            request.HTTPMethod = @"POST";
//            NSString *POSTBody = [NSString stringWithFormat:@"username=%@&password=%@",username,password];
//            request.HTTPBody = [POSTBody dataUsingEncoding:NSUTF8StringEncoding];
//            
//            NSURLSessionTask *loginTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                if (error) {
//                    NSLog(@"loginTask error %@", error);
//                    [delegate wlan:wlan connectResponse:ZQWlanResponseLoginDidFailed error:error];
//                } else {
//                    NSString *htmlContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    ZQWlanResponse response;
//                    if ([htmlContent rangeOfString:@"欢迎你"].location != NSNotFound) {
//                        response = ZQWlanResponseDidLogin;
//                        [MobClick event:@"WLANConnectionSucceed"];
//                    } else if ([htmlContent rangeOfString:@"密码不正确"].location != NSNotFound){
//                        response = ZQWlanResponseWrongPassword;
//                    } else if ([htmlContent rangeOfString:@"不存在"].location != NSNotFound) {
//                        response = ZQWlanResponseInvalidUsername;
//                    } else if ([htmlContent rangeOfString:@"系统繁忙"].location != NSNotFound) {
//                        response = ZQWlanResponseSystemBusy;
//                    } else if ([htmlContent rangeOfString:@"同名无线用户已在线"].location != NSNotFound) {
//                        response = ZQWlanResponseReplicateUserOnWlan;
//                    } else if ([htmlContent rangeOfString:@"帐号已在线"].location != NSNotFound) {
//                        response = ZQWlanResponseReplicateUserOnCERNET;
//                    } else if ([htmlContent rangeOfString:@"包天暂停"].location != NSNotFound) {
//                        response = ZQWlanResponseServiceDidStopManually;
//                    } else if ([htmlContent rangeOfString:@"余额不足"].location != NSNotFound) {
//                        response = ZQWlanResponseOverdue;
//                    } else {
//                        response = ZQWlanResponseLoginDidFailed;
//                        [MobClick event:@"WLANConnectionFailed"];
//                        NSLog(@"%@",htmlContent);
//                    }
//                    [delegate wlan:wlan connectResponse:response error:nil];
//                    
//                }
//            }];
//            
//            NSString *URLString = [NSString stringWithFormat:@"https://wlan.whu.edu.cn/portal?cmd=login&switchip=&mac=&ip=%@&essid=WHU-WLAN&url=",[ZQWlan fetchLoaclIP]];
//            NSURLSessionTask *loadCookieTask = [session dataTaskWithURL:[NSURL URLWithString:URLString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                if (error) {
//                    [delegate wlan:wlan connectResponse:ZQWlanResponseLoginDidFailed error:error];
//                    NSLog(@"WlanResponseLoginDidFailed error %@",error);
//                } else {
//                    [loginTask resume];
//                }
//            }];
//            
//            [delegate wlan:wlan connectResponse:ZQWlanResponseWillLogin error:nil];
//            [loadCookieTask resume];
//        }
//    }];
//    [delegate wlan:wlan connectResponse:ZQWlanResponseWillCheckStatus error:nil];
//    [self checkStatus];
//    return wlan;
//}
//











@end
