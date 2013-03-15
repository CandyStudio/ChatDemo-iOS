//
//  UserDataManage.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-14.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserData;

@interface UserDataManager : NSObject

@property (strong, nonatomic) UserData *user;

+ (UserDataManager *)sharedUserDataManager;
@end
