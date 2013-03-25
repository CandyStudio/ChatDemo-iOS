//
//  UserData.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-14.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//
//0.1版本的 所有村本地数据都不用base64
#import "UserData.h"

@implementation UserData

- (UserData *)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.userid = [dic objectForKey:@"userid"];
        self.role = [dic objectForKey:@"role"];
        self.username = [dic objectForKey:@"username"];
        self.userpassword = [dic objectForKey:@"password"];
        self.resultDict = dic;
        self.userToken = [dic objectForKey:@"token"];
        self.userRole = UserRoleGuest;
    }
    return self;
}

@end
