//
//  NSURLResponse+ZQ.m
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 1/3/14.
//  Copyright (c) 2014 黄 嘉恒. All rights reserved.
//

#import "NSURLResponse+ZQ.h"

@implementation NSURLResponse (ZQ)

- (NSStringEncoding)stringEncoding
{
    NSStringEncoding encodingType = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[self textEncodingName]));
    return encodingType;
}
@end
