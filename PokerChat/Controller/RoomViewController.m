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
#import "base64.h"

@interface RoomViewController ()

@end

@implementation RoomViewController
{
    NSDictionary *tmpDict;
    CreatRoomView *popCreatRoomView;
}

#pragma mark -
#pragma mark life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.roomlistArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.view addSubview:_userheadImgView];
    [self.view addSubview:_usernameLbl];
    [self.view addSubview:_useridLbl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _usernameLbl.text = [NSString stringWithFormat:@"用户名:%@",[UserDataManager sharedUserDataManager].user.username];
    _useridLbl.text = [NSString stringWithFormat:@"ID:%@",[UserDataManager sharedUserDataManager].user.userid];
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
    [self setExitBtn:nil];
    [self setUsernameLbl:nil];
    [self setUseridLbl:nil];
    [self setUserheadImgView:nil];
    [super viewDidUnload];
}

#pragma mark - IBActions
/**
 *创建聊天房间
 */
- (IBAction)creatRoom:(id)sender
{
    popCreatRoomView = [CreatRoomView creatRoomViewWithDelegate:self];
    popCreatRoomView.center = self.view.center;
    [self.view addSubview:popCreatRoomView];
}

- (void)updateRooms:(NSDictionary *)dict
{
    SSLog(@"dict = %@",dict);
    tmpDict = [NSDictionary dictionaryWithDictionary:dict];
    [self.romeList beginUpdates];
    [self.roomlistArray addObject:[NSMutableDictionary dictionaryWithDictionary: dict]];
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_roomlistArray count] - 1 inSection:0]];
    [self.romeList insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    [self.romeList endUpdates];
  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"创建成功"
                                                    message:@"进入房间"
                                                   delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


/**
 *编辑完成
 */
- (IBAction)editEnd:(id)sender
{
    [sender becomeFirstResponder];
}

/**
 *退到登陆界面
 */
- (IBAction)exitToLogin:(id)sender
{
    NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid,
                             @"username":[UserDataManager sharedUserDataManager].user.username};
    SSLog(@"toLoginparams = %@",params);
    [self.pomelo requestWithRoute:@"connector.entryHandler.quit"
                        andParams:params
                      andCallback:^(NSDictionary * result) {
                          if ([[result objectForKey:@"code"] intValue] == CODESUCCESS) {
                              [self.navigationController popToRootViewControllerAnimated:YES];
                              [self.pomelo disconnect];
                          }
                      }];
}

#pragma mark -
#pragma mark private methods

- (void)showSpinner
{
    self.spinner = [LoadingView loadingView];
    [self.view addSubview:self.spinner];
}
/**
 * 进入聊天房间
 */
- (void)enterRoom:(NSDictionary *)roomData
{
    SSLog(@"roomData= %@",roomData);
    SSLog(@"[UserDataManager sharedUserDataManager].user.userid=%@",[UserDataManager sharedUserDataManager].user.userid);
    NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid,
                             @"username":[UserDataManager sharedUserDataManager].user.username,
                             @"channelid":[roomData objectForKey:@"channelid"]};
    SSLog(@"enterRoomparams = %@",params);
    [self.pomelo requestWithRoute:@"connector.entryHandler.enterRoom" andParams:params andCallback:^(NSDictionary *result) {
        SSLog(@"result = %@",result);
        [self.spinner removeFromSuperview];
        NSArray *userList = [result objectForKey:@"users"];
        [UserDataManager sharedUserDataManager].user.channelName = [roomData objectForKey:@"name"];
        SSLog(@"enterRoomChannel = %@", [roomData objectForKey:@"name"]);
        //填数字给tableview。
        ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        chatViewController.pomelo = self.pomelo;
        chatViewController.userDic = [NSMutableDictionary dictionaryWithDictionary:params];
//        [chatViewController.userDic setObject:[roomData objectForKey:@"channelid"] forKey:@"channelid"];
        SSLog(@"self.userlist = %@",userList);
        SSLog(@"chatViewController.userDic = %@",chatViewController.userDic);
        [chatViewController.contactList addObjectsFromArray:userList];
        [self.navigationController pushViewController:chatViewController animated:YES];
        self.creatRoomTextField.text = @"";
    }];
}


#pragma mark -
#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    SSLog(@"self.roomlistArray = %@",self.roomlistArray);
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
    NSString *str = [NSString stringWithFormat:@"%@                %@                                             %@",
                     [[self.roomlistArray objectAtIndex:row] objectForKey:@"channelid"],
                     [[self.roomlistArray objectAtIndex:row] objectForKey:@"name"],
                     [[self.roomlistArray objectAtIndex:row] objectForKey:@"count"]];
    
    cell.textLabel.text = str;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectDict = [self.roomlistArray objectAtIndex:indexPath.row];
    SSLog(@"sdfa=%@",selectDict);
    [self performSelectorOnMainThread:@selector(showSpinner) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(enterRoom:) withObject:selectDict waitUntilDone:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"房间ID         房间名称                                            房间人数";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"在线人数:%@",[self.onlineDict objectForKey:@"onlineuser"]];
}

#pragma mark -
#pragma mark CreatRoomDelegate
- (void)creatRoomWithChannelName:(NSString *)theChannelName
{
    NSString *channel = theChannelName;
    NSNumber *userid = [UserDataManager sharedUserDataManager].user.userid;
  
    NSDictionary *params = @{@"channel": channel,@"userid":userid};
    SSLog(@"creatRoomParams = %@",params);
    [self.pomelo requestWithRoute:@"connector.entryHandler.createRoom"
                        andParams:params
                      andCallback:^(NSDictionary *result) {
                          if ([[result objectForKey:@"code"] intValue] == 200) {
                              //成功
                              SSLog(@"creat room success:result = %@",result);
                              NSDictionary *newRoom = @{@"channelid": [NSString stringWithFormat:@"%@",[result objectForKey:@"channelid"]],
                                                        @"name":channel,
                                                        @"count":@0};
                              [self performSelectorOnMainThread:@selector(updateRooms:) withObject:newRoom waitUntilDone:YES];
                          } else {
                              SSLog(@"Err:%@",[result objectForKey:@"code"]);
                          }
                          self.creatRoomTextField.text = @"";
                      }];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    [self enterRoom:tmpDict];
    [popCreatRoomView close];
}

@end