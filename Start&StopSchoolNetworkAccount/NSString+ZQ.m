//
//  NSString+ZQ.m
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 1/18/14.
//  Copyright (c) 2014 黄 嘉恒. All rights reserved.
//

#import "NSString+ZQ.h"

@implementation NSString (ZQ)

+ (NSStringEncoding)GBKStringEncoding
{
    return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
}

@end
