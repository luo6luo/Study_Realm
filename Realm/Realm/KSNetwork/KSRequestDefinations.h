//
//  KSRequestDefinations.h
//  KSNetwork
//
//  Created by Kiwi on 2017/8/29.
//  Copyright © 2015 Tags. Inc. All rights reserved.
//

#ifndef KSRequestDefinations_h
#define KSRequestDefinations_h

#import <Foundation/Foundation.h>



#ifdef BuiltForInternalTest
#define KSRequestLogPrint 1
#else
#define KSRequestLogPrint 0
#endif



extern NSString *const KSRequestErrorDomain; // "KSRequestErrorDomain"



typedef NS_ENUM(NSInteger, KSRequestBodyType) {
    KSRequestBodyTypeNone       = 0,
    KSRequestBodyTypeNormal     = 10, // for normal data post, such as "user=name&password=psd"
    KSRequestBodyTypeMultipart  = 20,  // for uploading images and files.
    KSRequestBodyTypeJson       = 30  //
};

typedef NS_ENUM(NSInteger, KSRequestErrorCode) {
    KSRequestErrorNone    = 0,
    KSRequestErrorUknown    = 1,
    KSRequestErrorRequest   = 2,
    KSRequestErrorParse     = 3
};



#endif /* KSRequestDefinations_h */
