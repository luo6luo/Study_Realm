//
//  KSRequest.h
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#import "KSRequestDefinations.h"

#ifndef __cplusplus
@import Foundation;
#endif

@class KSRequest;

@protocol KSRequestDelegate <NSObject>
@required
- (void)ksRequest:(KSRequest*)request didCancelWithError:(NSError *)error;
- (void)ksRequest:(KSRequest*)request didFailWithError:(NSError *)error;
- (void)ksRequest:(KSRequest*)request didFinishLoadingWithResult:(id)result;
@optional
- (void)ksRequest:(KSRequest*)request didReceiveResponse:(NSURLResponse *)response;
- (void)ksRequest:(KSRequest*)request didSendPercent:(float)percent;
- (void)ksRequest:(KSRequest*)request didReceivePercent:(float)percent;
@end

@interface KSRequest : NSObject

@property (unsafe_unretained, nonatomic) id <KSRequestDelegate> delegate;
@property (assign, nonatomic) KSRequestBodyType bodyType;
@property (copy, nonatomic) NSString     * url;
@property (copy, nonatomic) NSString     * httpMethod;
@property (copy, nonatomic) NSDictionary * paramaters;
@property (copy, nonatomic) NSDictionary * httpHeaderFields;

+ (KSRequest*)requestWithURL:(NSString *)url
                  httpMethod:(NSString *)httpMethod
                  paramaters:(NSDictionary *)paramaters
                    bodyType:(KSRequestBodyType)bodyType
            httpHeaderFields:(NSDictionary *)httpHeaderFields
                    delegate:(id<KSRequestDelegate>)delegate;

- (void)connect;
- (void)disconnect;

@end
