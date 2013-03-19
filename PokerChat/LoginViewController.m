//
//  LoginViewController.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "LoginViewController.h"
#import "UserData.h"
#import "UserDataManager.h"
#import "RoomViewController.h"
#import "RegisterView.h"

typedef enum
{
    UserRoleGuest,
    UserRoleRegister,
    UserRoleAdmin,
}UserRole;  //user类型

#define PASSWORDERROR 0
#define NOUSERNAME 1
#define ALREADYHASUSER 2
#define ALREADYLOGIN 3
#define SUCCESSLOGIN 200


//typedef enum
//{
//
//}GateHandlerType;

#define GUESTPASSWORD @"123456"
//#define GATEHANDLER_LOGIN @"gate.gateHandler.login"

@interface LoginViewController ()
{
    UserRole userRole;
}

/**
 *正常登陆
 */
- (void)normalLogin;

/**
 *游客登陆
 */
- (void)guestLogin;

/**
 *玩家注册
 */
- (void)guestRegister;

@end

@implementation LoginViewController
@synthesize pomelo;

#pragma mark -
#pragma mark life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRegisterButton:nil];
    [self setGuestButton:nil];
    [self setOnceAgainPassword:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark New Login, GuestLogin And Register Method

/**
 *@brief 进入聊天大厅
 *@param data 请求enter后返回的数据
 */
- (void)enterCenterRoom:(NSDictionary *)data
{
    RoomViewController *roomViewController = [[RoomViewController alloc] initWithNibName:@"RoomViewController" bundle:nil];
    roomViewController.pomelo = self.pomelo;
    roomViewController.roomlistArray = [NSMutableArray arrayWithArray:[data objectForKey:@"roomlist"]];
    [self.navigationController pushViewController:roomViewController animated:YES];
}

/**
 *@brief 请求enter
 *@param data 请求login后返回的结果
 *@param theUsername 玩家名称
 *@param thePassword 玩家密码
 */
- (void)entryWithLoginData:(NSDictionary *)data userName:(NSString *)theUsername andPassword:(NSString *)thePassword
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *parmas = @{@"userid":[UserDataManager sharedUserDataManager].user.userid,@"username":theUsername};
        [p requestWithRoute:@"connector.entryHandler.enter" andParams:parmas andCallback:^(NSDictionary *result) {
            SSLog(@"enterResult = %@",result);
            if ([[result objectForKey:@"code"] intValue] == 200) {
                [self enterCenterRoom:result];
            } else {
                [self checkError:[[[result objectForKey:@"err"] objectForKey:@"errorcode"] intValue]];
            }
        }];
    }];
}

- (void)checkError:(int)errorType
{
    switch (errorType) {
        case PASSWORDERROR:
        {   //密码错误
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"密码错误"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case NOUSERNAME:
        {   //无此用户
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"无此用户"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case ALREADYHASUSER:
        {
            //用户已注册
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"用户已注册"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];

        }
            break;
        case ALREADYLOGIN:
        {
            //用户已经登陆
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"用户已经登陆"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
            
        default:
            break;
    }
}

/**
 *@brief login请求
 *@param theUsername 用户名
 *@param thePassword 密码
 *@param theRole 玩家类型
 */
- (void)connectServerWithUsername:(NSString *)theUsername password:(NSString *)thePassword andUserRole:(UserRole )theRole
{
    [self.pomelo connectToHost:@"10.0.1.44" onPort:3014 withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"username": theUsername,@"password":thePassword};
        [self.pomelo requestWithRoute:@"gate.gateHandler.login" andParams:params andCallback:^(NSDictionary *result) {
            [self.pomelo disconnectWithCallback:^(Pomelo *p) {
                SSLog(@"rusult = %@",result);
                if ([[result objectForKey:@"code"] intValue] == 200) {
                    UserData *userData = [[UserData alloc] initWithDic:result];
                    [UserDataManager sharedUserDataManager].user = userData;
                    [UserDataManager sharedUserDataManager].user.role = @(theRole);
                    [UserDataManager sharedUserDataManager].user.username = theUsername;
                    [self entryWithLoginData:result userName:theUsername andPassword:thePassword];
                } else {
                    SSLog(@"result.logincode = %@",[result objectForKey:@"err"]);
                    [self checkError:[[[result objectForKey:@"err"] objectForKey:@"errorcode"] intValue]];
                }
            }];
        }];
    }];
}

//TODO:LOGIN:
/**
 *@brief已注册玩家登陆
 */
- (void)normalLogin
{
    NSString *username = _nameTextField.text;
    NSString *password = _channelTextField.text;
    userRole = UserRoleRegister;
    if ([username isEqualToString:@""] && [password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                                        message:@"请输入名称和密码"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else if ([username isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                                        message:@"请输入名称"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else if ([password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                                        message:@"请输入密码"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        //TODO:
        [self connectServerWithUsername:username password:password andUserRole:userRole];
    }
}


//TODO:REGISTER
/**
 *@brief玩家注册
 */
- (void)guestRegister
{
    NSString *registerUsername = _nameTextField.text;
    NSString *registerPassword = _channelTextField.text;
    NSString *againPassword = _onceAgainPassword.text;
    userRole = UserRoleRegister;
    //注册名字的要求
    if ([registerUsername length] >= 4 && [registerUsername length] <= 12) {
        //密码要求
        if ([registerPassword isEqualToString:againPassword]) {
            if ([registerPassword length] >= 4 && [registerPassword length] <= 12) {
                [self guestLoginOrRegisterWithUsername:registerUsername password:registerPassword andUserRole:userRole];
            } else {
                //密码的长度和符合条件
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:@"密码长度不符合条件"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
                [alerView show];
            }
        } else {
            //前后密码不一致
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"前后密码不一致"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    } else {
        //昵称不对
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"昵称不符合要求"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}



/**
 *@brief 游客登陆或者玩家注册时调用的方法，用来完成注册
 *@param theName 注册姓名或默认游客姓名
 *@param thePassword 注册密码或默认游客密码123456
 *@param theRole 判断是注册玩家还是游客玩家
 */
- (void)guestLoginOrRegisterWithUsername:(NSString *)theName password:(NSString *)thePassword andUserRole:(UserRole)theRole
{
    [self.pomelo connectToHost:@"10.0.1.44" onPort:3014 withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"username": theName,@"password":thePassword,@"role":[NSString stringWithFormat:@"%d",theRole]};
        [self.pomelo requestWithRoute:@"gate.gateHandler.register" andParams:params andCallback:^(NSDictionary *result) {
            SSLog(@"registOrGuestResult = %@",result);
            [self.pomelo disconnectWithCallback:^(Pomelo* p) {
                if ([[result objectForKey:@"code"] intValue] == 200) {
                    UserData *userData = [[UserData alloc] initWithDic:result];
                    [UserDataManager sharedUserDataManager].user = userData;
                    [UserDataManager sharedUserDataManager].user.role = @(theRole);
                    [UserDataManager sharedUserDataManager].user.username = theName;
                    [UserDataManager sharedUserDataManager].user.userpassword = thePassword;
                    [UserDataManager sharedUserDataManager].user.resultDict = result;
                    if (theRole == UserRoleRegister) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulation"
                                                                        message:@"注册成功"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                    } else {
                        //NEXT:游客登陆
                        [self entryWithLoginData:result userName:theName andPassword:thePassword];
                    }                   
                } else {
                    [self checkError:[[[result objectForKey:@"err"] objectForKey:@"errorcode"] intValue]];
                }
            }];
        }];
    }];
}

//TODO:GUEST LOGIN
/**
 *@brief游客登陆
 */
- (void)guestLogin
{
    NSString *guestName = [NSString stringWithFormat:@"游客%@",@((int)[[NSDate date] timeIntervalSince1970])];
    if ([guestName length] > 12) {
        [guestName substringToIndex:12];
    }
    NSString *guestPassword = GUESTPASSWORD;
    userRole = UserRoleGuest;
    [self guestLoginOrRegisterWithUsername:guestName password:guestPassword andUserRole:userRole];
}
#pragma mark -
#pragma mark IBActions
/**
 *@brief登陆Action
 */

- (IBAction)login:(id)sender
{
    [self normalLogin];
}

/**
 *@brief注册Action
 */
- (IBAction)register:(id)sender
{
//    [self guestRegister];
    //弹出注册框
    RegisterView *registerView = [RegisterView createRegisterViewWithDelegate:self];
    [self.view addSubview:registerView];
    registerView.frame = CGRectMake(30, 60, 960, 600);
}

/**
 *@brief游客登陆Action
 */
- (IBAction)guestLogin:(id)sender {
    [self guestLogin];
}

/**
 *@brieftextField完成编辑
 */
- (IBAction)textFieldDoneEdit:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark -
#pragma mark RegisterViewDelegate
- (void)userRegisterWithName:(NSString *)theName andPassword:(NSString *)thePassword
{
    userRole = UserRoleRegister;
    SSLog(@"theName = %@",theName);
    SSLog(@"thePassword = %@",thePassword);
    [self guestLoginOrRegisterWithUsername:theName password:thePassword andUserRole:userRole];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"cancel alertView");
    [self entryWithLoginData:[UserDataManager sharedUserDataManager].user.resultDict
                    userName:[UserDataManager sharedUserDataManager].user.username
                 andPassword:[UserDataManager sharedUserDataManager].user.userpassword];
}


@end
