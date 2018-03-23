//
//  Cat.h
//  Realm
//
//  Created by dundun on 2018/3/20.
//  Copyright © 2018年 dundun. All rights reserved.
//

#import <Realm/Realm.h>
@class User;

@interface Cat : RLMObject

@property (nonatomic, strong) NSString *catName;
@property (nonatomic, assign) NSInteger catAge;

@property (nonatomic, strong) User *user;

@end
