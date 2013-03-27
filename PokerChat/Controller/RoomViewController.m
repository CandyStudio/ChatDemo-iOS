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
#import "RoomListTableViewCell.h"
#import "SS_PinYin.h"

@interface RoomViewController ()

@end

@implementation RoomViewController
{
    NSDictionary *tmpDict;
    CreatRoomView *popCreatRoomView;
    RoomListTableViewCell *roomListCell;
    RoomListTableViewHeader *roomListHeader;
    RoomListTableViewFooter *roomListFooter;
    int sortChannelid;
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
    _usernameLbl.text = [NSString stringWithFormat:@"用户名:%@",[UserDataManager sharedUserDataManager].user.username];
    _useridLbl.text = [NSString stringWithFormat:@"ID:%@",[UserDataManager sharedUserDataManager].user.userid];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setCreatRoomTextField:nil];
    [self setCreatRoomButton:nil];
    [self setRomeList:nil];
    [self setExitBtn:nil];
    [self setUsernameLbl:nil];
    [self setUseridLbl:nil];
    [self setUserheadImgView:nil];
    [self setRefreshBtn:nil];
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
    [self.roomlistArray addObject:tmpDict];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.pomelo disconnect];
}

- (IBAction)refresh:(id)sender
{
    NSDictionary *params = @{};
    
    [self.pomelo requestWithRoute:@"connector.entryHandler.refreshRoomList"
                        andParams:params andCallback:^(NSDictionary *result) {
                            if ([[result objectForKey:@"code"] intValue] == CODESUCCESS) {
                                self.roomlistArray = nil;
                                self.roomlistArray = [NSMutableArray arrayWithArray:[result objectForKey:@"roomlist"]];
                                [self.onlineDict setObject:[result objectForKey:@"onlineuser"] forKey:@"onlineuser"];
                                [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
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
    NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid,
                             @"username":[UserDataManager sharedUserDataManager].user.username,
                             @"channelid":[roomData objectForKey:@"channelid"]};
    [self.pomelo requestWithRoute:@"connector.entryHandler.enterRoom" andParams:params andCallback:^(NSDictionary *result) {
        [self.spinner removeFromSuperview];
        if ([[result objectForKey:@"code"] intValue] == CODESUCCESS) {
            NSArray *userList = [result objectForKey:@"users"];
            [UserDataManager sharedUserDataManager].user.channelName = [roomData objectForKey:@"name"];
            //填数字给tableview。
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
            chatViewController.pomelo = self.pomelo;
            chatViewController.userDic = [NSMutableDictionary dictionaryWithDictionary:params];
            [chatViewController.contactList addObjectsFromArray:userList];
            [self.navigationController pushViewController:chatViewController animated:YES];
            self.creatRoomTextField.text = @"";
        } else {
            switch ([[result objectForKey:@"code"] intValue]) {
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
    return [self.roomlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //定制的
    static NSString *CellIdentifier = @"RoomListTableViewCellIdentifier";
    roomListCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (roomListCell == nil) {
        roomListCell = [RoomListTableViewCell creatRoomListCell];
    }
    NSInteger row = indexPath.row;
    roomListCell.channelidLbl.text = [[self.roomlistArray objectAtIndex:row] objectForKey:@"channelid"];
    roomListCell.channelNameLbl.text = [[self.roomlistArray objectAtIndex:row] objectForKey:@"name"];
    roomListCell.channelOnlineNumLbl.text = [NSString stringWithFormat:@"%@",[[self.roomlistArray objectAtIndex:row] objectForKey:@"count"]];
    roomListCell.accessoryType = UITableViewCellAccessoryNone;
    roomListCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return roomListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectDict = [self.roomlistArray objectAtIndex:indexPath.row];
    [self performSelectorOnMainThread:@selector(showSpinner) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(enterRoom:) withObject:selectDict waitUntilDone:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    roomListHeader = [RoomListTableViewHeader createRoomListTableViewHeader];
    roomListHeader.delegate = self;
    return roomListHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    roomListFooter = [RoomListTableViewFooter createRoomListTableViewFooter];
    roomListFooter.delegate = self;
    roomListFooter.onlineUserNumLbl.text = [NSString stringWithFormat:@"%@",[self.onlineDict objectForKey:@"onlineuser"]];
    return roomListFooter;
}

//设置cell背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [roomListCell setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:155.0/255.0 blue:222.0/255.0 alpha:1]];
}

#pragma mark -
#pragma mark RoomListTableViewHeaderDelegate
- (void)channelSortByChannelid
{
    switch (sortChannelid % 2) {
        case 0:
        {
            NSSortDescriptor *channel_sort_by_channelid = [NSSortDescriptor sortDescriptorWithKey:@"channelid" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 intValue] > [obj2 intValue]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            [self.roomlistArray sortUsingDescriptors:[NSMutableArray arrayWithObject:channel_sort_by_channelid]];
            [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            sortChannelid = 1;
        }
            break;
        case 1:
        {
            NSSortDescriptor *channel_sort_by_channelid = [NSSortDescriptor sortDescriptorWithKey:@"channelid" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 intValue] < [obj2 intValue]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            [self.roomlistArray sortUsingDescriptors:[NSMutableArray arrayWithObject:channel_sort_by_channelid]];
            [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            sortChannelid = 0;
        }
            break;
        default:
            break;
    }        
}

- (void)channelSortByChannelName
{
    switch (sortChannelid % 2) {
        case 0:
        {
            NSSortDescriptor *channel_sort_by_channelid = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
                if (pinyinFirstLetter([[obj1 lowercaseString] characterAtIndex:0]) > pinyinFirstLetter([[obj2 lowercaseString] characterAtIndex:0])) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            [self.roomlistArray sortUsingDescriptors:[NSMutableArray arrayWithObject:channel_sort_by_channelid]];
            [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            sortChannelid = 1;
        }
            break;
        case 1:
        {
            NSSortDescriptor *channel_sort_by_channelid = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
                if (pinyinFirstLetter([[obj1 lowercaseString] characterAtIndex:0]) < pinyinFirstLetter([[obj2 lowercaseString] characterAtIndex:0])) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            [self.roomlistArray sortUsingDescriptors:[NSMutableArray arrayWithObject:channel_sort_by_channelid]];
            [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            sortChannelid = 0;
        }
            break;
        default:
            break;
    }
}

- (void)channelSortByChannelOnlineNumber
{
    switch (sortChannelid % 2) {
        case 0:
        {
            NSSortDescriptor *channel_sort_by_channelid = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 intValue] > [obj2 intValue]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            [self.roomlistArray sortUsingDescriptors:[NSMutableArray arrayWithObject:channel_sort_by_channelid]];
            [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            sortChannelid = 1;
        }
            break;
        case 1:
        {
            NSSortDescriptor *channel_sort_by_channelid = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 intValue] < [obj2 intValue]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            [self.roomlistArray sortUsingDescriptors:[NSMutableArray arrayWithObject:channel_sort_by_channelid]];
            [self.romeList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            sortChannelid = 0;
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark RoomListTableViewFooterDelegate
- (void)hiddenNoUsersChannel:(BOOL)swithState
{
    SSLog(@"hiddenNoUsersChannelSwithState = %d",swithState);
}

- (void)hiddenAllUsersChannel:(BOOL)swithState
{
    SSLog(@"hiddenAllUsersChannelSwithState = %d",swithState);
}

- (void)quickEnterChannel
{
    SSLog(@"quickEnterChannel");
}

#pragma mark -
#pragma mark CreatRoomDelegate
- (void)creatRoomWithChannelName:(NSString *)theChannelName
{
    NSString *channel = theChannelName;
    NSNumber *userid = [UserDataManager sharedUserDataManager].user.userid;
  
    NSDictionary *params = @{@"channel": channel,@"userid":userid};
    [self.pomelo requestWithRoute:@"connector.entryHandler.createRoom"
                        andParams:params
                      andCallback:^(NSDictionary *result) {
                          if ([[result objectForKey:@"code"] intValue] == 200) {
                              //成功
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
