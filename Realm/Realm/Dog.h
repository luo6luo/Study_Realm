//
//  Dog.h
//  Realm
//
//  Created by dundun on 2018/3/20.
//  Copyright © 2018年 dundun. All rights reserved.
//

#import <Realm/Realm.h>
@class User;

@interface Dog : RLMObject

@property (nonatomic, strong) NSString *dogName;
@property (nonatomic, assign) NSInteger dogAge;
@property (nonatomic, strong) NSString *dogColor;

@property (readonly) RLMLinkingObjects *owners;

@end

// 宏协议，表示可以使用 RLMArray<> 类
RLM_ARRAY_TYPE(Dog)
