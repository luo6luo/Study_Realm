//
//  User.h
//  Realm
//
//  Created by dundun on 2018/3/20.
//  Copyright © 2018年 dundun. All rights reserved.
//

#import <Realm/Realm.h>
@class Dog;

RLM_ARRAY_TYPE(Dog)

@interface User : RLMObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, assign) NSInteger age;



@property (nonatomic, strong) RLMArray<Dog *><Dog> *dogs;

@end
