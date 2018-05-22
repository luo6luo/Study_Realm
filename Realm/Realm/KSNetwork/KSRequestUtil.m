//
//  KSRequestUtil.m
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#import "KSRequestUtil.h"

@implementation NSString (KSRequestUtil)

- (NSString*)KSRequestURLEncodedString {
    NSCharacterSet * characterSet = [NSCharacterSet characterSetWithCharactersInString:@"~!@#$%^&*()-+={}\"[]|\\<> \n\t\r"].invertedSet;
//    NSCharacterSet * characterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

- (NSString*)KSRequestURLDecodedString {
    return [self stringByRemovingPercentEncoding];
}

- (NSData*)KSRequestEncodedData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end
