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

@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) User *user;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置本地默认realm
//    [self setupLocalDefaultRealm];
//    // 设置本地默认配置下的realm
//    [self setupLocalRealmWithDefaultConfiguration];
    // 设置本地自定义配置下的realm
    [self setupLocalRealmWithCustomConfiguration];
    
    // 添加数据
//    [self addModel];
    // 删除数据
//    [self deleteModel];
    // 修改数据
    [self modifyModel];
    
    
//
//    // 同步Realm数据库
//    RLMSyncUser *syncUser = [RLMSyncUser currentUser];
//    // 创建配置
//    NSURL *syncServerURL = [NSURL URLWithString:@"http://192.168.1.92/"];
//    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
//    config.syncConfiguration = [[RLMSyncConfiguration alloc] initWithUser:syncUser realmURL:syncServerURL];
//    // 打开远程realm数据库
//    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:nil];

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

# pragma mark - Getter

- (User *)user
{
    if (!_user) {
        _user = [self setupUserModel];
    }
    return _user;
}

# pragma mark - Set up model

/*
 (1)需要存储的自定义模型，需要继承 RLMObject 类
 (2)Dog 中设置了反向关系
 
 创建对象方法：
 （1）指定初始化函数来创建。
 （2）通过恰当的键值，通过字典来创建。
 （3）通过数组来完成实例化，数组中的值必须和模型中的属性次序一致。
*/

// 设置狗模型数据，通过指定初始化函数创建
- (Dog *)setupDogModelWithName:(NSString *)dogName
{
    Dog *dog = [[Dog alloc] init];
    dog.dogName = dogName;
    dog.dogAge = 2;
    dog.dogColor = @"白色";
    
    return dog;
}

// 设置猫数据模型，通过字典创建
- (Cat *)setupCatModelWithName:(NSString *)catName
{
    Cat *cat = [[Cat alloc] initWithValue:@{@"catName": catName, @"catAge": @(3)}];
    return cat;
}

// 设置人模型数据，通过数组创建
- (User *)setupUserModel
{
    Cat *cat = [self setupCatModelWithName:@"肥妞"];
    Dog *dog1 = [self setupDogModelWithName:@"默默"];
    Dog *dog2 = [self setupDogModelWithName:@"裤衩儿"];
    User *user = [[User alloc] initWithValue:@[@"主人", @"女", @(20), cat, @[dog1, dog2]]];
    return user;
}

# pragma mark - Set up local realm

// 设置本地默认realm
- (void)setupLocalDefaultRealm
{
    // 直接创建数据库，此时初始化的是默认数据库，每个线程只需执行一次
    // 默认数据库的路径是 Documents 下
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSLog(@"原始路径：%@",realm.configuration.fileURL);
}

// 根据默认配置项创建数据库
- (void)setupLocalRealmWithDefaultConfiguration
{
    // 默认配置（Documents）
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    // 使用默认目录，将文件名替换为用户名
    configuration.fileURL = [[[configuration.fileURL URLByDeletingLastPathComponent]
                              URLByAppendingPathComponent:@"user"]
                             URLByAppendingPathExtension:@"realm"];
    // 根据该配置创建数据库
    [RLMRealmConfiguration setDefaultConfiguration:configuration];
    [RLMRealm realmWithConfiguration:configuration error:nil];
    NSLog(@"%@",configuration.fileURL);
}

// 根据自定义配置项创建数据库
- (void)setupLocalRealmWithCustomConfiguration
{
    // 设置 realm 储存路径
    RLMRealmConfiguration *configuration = [[RLMRealmConfiguration alloc] init];
    NSString *path = @"/Users/dundun/Desktop/Study_Realm/UserRealm/";
    NSString *filePath = [path stringByAppendingString:@"user.realm"];
    configuration.fileURL = [[NSURL alloc] initWithString:filePath];
    
    // 根据该配置创建数据库
    [RLMRealmConfiguration setDefaultConfiguration:configuration];
    self.realm = [RLMRealm realmWithConfiguration:configuration error:nil];
}

# pragma mark - Add & Delete & Modify

- (void)addModel
{
    // 在事务中添加数据
    [self.realm beginWriteTransaction];
    [self.realm addObject:self.user];
    [self.realm commitWriteTransaction];
}

- (void)deleteModel
{
    // 在事务中删除数据
    [self.realm beginWriteTransaction];
    [self.realm deleteObject:self.user];
    [self.realm commitWriteTransaction];
}

- (void)modifyModel
{
    // 修改数据
    [self.realm beginWriteTransaction];
    self.user.name = @"美女";
    [self.realm commitWriteTransaction];
}

@end
