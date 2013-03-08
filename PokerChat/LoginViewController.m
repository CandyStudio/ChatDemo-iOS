//
//  LoginViewController.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"

@interface LoginViewController ()
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
    NSString *name = _nameTextField.text;
    NSString *channel = _channelTextField.text;
    if (([name length] > 0) && ([channel length] > 0)) {
        [self.pomelo connectToHost:@"10.0.1.23" onPort:3014 withCallback:^(Pomelo *p) {
            NSDictionary *params = [NSDictionary dictionaryWithObject:name forKey:@"uid"];
            NSLog(@"params = %@",params);
            [self.pomelo requestWithRoute:@"gate.gateHandler.queryEntry" andParams:params andCallback:^(NSDictionary *result) {
                NSLog(@"result=%@",result);
                [self.pomelo disconnectWithCallback:^(Pomelo *p) {
                    NSLog(@"result2=%@",result);
                    [self entryWithData:result];
                }];
            }];
        }];
    }
}
/**
 *失败时再次连接
 */
- (void)entryWithData:(NSDictionary *)data
{
    NSLog(@"data=%@",data);
    NSString *host = [data objectForKey:@"host"];
    NSInteger port = [[data objectForKey:@"port"] intValue];
    NSString *name = _nameTextField.text;
    NSString *channel = _channelTextField.text;
    NSLog(@"name=%@",name);
    NSLog(@"channel=%@",channel);
    NSLog(@"%@",self.pomelo);
    [self.pomelo connectToHost:host onPort:port withCallback:^(id callback) {
    }];
    [self.pomelo connectToHost:host onPort:port withCallback:^(Pomelo *p) {
        NSLog(@"name = %@",name);
        NSLog(@"channel = %@",channel);
        NSDictionary *params = @{@"username": name,@"rid":channel};
        NSLog(@"-----");
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

@end
