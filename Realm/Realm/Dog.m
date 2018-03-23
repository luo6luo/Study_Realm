//
//  Dog.m
//  Realm
//
//  Created by dundun on 2018/3/20.
//  Copyright © 2018年 dundun. All rights reserved.
//

#import "Dog.h"
#import "User.h"

@implementation Dog

// 反向关系
// 在一个人拥有多只狗的情况下(一对多关系),狗没有对应的主人，所以需要设置反向关系
+ (NSDictionary *)linkingObjectsProperties {
    return @{
      @"owners": [RLMPropertyDescriptor descriptorWithClass:User.class propertyName:@"dogs"]
    };
}

@end
