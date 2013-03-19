//
//  UserData.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-14.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject

@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *role;
@property (nonatomic, copy) NSString *userpassword;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSDictionary *resultDict;

- (UserData *)initWithDic:(NSDictionary *)dic;
@end
