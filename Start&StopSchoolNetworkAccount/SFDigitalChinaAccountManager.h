//
//  SFDigitalChinaAccountManager.h
//  Start&StopSchoolNetworkAccount
//
//  Created by 孙培峰 on 5/3/14.
//  Copyright (c) 2014 孙培峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFDigitalChinaDelegate <NSObject>



@end

@interface SFDigitalChinaAccountManager : NSObject<NSURLSessionDelegate>

- (void)switchAccountStatusToResumeOrSuspend:(NSString *)resumeOrSuspend;

@end
