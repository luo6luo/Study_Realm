//
//  KSClient.m
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSClient.h"
#import "KSRequest.h"

typedef void(^KSClientCompleteSuccessBlock) (id resultDictionary);
typedef void(^KSClientCompleteFailureBlock) (KSClient * errorClient);

@interface KSClient () <KSRequestDelegate> {
    BOOL _cancelled;
}

@property (strong, nonatomic) KSRequest * request;
@property (copy, nonatomic) KSClientCompleteSuccessBlock successBlock;
@property (copy, nonatomic) KSClientCompleteFailureBlock failureBlock;
@property (assign, nonatomic) BOOL preparedToComplete;

+ (NSMutableArray*)sharedClients;

@end

@implementation KSClient

+ (NSMutableArray*)sharedClients {
    static NSMutableArray * sharedClients = nil;
    if (sharedClients == nil) {
        sharedClients = [[NSMutableArray alloc] init];
    }
    return sharedClients;
}

+ (void)cancelOperationsForController:(id)controller {
    NSMutableArray * operations = [self sharedClients];
    NSInteger index = 0;
    while (index < operations.count) {
        KSClient * client = [operations objectAtIndex:index];
        if (client.controller == controller) {
            [client cancel];
        } else {
            index ++;
        }
    }
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        _cancelled = NO;
//        _hasError = YES;
        _workWithNoRespond = NO;
        self.error = nil;
        self.needAlert = YES;
        self.parsedAsJSON = YES;
        self.needLoadingHUD = YES;
        self.preparedToComplete = NO;
    }
    return self;
}

- (instancetype)initWithComplete:(void(^) (id resultDictionary))successBlock failure:(void(^) (KSClient * errorClient))failureBlock {
    return [self initWithComplete:successBlock failure:failureBlock controller:nil];
}

- (instancetype)initWithComplete:(void(^) (id resultDictionary))successBlock failure:(void(^) (KSClient * errorClient))failureBlock controller:(id)controller {
    if (self = [super init]) {
        if (successBlock) self.successBlock = successBlock;
        if (failureBlock) self.failureBlock = failureBlock;
        self.controller = controller;
        _cancelled = NO;
//        _hasError = YES;
        _workWithNoRespond = NO;
        self.error = nil;
        self.needAlert = YES;
        self.parsedAsJSON = YES;
        self.needLoadingHUD = YES;
        self.preparedToComplete = NO;
    }
    return self;
}

//- (void)dealloc {
//    NSLog(@"dealloc request = %@", _request.url);
//}

- (void)cancel {
    if (self.preparedToComplete) return;
    self.preparedToComplete = YES;
    if (!_cancelled) {
        _cancelled = YES;
        self.delegate = nil;
        [self.request disconnect];
        [self loadingComplete];
    }
}

- (void)showAlert {
    // to be implemented in sub-classes
}

- (KSRequestBodyType)postDataTypeWithParameters:(NSDictionary*)params {
    KSRequestBodyType type = KSRequestBodyTypeNormal;
    for (id param in params.allValues) {
        if ([param isKindOfClass:[NSData class]]) {
            type = KSRequestBodyTypeMultipart;
            break;
        } else if ([param isKindOfClass:[NSDictionary class]] || [param isKindOfClass:[NSArray class]]) {
            type = KSRequestBodyTypeJson;
            break;
        }
    }
    return type;
}

- (void)getWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    [self loadRequestWithMethodName:methodName httpMethod:@"GET" paramaters:paramaters bodyType:KSRequestBodyTypeNone httpHeaderFields:nil];
}
- (void)postWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    KSRequestBodyType type = [self postDataTypeWithParameters:paramaters];
    [self loadRequestWithMethodName:methodName httpMethod:@"POST" paramaters:paramaters bodyType:type httpHeaderFields:nil];
}
- (void)putWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    KSRequestBodyType type = [self postDataTypeWithParameters:paramaters];
    [self loadRequestWithMethodName:methodName httpMethod:@"PUT" paramaters:paramaters bodyType:type httpHeaderFields:nil];
}
- (void)deleteWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    KSRequestBodyType type = [self postDataTypeWithParameters:paramaters];
    [self loadRequestWithMethodName:methodName httpMethod:@"DELETE" paramaters:paramaters bodyType:type httpHeaderFields:nil];
}
- (void)jsonPostWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    [self loadRequestWithMethodName:methodName httpMethod:@"POST" paramaters:paramaters bodyType:KSRequestBodyTypeJson httpHeaderFields:nil];
}
- (void)jsonPutWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    [self loadRequestWithMethodName:methodName httpMethod:@"PUT" paramaters:paramaters bodyType:KSRequestBodyTypeJson httpHeaderFields:nil];
}
- (void)jsonDeleteWithMethodName:(NSString *)methodName params:(NSMutableDictionary *)paramaters {
    [self loadRequestWithMethodName:methodName httpMethod:@"DELETE" paramaters:paramaters bodyType:KSRequestBodyTypeJson httpHeaderFields:nil];
}
- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                       paramaters:(NSMutableDictionary *)paramaters
                         bodyType:(KSRequestBodyType)bodyType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields {
    [_request disconnect];
    
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionaryWithDictionary:paramaters];
    NSMutableDictionary * headerFields = [NSMutableDictionary dictionaryWithDictionary:httpHeaderFields];
    id delegate = self;
    self.request = [KSRequest requestWithURL:methodName
                                  httpMethod:httpMethod
                                  paramaters:paramsDic
                                    bodyType:bodyType
                            httpHeaderFields:headerFields
                                    delegate:delegate];
    [self.request connect];
    [[[self class] sharedClients] addObject:self];
    if (_needLoadingHUD) [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (id)parseResultWithData:(NSData*)data {
    // should be implemented in sub-class
    if (self.parsedAsJSON) {
        // should parse as JSON
        NSError * error = nil;
        id result = [self parseJSONData:data error:&error];
        if (error) {
//            _hasError = YES;
//            self.errorCode = error.code;
//            self.errorMessage = [error localizedDescription];
            self.error = error;
        }
        return result;
    }
    return data;
}

- (void)loadingComplete {
    if (_needLoadingHUD) {
        NSArray * clientsAll = [[self class] sharedClients];
        NSMutableArray * clientsStillNeedHUD = [NSMutableArray arrayWithCapacity:clientsAll.count];
        for (KSClient * client in clientsAll) {
            if (client.needLoadingHUD && client != self) [clientsStillNeedHUD addObject:client];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = clientsStillNeedHUD.count > 0;
    }
    [[[self class] sharedClients] removeObject:self];
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error {
    NSError * parseError = nil;
    id result = nil;
    if ([data isKindOfClass:[NSData class]] && data.length > 0) {
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
    }
    
    if (!([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSArray class]])) {
        if (error != nil) {
            * error = [self errorWithCode:KSRequestErrorParse
                                 userInfo:@{NSLocalizedDescriptionKey:@"invalid json data",
                                            NSLocalizedFailureReasonErrorKey:@"invalid json data"}];
        }
    }
    
    return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:KSRequestErrorDomain code:code userInfo:userInfo];
}

#pragma mark
#pragma mark - KSRequestDelegate
- (void)ksRequest:(KSRequest*)request didCancelWithError:(NSError *)error {
    // do nothing
}
- (void)ksRequest:(KSRequest*)request didFailWithError:(NSError *)error {
    if (_cancelled || _workWithNoRespond) {
        // do nothing
    } else {
//        self.errorCode = error.code;
//        NSString * errorStr = [NSString stringWithFormat:@"%@", [error localizedDescription]];
//        if (!([errorStr isKindOfClass:[NSString class]] && errorStr.length > 0)) {
//            errorStr = [NSString stringWithFormat:@"%@", [[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
//        }
//        if (!([errorStr isKindOfClass:[NSString class]] && errorStr.length > 0) || error.code == -1003) {
//            errorStr = @"DNS error, please try again later";
//        }
//        self.errorMessage = errorStr;
        self.error = error;
        if (self.delegate && [self.delegate respondsToSelector:@selector(client:didFinishLoadingWithResult:)]) {
            [self.delegate client:self didFinishLoadingWithResult:error];
        } else {
            __weak __typeof(self) weakSelf = self;
            KSClientCompleteFailureBlock handler = self.failureBlock;
            @autoreleasepool {
                if (handler) {
                    [weakSelf showAlert];
                    handler(weakSelf);
                }
            }
        }
    }
    [self loadingComplete];
}
- (void)ksRequest:(KSRequest*)request didFinishLoadingWithResult:(id)resultData {
    if (_cancelled || _workWithNoRespond) {
        // do nothing
    } else {
        // parse data
//        _hasError = NO;
        id result = [self parseResultWithData:resultData];
        
        // callbacks
        if (self.delegate && [self.delegate respondsToSelector:@selector(client:didFinishLoadingWithResult:)]) {
            [self.delegate client:self didFinishLoadingWithResult:result];
        } else {
            __weak __typeof(self) weakSelf = self;
            if (self.error) {
                KSClientCompleteFailureBlock handler = self.failureBlock;
                @autoreleasepool {
                    if (handler) {
                        [weakSelf showAlert];
                        handler(weakSelf);
                    }
                }
            } else {
                KSClientCompleteSuccessBlock handler = self.successBlock;
                @autoreleasepool {
                    if (handler) {
                        handler(result);
                    }
                }
            }
        }
    }
    [self loadingComplete];
}
- (void)ksRequest:(KSRequest*)request didReceiveResponse:(NSURLResponse *)response {
    // do nothing
}
- (void)ksRequest:(KSRequest*)request didSendPercent:(float)percent {
    if ([self.delegate respondsToSelector:@selector(client:didSendPercent:)]) [self.delegate client:self didSendPercent:percent];
}
- (void)ksRequest:(KSRequest*)request didReceivePercent:(float)percent {
    if ([self.delegate respondsToSelector:@selector(client:didReceivePercent:)]) [self.delegate client:self didReceivePercent:percent];
}

@end
