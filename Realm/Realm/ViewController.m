//
//  ViewController.m
//  Realm
//
//  Created by dundun on 2018/3/13.
//  Copyright © 2018年 dundun. All rights reserved.
//
//
//  官网中文文档 - https://realm.io/cn/docs/objc/latest/#many-to-many
//

#import "ViewController.h"
#import "Dog.h"
#import "User.h"
#import "Cat.h"
#import <Realm/Realm.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 需要存储的自定义模型，需要继承 RLMObject
    User *user = [[User alloc] init];
    user.name = @"主人";
    user.sex = @"女";
    user.age = 20;
    
    // 创建数据库，此时初始化的是默认数据库
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSError *error = nil;
    __weak typeof(realm) weakRealm = realm;
    [realm transactionWithBlock:^{
        [weakRealm addObject: user];
    } error:&error];
    
    // 配置数据库
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"user.realm"];
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.fileURL = [NSURL URLWithString:filePath];
    NSLog(@"%@",configuration.fileURL);
    

//    // 一对一绑定
//    Cat *cat = [[Cat alloc] init];
//    cat.user = user;
//
//    // 一对多绑定，绑定多个话，需要加入RLM_ARRAY_TYPE宏定义协议，才能实现RLMArray类调用
//    Dog *dog1 = [[Dog alloc] init];
//    Dog *dog2 = [[Dog alloc] init];
//    [user.dogs addObject:dog1];
//    [user.dogs addObject:dog2];
//
//    // Realm中涉及的 insert，delete，update都必须在一个write事务中执行。
//    NSError *error = nil;
//    [realm transactionWithBlock:^{
//        // insert, delete, update操作
//        [realm addObject:cat];
//    } error:&error];
//
//    // 查询操作，不是拷贝，如果对查询结果（在写入事务中）进行修改，会直接修改磁盘数据
//    // 查询Realm中所有的狗
//    RLMResults<Dog *> *dogs = [Dog allObjects];
//    // 使用断言字符串查询
//    RLMResults<Dog *> *tanDogs = [Dog objectsWhere:@"dogColor = '黄白'"];
//    // 使用 NSPredicate 查询
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"dogColor = '黄白'"];
//    tanDogs = [Dog objectsWithPredicate:pred];
    
}


@end
