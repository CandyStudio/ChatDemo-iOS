//
//  RoomViewController.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-14.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "RoomViewController.h"
#import "UserDataManager.h"
#import "UserData.h"
#import "ChatViewController.h"

@interface RoomViewController ()

@end

@implementation RoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.roomlistArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)creatRoom:(id)sender
{
//    NSString *channel = _creatRoomTextField.text;
//    [self enterRoom:channel];
    NSString *channel = _creatRoomTextField.text;
    NSString *username = [UserDataManager sharedUserDataManager].user.username;
    NSNumber *userid = [UserDataManager sharedUserDataManager].user.userid;
    NSDictionary *params = @{@"channel": channel,@"username":username,@"userid":userid};
    [self.pomelo requestWithRoute:@"connector.entryHandler.createRoom" andParams:params andCallback:^(NSDictionary *result) {
        NSLog(@"result123 = %@",result);
        if ([[result objectForKey:@"code"] intValue] == 200) {
            //成功
            NSLog(@"result = %@",result);
            NSDictionary *newRoom = @{@"id": [NSString stringWithFormat:@"%@",[result objectForKey:@"roomid"]],@"name":channel};
            [self.romeList beginUpdates];
            [self.roomlistArray addObject:[NSMutableDictionary dictionaryWithDictionary: newRoom]];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_roomlistArray count] - 1 inSection:0]];
            [self.romeList insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            [self.romeList endUpdates];
        } else{
        
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCreatRoomTextField:nil];
    [self setCreatRoomButton:nil];
    [self setRomeList:nil];
    [super viewDidUnload];
}

- (IBAction)editEnd:(id)sender
{
    [sender becomeFirstResponder];
}

#pragma mark -
#pragma mark private methods
- (void)enterRoom:(NSString *)channel
{
    if ([channel length] > 0 && channel != nil) {
        NSLog(@"!!!!channel=%@",channel);
        NSLog(@"[UserDataManager sharedUserDataManager].user.username=%@",[UserDataManager sharedUserDataManager].user.username);
        NSLog(@"[UserDataManager sharedUserDataManager].user.userid=%@",[UserDataManager sharedUserDataManager].user.userid);
        NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid,@"username":[UserDataManager sharedUserDataManager].user.username,@"channel":channel};
        [self.pomelo requestWithRoute:@"connector.entryHandler.enterRoom" andParams:params andCallback:^(NSDictionary *result) {
            NSArray *userList = [result objectForKey:@"users"];
            NSLog(@"userlist = %@",userList);
            //填数字给tableview。
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
            chatViewController.pomelo = self.pomelo;
            chatViewController.userDic = [NSMutableDictionary dictionaryWithDictionary:params];
            [chatViewController.contactList addObjectsFromArray:userList];
//            [chatViewController.contactList removeObject:[UserDataManager sharedUserDataManager].user.username];
//            [chatViewController.contactList removeObject:[UserDataManager sharedUserDataManager].user.userid];
            [self.navigationController pushViewController:chatViewController animated:YES];
            //        [self presentViewController:chatViewController animated:NO completion:nil];
        }];
    } else {
        NSLog(@"房间名不能为空");
    }
}


#pragma mark -
#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.roomlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"roomListTabelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSInteger row = indexPath.row;
//    cell.textLabel.text = [self.roomlistArray objectAtIndex:row];
    cell.textLabel.text = [[self.roomlistArray objectAtIndex:row] objectForKey:@"name"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [[self.roomlistArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self enterRoom:str];
}


@end
