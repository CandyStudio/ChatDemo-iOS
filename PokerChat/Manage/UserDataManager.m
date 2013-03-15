//
//  UserDataManage.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-14.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "UserDataManager.h"

@implementation UserDataManager

//单利
+ (UserDataManager *)sharedUserDataManager{
    static dispatch_once_t onceToken = 0;
    __strong static UserDataManager *_sharedUserDataManager = nil;
    dispatch_once(&onceToken, ^{
        _sharedUserDataManager = [[self alloc] init];
    });
    return _sharedUserDataManager;
}

@end
