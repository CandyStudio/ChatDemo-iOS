//
//  AppDelegate.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pomelo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PomeloDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) Pomelo *pomelo;

@end
