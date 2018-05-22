//
//  KSClient.h
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#import "KSRequestDefinations.h"

#ifndef __cplusplus
@import Foundation;
#endif

@class KSClient;

@protocol KSClientDelegate <NSObject>
@required
// callback method
- (BOOL)client:(KSClient*)sender didFinishLoadingWithResult:(id)result;
@optional
// callback while sending data
- (void)client:(KSClient*)sender didSendPercent:(float)percent;
// callback while receiving data
- (void)client:(KSClient*)sender didReceivePercent:(float)percent;
@end



@interface KSClient : NSObject {
    // if YES the request may not call back when completed, the default value is NO
    BOOL _workWithNoRespond;
}

// object that respond while request is completed
@property (unsafe_unretained, nonatomic) id <KSClientDelegate> delegate;

// error
@property (strong, nonatomic) NSError * error;

// identifier for different kinds of requests in one object
@property (assign, nonatomic) NSInteger   requestID;

// YES if this request need the loading HUD
@property (assign, nonatomic) BOOL        needLoadingHUD;
// if NO the request may ignore errors without alerts, the default value is YES
@property (assign, nonatomic) BOOL        needAlert;
// if YES the result would be parsed as json, the default value is YES
@property (assign, nonatomic) BOOL        parsedAsJSON;

// client should cancel while controller dealloc
@property (unsafe_unretained, nonatomic) id controller;

+ (void)cancelOperationsForController:(id)controller;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	初始化EHClient实例
 *
 *	@param 	delegate 回调对象实例
 *
 *	@return	return a BSClient object
 */
- (instancetype)initWithDelegate:(id)delegate;

- (instancetype)initWithComplete:(void(^) (id resultDictionary))successBlock failure:(void(^) (KSClient * errorClient))failureBlock;

- (instancetype)initWithComplete:(void(^) (id resultDictionary))successBlock failure:(void(^) (KSClient * errorClient))failureBlock controller:(id)controller;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	中断并取消请求
 */
- (void)cancel;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	doing nothing
 *  should be implemented in sub-classes
 */
- (void)showAlert;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	发送GET请求
 *
 *	@param 	methodName URL后缀
 *	@param 	params     a dictionary with all parameters (NSNumber, NSString)
 */
- (void)getWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)params;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	load a http request type as POST
 *
 *	@param 	methodName URL后缀
 *	@param 	params     a dictionary with all parameters (NSNumber, NSString, UIImage, NSData)
 */
- (void)postWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)params;
- (void)putWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)params;
- (void)deleteWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)params;
- (void)jsonPostWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters;
- (void)jsonPutWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters;
- (void)jsonDeleteWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	load a http request
 *
 *	@param 	methodName URL
 *	@param 	httpMethod @"GET" or @"POST"
 *	@param 	paramaters a dictionary with all parameters (NSNumber, NSString, NSData)
 *	@param 	bodyType http body
 *	@param 	httpHeaderFields http header fields
 */
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                       paramaters:(NSMutableDictionary *)paramaters
                         bodyType:(KSRequestBodyType)bodyType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields;

/**
 *	Copyright © 2015 Tags. Inc. All rights reserved.
 *
 *	默认以 JSON 格式解析返回数据
 */
- (id)parseResultWithData:(NSData*)data;

@end
