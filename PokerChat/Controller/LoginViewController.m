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


//#define API_HOST @"http://10.0.1.23"
//#define API_HOST @"http://10.0.1.9"
#define API_HOST @"http://10.0.1.44"

//#define API_PORT @"3014"
#define API_PORT @"3000"

#define API_POMELO_HOST @"10.0.1.44"
//#define API_POMELO_HOST @"10.0.1.23"
#define API_POMELO_PORT 3014


#define GUESTPASSWORD @"123456"
//#define GATEHANDLER_LOGIN @"gate.gateHandler.login"

@interface LoginViewController ()
{
    UserRole userRole;
    RegisterView *registerView;
    NSMutableData *receiveData;
    NSString *username;
    NSString *password;
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
    [self.view setExclusiveTouch:YES];
    [self.registerButton setExclusiveTouch:YES];
    [self.guestButton setExclusiveTouch:YES];
    [self.loginBtn setExclusiveTouch:YES];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"memUsername"]) {
        _nameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"memUsername"];
        _nameSwitch.on = YES;
    } else {
        _nameSwitch.on = NO;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"memUserPassword"]) {
        _channelTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"memUserPassword"];
        _passwordSwitch.on = YES;
    } else {
        _passwordSwitch.on = NO;
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setRegisterButton:nil];
    [self setGuestButton:nil];
    [self setNameSwitch:nil];
    [self setPasswordSwitch:nil];
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
    SSLog(@"roomViewController.listArray = %@",roomViewController.roomlistArray);
    roomViewController.onlineDict = [NSMutableDictionary dictionaryWithObject:[data objectForKey:@"onlineuser"] forKey:@"onlineuser"];
    switch (_nameSwitch.on) {
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:[UserDataManager sharedUserDataManager].user.username forKey:@"memUsername"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"nameSwitchState"];
            
            break;
        case 0:
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"memUsername"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"nameSwitchState"];
            break;
        default:
            break;
    }
    switch (_passwordSwitch.on) {
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:[UserDataManager sharedUserDataManager].user.userpassword
                                                      forKey:@"memUserPassword"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"passwordSwitchState"];
            break;
        case 0:
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"memUserPassword"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"passwordSwitchState"];
            break;
        default:
            break;
    }
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
    SSLog(@"data = %@",data);
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *parmas = @{@"userid":[UserDataManager sharedUserDataManager].user.userid,
                                 @"username":theUsername};
        [p requestWithRoute:@"connector.entryHandler.enter"
                  andParams:parmas
                andCallback:^(NSDictionary *result) {
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
        case SERVER_ERROR:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"服务端错误"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case PASSWORDERROR:
        {   //密码错误
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"密码错误"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case NOUSERNAME:
        {   //无此用户
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"无此用户"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
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
                                                      otherButtonTitles:nil];
            [registerView.spinner removeFromSuperview];
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
                                                      otherButtonTitles:nil];
            [alertView show];
            [self.pomelo disconnect];
        }
            break;
        case PARAM_ERROR:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"参数错误"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case GUEST_FORBIDDEN:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"游客禁止登陆"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case AUTH_FILED:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"验证失败"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case AUTH_TIME:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"验证超时"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];

        }
        default:
            break;
    }
}

//TODO:LOGIN:
/**
 *@brief已注册玩家登陆
 */
- (void)normalLogin
{
    username = _nameTextField.text;
    password = _channelTextField.text;
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
        //TODO:新登陆接口:
        if ([username length] >= 4 && [username length] <= 12) {
            [self connectHttpServerWithUsername:username password:password];
            self.spinner = [LoadingView loadingView];
            [self.view addSubview:self.spinner];
        } else {
            if ([username length] < 4) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                                                message:@"名称小于2位数"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            if ([username length] > 12) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                                                message:@"名称大于12位数"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
}

//TODO:新登陆接口实现:
- (void)connectHttpServerWithUsername:(NSString *)theName password:(NSString *)thePassword
{
    NSString *loginBody = [NSString stringWithFormat:@"username=%@&password=%@&devicetoken=%@&macaddress=%@",theName,thePassword,@"",MacAddress];
    NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@",API_HOST,API_PORT,@"login"]];
    NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] initWithURL:loginUrl];
    [loginRequest setHTTPMethod:@"POST"];
    SSLog(@"loginBody = %@",loginBody);
    [loginRequest setHTTPBody:[loginBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *loginConnection = [[NSURLConnection alloc] initWithRequest:loginRequest delegate:self];
    if (loginConnection) {
        SSLog(@"http login success");
        receiveData = nil;
        receiveData = [NSMutableData data];
    } else {
        SSLog(@"http login faild");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆失败"
                                                            message:@"http请求失败"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//TODO:新游客登陆
/**
 *@brief游客登陆
 */
- (void)guestLogin
{
    self.spinner = [LoadingView loadingView];
    [self.view addSubview:self.spinner];

    NSString *guestLoginBody = [NSString stringWithFormat:@"macaddress=%@&devicetoken=%@",MacAddress,@""];
    SSLog(@"guestLoginBody = %@",guestLoginBody);
    NSURL *guestLoginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@",API_HOST,API_PORT,@"guest"]];
    NSMutableURLRequest *guestRequest = [[NSMutableURLRequest alloc] initWithURL:guestLoginUrl];
    [guestRequest setHTTPMethod:@"POST"];
    [guestRequest setHTTPBody:[guestLoginBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *loginConnection = [[NSURLConnection alloc] initWithRequest:guestRequest delegate:self];
    if (loginConnection) {
        SSLog(@"http login success");
        receiveData =nil;
        receiveData = [NSMutableData data];
    } else {
        SSLog(@"http login failed");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆失败"
                                                        message:@"http请求失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
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
    //弹出注册框
    registerView = [RegisterView createRegisterViewWithDelegate:self addParentView:self.view];
    registerView.parentView = self.view;
}

/**
 *@brief游客登陆Action
 */
- (IBAction)guestLogin:(id)sender
{
    [self guestLogin];
}

/**
 *@brieftextField完成编辑
 */
- (IBAction)textFieldDoneEdit:(id)sender
{
    SSLog(@"textFieldDoneEdit");
    UITextField *selectTextField = (id)sender;
    if (selectTextField == _nameTextField) {
        [_channelTextField becomeFirstResponder];
    } else if (selectTextField == _channelTextField) {
        [_channelTextField resignFirstResponder];
        [self normalLogin];
    }
}
- (IBAction)switchClick:(id)sender
{
    SSLog(@"switchClick");
    UISwitch *memSwitch = (id)sender;
    if (memSwitch == _nameSwitch) {
        switch (memSwitch.on) {
            case 1:
                [[NSUserDefaults standardUserDefaults] setObject:[UserDataManager sharedUserDataManager].user.username
                                                          forKey:@"memUsername"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"nameSwitchState"];
                break;
            case 0:
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"memUsername"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"nameSwitchState"];
                break;
                
            default:
                break;
        }
    } else if (memSwitch == _passwordSwitch) {
        switch (memSwitch.on) {
            case 1:
                [[NSUserDefaults standardUserDefaults] setObject:[UserDataManager sharedUserDataManager].user.userpassword
                                                          forKey:@"memUserPassword"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"passwordSwitchState"];
                break;
            case 0:
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"memUserPassword"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"passwordSwitchState"];
                
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -
#pragma UITextFieldViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _nameTextField) {
        [_channelTextField becomeFirstResponder];
    } else if (textField == _channelTextField) {
        [_channelTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark RegisterViewDelegate
- (void)userRegisterWithName:(NSString *)theName andPassword:(NSString *)thePassword
{
    userRole = UserRoleRegister;
    [self guestRegisterWithUsername:theName password:thePassword andUserRole:userRole];
}
//TODO:新:http注册系统
- (void)guestRegisterWithUsername:(NSString *)name password:(NSString *)thepassword andUserRole:(UserRole)role
{
    username = name;
    password = thepassword;
    NSString *registerBody = [NSString stringWithFormat:@"username=%@&password=%@&devicetoken=%@&macaddress=%@&isguest=%d",name,password,@"",MacAddress,0];
    NSURL *registerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@/%@",API_HOST,API_PORT,@"register"]];
    NSMutableURLRequest *registerRequest = [[NSMutableURLRequest alloc] initWithURL:registerUrl];
    [registerRequest setHTTPMethod:@"POST"];
    [registerRequest setHTTPBody:[registerBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *registerConnection = [[NSURLConnection alloc ] initWithRequest:registerRequest delegate:self];
    if (registerConnection) {
        SSLog(@"http register success");//注册成功储存username password
        receiveData = nil;
        receiveData = [NSMutableData data];
    } else {
        SSLog(@"http register failed");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                        message:@"http请求失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate && NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.spinner removeFromSuperview];
    if ([[[[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"] substringFromIndex:[[[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"] length] - 8] isEqualToString:@"register"]) {
        [registerView.spinner removeFromSuperview];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error:%d",[error code]]
                                                    message:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:@"NSLocalizedDescription"]]
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receiveData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receiveData appendData:data];
}

//Http请求完成返回的数据
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.spinner removeFromSuperview];
    NSError *jsonParseError = nil;
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableContainers error:&jsonParseError];
    SSLog(@"jsonData = %@",jsonData);
    
    if ([jsonData objectForKey:@"route"] != nil && [[jsonData objectForKey:@"route"] isEqualToString:@"login"]) {
        //进入新的登陆
        SSLog(@"进入新的登陆");
        UserData *user = [[UserData alloc] initWithDic:jsonData];
        [UserDataManager sharedUserDataManager].user = user;
        [UserDataManager sharedUserDataManager].user.userRole = UserRoleRegister;
        [UserDataManager sharedUserDataManager].user.username = username;
        [UserDataManager sharedUserDataManager].user.userpassword = password;
        SSLog(@"loginid = %@",[jsonData objectForKey:@"userid"]);
        [self connectServerForEnterWithUserid:[[jsonData objectForKey:@"userid"] intValue] andToken:[jsonData objectForKey:@"token"]];
    } else if ([jsonData objectForKey:@"route"] != nil && [[jsonData objectForKey:@"route"] isEqualToString:@"register"]) {
        //进入新的注册
        SSLog(@"进入新的注册");
        UserData *user = [[UserData alloc] initWithDic:jsonData];
        [UserDataManager sharedUserDataManager].user = user;
        [UserDataManager sharedUserDataManager].user.userRole = UserRoleRegister;
        [UserDataManager sharedUserDataManager].user.username = username;
        [UserDataManager sharedUserDataManager].user.userpassword = password;
        [UserDataManager sharedUserDataManager].user.resultDict = jsonData;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulation"
                                                        message:@"注册成功"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else if ([jsonData objectForKey:@"route"] != nil && [[jsonData objectForKey:@"route"] isEqualToString:@"guest"]) {
        //进入新的游客登陆
        SSLog(@"进入新的游客登陆");
        UserData *user = [[UserData alloc] initWithDic:jsonData];
        [UserDataManager sharedUserDataManager].user = user;
        [UserDataManager sharedUserDataManager].user.userRole = UserRoleGuest;
        [self connectServerForEnterWithUserid:[[jsonData objectForKey:@"userid"] intValue] andToken:[jsonData objectForKey:@"token"]];
    } else {
        [self checkError:[[jsonData objectForKey:@"errorcode"] intValue]];
    }
}
//TODO:连接pomemo 接入gate.gateHandler.entry接口
- (void)connectServerForEnterWithUserid:(int)userid andToken:(NSString *)theToken
{
    NSDictionary *params = @{@"userid": [NSString stringWithFormat:@"%d",userid],@"token":theToken};
    [self.pomelo connectToHost:API_POMELO_HOST onPort:API_POMELO_PORT withCallback:^(Pomelo *p) {
        [self.pomelo requestWithRoute:@"gate.gateHandler.entry" andParams:params andCallback:^(NSDictionary *result) {
            [self.pomelo disconnectWithCallback:^(Pomelo *p) {
                if ([[result objectForKey:@"code"] intValue] == CODESUCCESS) {
                    //成功进入
                    [self entryWithLoginData:result andToken:theToken];
                } else {
                    [self checkError:[[[result objectForKey:@"error"] objectForKey:@"errorcode"] intValue]];
                }
            }];
        }];
    }];
}

//TODO:进入connector.entryHandler.entry接口
- (void)entryWithLoginData:(NSDictionary *)data andToken:(NSString *)token
{
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid,
                                 @"token":[UserDataManager sharedUserDataManager].user.userToken};
        [p requestWithRoute:@"connector.entryHandler.entry" andParams:params andCallback:^(NSDictionary *result) {
            if ([[result objectForKey:@"code"] intValue] == CODESUCCESS) {
                [self enterCenterRoom:result];
            } else {
                [self checkError:[[[result objectForKey:@"error"] objectForKey:@"errorcode"] intValue]];
            }
        }];
    }];
}

//TODO:新注册
#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [registerView close];
    [self connectServerForEnterWithUserid:[[UserDataManager sharedUserDataManager].user.userid intValue]
                                andToken:[UserDataManager sharedUserDataManager].user.userToken];
}

@end
