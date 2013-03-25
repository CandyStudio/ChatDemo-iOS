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

#import "RegisterView.h"
/*!
    @class LoingViewController
    @superclass UIViewController
 */
@interface LoginViewController : UIViewController<RegisterViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>
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

/**
 *register Button
 */
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

/**
 *guest Button
 */
@property (weak, nonatomic) IBOutlet UIButton *guestButton;

@property (weak, nonatomic) IBOutlet UISwitch *nameSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *passwordSwitch;

@property (strong, nonatomic) LoadingView *spinner;

@end
