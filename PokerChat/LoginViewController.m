//
//  LoginViewController.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"
#import "UserData.h"
#import "UserDataManager.h"
#import "RoomViewController.h"

typedef enum
{
    UserRoleGuest,
    UserRoleRegister,
    UserRoleAdmin,
}UserRole;  //user类型

#define GUSETPASSWORD @"123456"

@interface LoginViewController ()
{
    UserRole userRole;
}
- (void)entryWithData:(NSDictionary *)data;
@end

@implementation LoginViewController
@synthesize pomelo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/**
 *登陆
 */

- (IBAction)login:(id)sender
{
    NSString *username = _nameTextField.text;
    NSString *passward = _channelTextField.text;
    [self.pomelo connectToHost:@"10.0.1.44" onPort:3014 withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"username": username,@"password":passward};
        NSLog(@"login params = %@",params);
        [self.pomelo requestWithRoute:@"gate.gateHandler.login" andParams:params andCallback:^(NSDictionary *result) {
            NSLog(@"result = %@",result);
            [self.pomelo disconnectWithCallback:^(Pomelo *p) {
                NSLog(@"normalLoginResult1=%@",result);
                UserData *userData = [[UserData alloc] initWithDic:result];
                [UserDataManager sharedUserDataManager].user = userData;
                [UserDataManager sharedUserDataManager].user.username = username;
                [self entryWithNormalLogin:result guestName:username guestPassword:passward];
            }];
        }];
    }];
}

- (void)entryWithNormalLogin:(NSDictionary *)data guestName:theusername guestPassword:thepassword
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];

    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSLog(@"[UserDataManager sharedUserDataManager].user.userid = %@",[UserDataManager sharedUserDataManager].user.userid);
        NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid};
        [p requestWithRoute:@"connector.entryHandler.enter" andParams:params andCallback:^(NSDictionary *result) {
            NSLog(@"loginResult = %@",result);
            [self enterRoom:result];
        }];
    }];

}

- (void)entryWithLoginData:(NSDictionary *)data
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    NSString *username = _nameTextField.text;
    NSString *password = _channelTextField.text;
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"username": username,@"password":password};
        [p requestWithRoute:@"gate.gateHandler.login" andParams:params andCallback:^(NSDictionary *result) {
            NSLog(@"loginResult = %@",result);
            [self enterRoom:result];
        }];
    }];
}

- (IBAction)register:(id)sender
{
    NSLog(@"register");
    userRole = UserRoleRegister;
    NSString *registerUsername = _nameTextField.text;
    NSString *registerPassword = _channelTextField.text;
    NSString *onceAgainPassword = _onceAgainPassword.text;
    
    if ([registerUsername length] >= 4 && [registerUsername length] <= 12) {
        if ([registerPassword isEqualToString:onceAgainPassword]) {
            if ([registerPassword length] >= 4 && [registerPassword length] <= 12) {
                [self.pomelo connectToHost:@"10.0.1.44" onPort:3014 withCallback:^(Pomelo *p) {
                    NSDictionary *params = @{@"username": registerUsername, @"password":registerPassword,@"role":[NSString stringWithFormat:@"%d",userRole]};
                    NSLog(@"params = %@",params);
                    [self.pomelo requestWithRoute:@"gate.gateHandler.register" andParams:params andCallback:^(NSDictionary *result) {
                    NSLog(@"result = %@", result);
                        [self.pomelo disconnectWithCallback:^(Pomelo *p) {
                            if ([[result objectForKey:@"code"] intValue] == 200) {
                                NSLog(@"注册成功");
                                UserData *userData = [[UserData alloc] initWithDic:result];
                                [UserDataManager sharedUserDataManager].user = userData;
                                [UserDataManager sharedUserDataManager].user.role = @(UserRoleRegister);
                                [UserDataManager sharedUserDataManager].user.username = _nameTextField.text;
                                [self entryWithRegisterData:result];
                            } else {
                                NSLog(@"err = %@",[result objectForKey:@"code"]);
                            }
                        }];
                    }];
                }];
            } else {
                //密码不合规矩
                NSLog(@"密码不合规矩");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Error", @"password error")
                                                                    message:@"密码不合规矩"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
        } else {
            //前后密码不一致
            NSLog(@"前后密码不一致");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"password error")
                                                                message:@"前后密码不一致" delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    } else {
        //昵称不合规矩
            NSLog(@"昵称不合规矩");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"nickname error")
                                                                message:@"昵称不合规矩" delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];

    }
    
    
}

/**
 *注册握手连接
 */
- (void)entryWithRegisterData:(NSDictionary *)data
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid};
        [p requestWithRoute:@"connector.entryHandler.enter" andParams:params andCallback:^(NSDictionary *result) {
            NSLog(@"registerResult=%@",result);
//            RoomViewController *roomController = [[RoomViewController alloc] initWithNibName:@"RoomViewController" bundle:nil];
//            roomController.pomelo = self.pomelo;
//            
//            roomController.roomlistArray = [result objectForKey:@"roomlist"];
//            NSLog(@"roomlistArray = %@",roomController.roomlistArray);
//            [self.navigationController pushViewController:roomController animated:YES];
            [self enterRoom:result];
            
        }];
    }];
}

- (void)enterRoom:(NSDictionary *)data
{
    RoomViewController *roomController = [[RoomViewController alloc] initWithNibName:@"RoomViewController" bundle:nil];
    roomController.pomelo = self.pomelo;
    roomController.roomlistArray = [data objectForKey:@"roomlist"];
    [self.navigationController pushViewController:roomController animated:YES];
}


- (IBAction)guestLogin:(id)sender {
    NSString *guestName = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]]];
//    NSString *guestName = (NSString *)[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue];
    NSString *guestPassword = GUSETPASSWORD;
    NSLog(@"guestName=%@",guestName);
    userRole = UserRoleGuest;
    [self.pomelo connectToHost:@"10.0.1.44" onPort:3014 withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"username": guestName,@"password":guestPassword,@"role":[NSString stringWithFormat:@"%d",userRole]};
        
        [self.pomelo requestWithRoute:@"gate.gateHandler.register" andParams:params andCallback:^(NSDictionary *result) {
            NSLog(@"guestLoginResult = %@",result);
            [self.pomelo disconnectWithCallback:^(Pomelo *p) {
                UserData *userData = [[UserData alloc] initWithDic:result];
                [UserDataManager sharedUserDataManager].user = userData;
              
                NSLog(@"[UserDataManager sharedUserDataManager].user.username = %@",guestName);
                [UserDataManager sharedUserDataManager].user.username = (NSString *)guestName;
                [UserDataManager sharedUserDataManager].user.role = @(UserRoleGuest);
                [self entrywithGuestLogin:result guestName:guestName guestPassword:guestPassword];
                
            }];
        }];
    }];
}

- (void)entrywithGuestLogin:(NSDictionary *)data guestName:(NSString *)theName guestPassword:(NSString *)thePassword
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid};
        [p requestWithRoute:@"connector.entryHandler.enter" andParams:params andCallback:^(NSDictionary *result) {
            NSLog(@"normalLoginResult = %@",result);
            [self enterRoom:result];
        }];
    }];
}


/**
 *握手连接
 */
- (void)entryWithData:(NSDictionary *)data
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    NSString *name = _nameTextField.text;
    NSString *channel = _channelTextField.text;
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"username": name,@"rid":channel};
        NSLog(@"params=%@",params);
        
        [p requestWithRoute:@"connector.entryHandler.enter" andParams:params andCallback:^(NSDictionary *result) {
            NSArray *userList = [result objectForKey:@"users"];
            //填数字给tableview。
            NSLog(@"result2=%@",result);
            NSLog(@"params2=%@",params);
            NSLog(@"userlist=%@",userList);
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
            chatViewController.pomelo = self.pomelo;
            chatViewController.userDic = [NSMutableDictionary dictionaryWithDictionary:params];
            [chatViewController.contactList addObjectsFromArray:userList];
            [chatViewController.contactList removeObject:name];
            [self.navigationController pushViewController:chatViewController animated:YES];
        }];
    }];
}
/**
 *textField完成编辑
 */
- (IBAction)textFieldDoneEdit:(id)sender
{
    [sender resignFirstResponder];
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
@end
