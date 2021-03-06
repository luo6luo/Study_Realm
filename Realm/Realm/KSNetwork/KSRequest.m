//
//  KSRequest.m
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#import "KSRequest.h"
#import "KSRequestUtil.h"

#define KSRequestTimeOutInterval   30.0
#define KSRequestStringBoundary    @"0x912913kiwi43764376x0"

NSString * const KSRequestErrorDomain = @"KSRequestErrorDomain";

@interface KSRequest () <NSURLSessionDelegate> {
    NSURLSessionResponseDisposition _responseDisposition;
    NSMutableData * _responseData;
    long long _dataSize;
    long long _loadedSize;
}

@property (strong, nonatomic) NSURLSessionDataTask * sessionDataTask;

@end

@implementation KSRequest

#pragma mark
#pragma mark - Public Static Methods

+ (KSRequest*)requestWithURL:(NSString *)url
                  httpMethod:(NSString *)httpMethod
                  paramaters:(NSDictionary *)paramaters
                    bodyType:(KSRequestBodyType)bodyType
            httpHeaderFields:(NSDictionary *)httpHeaderFields
                    delegate:(id<KSRequestDelegate>)delegate {
    return [[KSRequest alloc] initWithURL:url httpMethod:httpMethod paramaters:paramaters bodyType:bodyType httpHeaderFields:httpHeaderFields delegate:delegate];
}


#pragma mark
#pragma mark - Private Static Methods

+ (NSString *)queryParamatersStringFromDictionary:(NSDictionary *)dict encoded:(BOOL)encoded {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [dict keyEnumerator]) {
        NSString * val = [dict valueForKey:key];
        if (!([val isKindOfClass:[NSString class]])) {
            if ([val isKindOfClass:[NSNumber class]]) {
                val = [(NSNumber*)val stringValue];
            } else continue;
        }
        
        if (encoded) val = [val KSRequestURLEncodedString];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, val]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendDataToBody:(NSMutableData *)body dataString:(NSString *)dataString {
    [body appendData:[dataString KSRequestEncodedData]];
}


#pragma mark
#pragma mark - Public Methods

- (instancetype)initWithURL:(NSString *)url
                 httpMethod:(NSString *)httpMethod
                 paramaters:(NSDictionary *)paramaters
                   bodyType:(KSRequestBodyType)bodyType
           httpHeaderFields:(NSDictionary *)httpHeaderFields
                   delegate:(id<KSRequestDelegate>)delegate {
    if (self = [super init]) {
        // Initialization Code
        self.url = url;
        self.httpMethod = httpMethod;
        self.paramaters = paramaters;
        self.bodyType = bodyType;
        self.httpHeaderFields = httpHeaderFields;
        self.delegate = delegate;
    }
    return self;
}

- (void)connect {
    // prepare request URL
    NSMutableString * urlString = [NSMutableString stringWithString:self.url];
    if (self.bodyType == KSRequestBodyTypeNone) {
        // append all paramaters to URL
        if (self.paramaters.count > 0) {
            // append '?' if url doesn't contain any parameters,
            // otherwise append '&'
            if ([urlString containsString:@"?"]) [urlString appendString:@"&"];
            else [urlString appendString:@"?"];
            // append extra parameters from dictionary
            [urlString appendString:[[self class] queryParamatersStringFromDictionary:self.paramaters encoded:YES]];
        }
    }
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                        timeoutInterval:KSRequestTimeOutInterval];
    [request setHTTPMethod:self.httpMethod];
    
    // add http body if needed
    if (self.bodyType != KSRequestBodyTypeNone) {
        if (self.bodyType == KSRequestBodyTypeNormal) {
            NSString * contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=UTF-8"];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        } else if (self.bodyType == KSRequestBodyTypeMultipart) {
            NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", KSRequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        } else if (self.bodyType == KSRequestBodyTypeJson) {
            NSString * contentType = [NSString stringWithFormat:@"application/json; charset=UTF-8"];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        NSData * postBody = [self postBody];
        NSTimeInterval timeinterval = KSRequestTimeOutInterval + ([postBody length]>>14);
        [request setTimeoutInterval:timeinterval];
        [request setHTTPBody:postBody];
    } else {
#ifdef DEBUG
#if KSRequestLogPrint
        // should add log for DEBUG
        // Http Get
        NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http Get Start:"];
        [logString appendFormat:@"\nURL: %@", urlString];
        if (self.httpHeaderFields.count > 0) {
            [logString appendFormat:@"\nHeader Fields: %@", [[self class] queryParamatersStringFromDictionary:self.httpHeaderFields encoded:NO]];
        }
        NSLog(@"%@", logString);
#endif
#endif
    }
    
    // add http header fields
    for (NSString *key in [_httpHeaderFields keyEnumerator]) {
        [request setValue:[_httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    // prepare values
    _responseDisposition = NSURLSessionResponseAllow;
    
    // start task
    NSURLSessionConfiguration * sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfig.requestCachePolicy = request.cachePolicy;
    sessionConfig.timeoutIntervalForRequest = request.timeoutInterval;
    sessionConfig.timeoutIntervalForResource = request.timeoutInterval;
    NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.sessionDataTask = [session dataTaskWithRequest:request];
    [self.sessionDataTask resume];
}

- (void)disconnect {
    if (self.sessionDataTask) {
        [self.sessionDataTask cancel]; self.sessionDataTask = nil;
    }
    _responseData = nil;
    _delegate = nil;
    _responseDisposition = NSURLSessionResponseCancel;
}


#pragma mark
#pragma mark - Private Methods

- (NSMutableData *)postBody {
    NSMutableData * body = [NSMutableData data];
    if (self.bodyType == KSRequestBodyTypeNormal) {
        // should generate normal body
        [[self class] appendDataToBody:body dataString:[[self class] queryParamatersStringFromDictionary:self.paramaters encoded:YES]];
        
#ifdef DEBUG
#if KSRequestLogPrint
        // should add log for DEBUG
        // Http Post
        NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http POST Start:"];
        [logString appendFormat:@"\nURL: %@", self.url];
        if (self.httpHeaderFields.count > 0) {
            [logString appendFormat:@"\nHeader Fields: %@", [[self class] queryParamatersStringFromDictionary:self.httpHeaderFields encoded:NO]];
        }
        if (self.paramaters.count > 0) {
            [logString appendFormat:@"\nParamaters:"];
            for (id key in [self.paramaters keyEnumerator]) {
                id obj = [self.paramaters valueForKey:key];
                if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                    [logString appendFormat:@"\n[Text] %@: %@", key, obj];
                }
            }
        }
        NSLog(@"%@", logString);
#endif
#endif
        
    } else if (self.bodyType == KSRequestBodyTypeMultipart) {
        // should generate multipart body
        NSString * bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", KSRequestStringBoundary];
        NSString * bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", KSRequestStringBoundary];
        // add body prefix
        [[self class] appendDataToBody:body dataString:bodyPrefixString];
        
        // add string paramaters to body and insert other kinds to one dictionary
        NSMutableDictionary * dataDictionary = [NSMutableDictionary dictionary];
        for (id key in [self.paramaters keyEnumerator]) {
            id obj = [self.paramaters valueForKey:key];
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [[self class] appendDataToBody:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, obj]];
                [[self class] appendDataToBody:body dataString:bodyPrefixString];
                continue;
            }
            [dataDictionary setObject:obj forKey:key];
        }
        
        // add other kinds of paramaters
        if (dataDictionary.count > 0) {
            NSString * dataBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", KSRequestStringBoundary];
            for (id key in [dataDictionary keyEnumerator]) {
                NSData * obj = [dataDictionary valueForKey:key];
                if ([obj isKindOfClass:[NSData class]]) {
                    NSString * contentType = @"application/octet-stream";
                    NSString * filename = @"file";
                    /*
                    uint8_t c;
                    [obj getBytes:&c length:1];
                    switch (c) {
                        case 0xFF: {
                            contentType = @"image/jpeg";
                            filename = @"file.jpeg";
                        }
                        case 0x89: {
                            contentType = @"image/png";
                            filename = @"file.png";
                        }
                        case 0x47: {
                            contentType = @"image/gif";
                            filename = @"file.gif";
                        }
                        default: {
                            contentType = @"audio/mp3";
                            filename = @"file.mp3";
                        }
                    }*/
                    
                    [[self class] appendDataToBody:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename]];
                    [[self class] appendDataToBody:body dataString:[NSString stringWithFormat:@"Content-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n", contentType]];
                    [body appendData:(NSData*)obj];
                    [[self class] appendDataToBody:body dataString:dataBoundary];
                }
            }
        }
        [[self class] appendDataToBody:body dataString:bodySuffixString];
        
#ifdef DEBUG
#if KSRequestLogPrint
        // should add log for DEBUG
        // Http Post Multipart
        NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http POST Start:"];
        [logString appendFormat:@"\nURL: %@", self.url];
        if (self.httpHeaderFields.count > 0) {
            [logString appendFormat:@"\nHeader Fields: %@", [[self class] queryParamatersStringFromDictionary:self.httpHeaderFields encoded:NO]];
        }
        if (self.paramaters.count > 0) {
            [logString appendFormat:@"\nParamaters:"];
            for (id key in [self.paramaters keyEnumerator]) {
                id obj = [self.paramaters valueForKey:key];
                if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                    [logString appendFormat:@"\n[Text] %@: %@", key, obj];
                } else if ([obj isKindOfClass:[NSData class]]) {
                    [logString appendFormat:@"\n[Data] %@: %td bytes", key, ((NSData*)obj).length];
                }
            }
        }
        NSLog(@"%@", logString);
#endif
#endif
        
    } else if (self.bodyType == KSRequestBodyTypeJson) {
        // should generate json body
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.paramaters options:0 error:&error];
        [body appendData:jsonData];
        
        /*
         char * buffers = malloc(sizeof(char)* jsonData.length);
         [jsonData getBytes:buffers length:jsonData.length];
         
         NSMutableString * bufferStr = [NSMutableString stringWithFormat:@"buffer string begin\n"];
         for (int i = 0; i < jsonData.length; i ++) {
         [bufferStr appendFormat:@"%x\n", buffers[i]];
         }
         NSLog(@"%@", bufferStr);
         
         free(buffers);
         */
        
#ifdef DEBUG
#if KSRequestLogPrint
        // should add log for DEBUG
        // Http Post Json
        NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http POST Start:"];
        [logString appendFormat:@"\nURL: %@", self.url];
        if (self.httpHeaderFields.count > 0) {
            [logString appendFormat:@"\nHeader Fields: %@", [[self class] queryParamatersStringFromDictionary:self.httpHeaderFields encoded:NO]];
        }
        if (self.paramaters.count > 0) {
            [logString appendFormat:@"\nParamaters:\n"];
            [logString appendString:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        }
        NSLog(@"%@", logString);
#endif
#endif
        
    }
    return body;
}



#pragma mark
#pragma mark - Delegate Callbacks

#pragma mark - NSURLSessionDelegate

// session become invalid
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    // do nothing
}

#pragma mark - NSURLSessionTaskDelegate

// session sending data
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if ([self.delegate respondsToSelector:@selector(ksRequest:didSendPercent:)]) {
        float current = (float)totalBytesSent;
        float total = (float)totalBytesExpectedToSend;
        [self.delegate ksRequest:self didSendPercent:current / total * 100.0f];
    }
}

// session end
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
            // task cancelled
            if ([self.delegate respondsToSelector:@selector(ksRequest:didCancelWithError:)]) {
                [self.delegate ksRequest:self didCancelWithError:nil];
            }
            
#ifdef DEBUG
#if KSRequestLogPrint
            // should add log for DEBUG
            NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http Cancelled:"];
            [logString appendFormat:@"\nURL: %@", self.url];
            NSLog(@"%@", logString);
#endif
#endif
            
        } else {
            // end with other kinds of error
            [self.delegate ksRequest:self didFailWithError:error];
            
#ifdef DEBUG
#if KSRequestLogPrint
            // should add log for DEBUG
            NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http End With Error:"];
            [logString appendFormat:@"\nURL: %@", self.url];
            [logString appendFormat:@"\nError: %@", error.description];
            NSLog(@"%@", logString);
#endif
#endif
            
        }
    } else {
        // task complete
        [self.delegate ksRequest:self didFinishLoadingWithResult:_responseData];
        
#ifdef DEBUG
#if KSRequestLogPrint
        // should add log for DEBUG
        NSMutableString * logString = [NSMutableString stringWithString:@"[KSNetwork] Http End:"];
        [logString appendFormat:@"\nURL: %@", self.url];
        [logString appendFormat:@"\nReceived Data:\n"];
        
        // append reveived data
        NSString * reveivedDataString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        if ([reveivedDataString isKindOfClass:[NSString class]]) {
            [logString appendString:reveivedDataString];
        } else {
            [logString appendFormat:@"Data Size: %td", _responseData.length];
        }
        NSLog(@"%@", logString);
#endif
#endif
        
    }
    _responseData = nil;
    [session finishTasksAndInvalidate];
}

#pragma mark - NSURLSessionDataDelegate

// session responses
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    _responseData = [[NSMutableData alloc] init];
    _loadedSize = 0;
    if ([self.delegate respondsToSelector:@selector(ksRequest:didReceiveResponse:)]) {
        [self.delegate ksRequest:self didReceiveResponse:response];
    }
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary * httpResponseHeaderFields = [httpResponse allHeaderFields];
        _dataSize = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    }
    if ([self.delegate respondsToSelector:@selector(ksRequest:didReceivePercent:)]) {
        [self.delegate ksRequest:self didReceivePercent:0];
    }
    completionHandler(_responseDisposition);
}

// session receive data
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    _loadedSize += data.length;
    if (_dataSize > 0 && [self.delegate respondsToSelector:@selector(ksRequest:didReceivePercent:)]) {
        float current = (float)_loadedSize;
        float total = (float)_dataSize;
        [self.delegate ksRequest:self didReceivePercent:current / total * 100.0f];
    }
}

@end
