//
//  LoginViewController.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//
/*!
    @header ChatLoginView
    @discussion 聊天室登陆页
 */

#import <UIKit/UIKit.h>
#import "Pomelo.h"
/*!
    @class LoingViewController
    @superclass UIViewController
 */
@interface LoginViewController : UIViewController
/**
 *nameText
 */
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
/**
 *channelText
 */
@property (strong, nonatomic) IBOutlet UITextField *channelTextField;
/**
 *login按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
/**
 *Pomelo
 */
@property (strong, nonatomic) Pomelo *pomelo;
@end
