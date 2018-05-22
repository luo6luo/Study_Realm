//
//  KSRequestUtil.h
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#ifndef __cplusplus
@import Foundation;
#endif

@interface NSString (KSRequestUtil)

- (NSString*)KSRequestURLEncodedString;
- (NSString*)KSRequestURLDecodedString;

- (NSData*)KSRequestEncodedData;

@end
