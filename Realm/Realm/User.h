//
//  User.h
//  Realm
//
//  Created by dundun on 2018/3/20.
//  Copyright © 2018年 dundun. All rights reserved.
//

#import <Realm/Realm.h>
@class Dog;
@class Cat;

RLM_ARRAY_TYPE(Dog)

@interface User : RLMObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, assign) NSInteger age;

// 一对一关系，一个user对应一个cat
@property Cat *cat;

// 一对多关系，一个user对应多个dog
@property RLMArray<Dog *><Dog> *dogs;

@end
