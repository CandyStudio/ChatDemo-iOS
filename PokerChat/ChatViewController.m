//
//  ChatViewController.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

////self.target 不在本地base64

#import "ChatViewController.h"
#import "LoginViewController.h"
#import "UserDataManager.h"
#import "UserData.h"
#import "Pomelo.h"
#import "base64.h"

#define CHAT_TABLEVIEW 100001
#define ONLINE_PLAYER_TABLEVIEW 100002

#define CHATLOGTYPE_ALL  0
#define CHATLOGTYPE_SINGLE  1

@interface ChatViewController ()

/**
 *chatStr 发送的文字
 */
@property (strong, nonatomic) NSMutableString *chatStr;
@property (strong, nonatomic) NSMutableArray *convertArray;
@end

@implementation ChatViewController


#pragma mark -
#pragma mark life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chatStr = [[NSMutableString alloc] initWithCapacity:10];
        self.contactList = [[NSMutableArray alloc] initWithCapacity:1];
        self.userDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.chatLogArray = [[NSMutableArray alloc] initWithCapacity:10];
        [self.contactList addObject:@{@"username": [@"All" base64EncodedString],
                                        @"userid":@0}];
        self.target = @{@"username": @"All",
                                @"userid":@0,
                                @"content":@""};
        self.tempArray = [[NSMutableArray alloc] initWithCapacity:10];
        self.convertArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.hasLoad = NO;
    }
    return self;
}
/**
 *对话
 */
- (void)initEvents
{
    [_pomelo onRoute:@"onChat" withCallback:^(NSDictionary *data) {
        SSLog(@"onChat...");
        SSLog(@"onChatData = %@",data);
        //是自己就不说
        SSLog(@"[[UserDataManager sharedUserDataManager].user.userid stringValue] = %@",[[UserDataManager sharedUserDataManager].user.userid stringValue]);
        SSLog(@"[data objectForKey: = %@",[data objectForKey:@"from_user_id"]);
       if  ( !([[data objectForKey:@"from_user_id"] intValue] == [[UserDataManager sharedUserDataManager].user.userid intValue]))
       {
           NSNumber *tid = [data objectForKey:@"tid"];
           NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
           [dict setObject:tid forKey:@"id"];
           [_chatLogArray addObject:dict];
           [self updateChat];
       }
    }];
}
/**
 *刷新onlinePlayerTableView上玩家信息。
 */
- (void)init2Events
{
    [_pomelo onRoute:@"onAdd" withCallback:^(NSDictionary *data) {
        SSLog(@"user add -----");
        SSLog(@"onAddData = %@",data);
        [self.onlinePlayerTableView beginUpdates];
        [_contactList addObject:data];
        self.numLabel.text = [NSString stringWithFormat:@"人数:%d",_contactList.count - 1];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_contactList count] - 1 inSection:0]];
        [self.onlinePlayerTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
        [self.onlinePlayerTableView endUpdates];
    }];
    [_pomelo onRoute:@"onLeave" withCallback:^(NSDictionary *data) {
        SSLog(@"user leave ----");
        SSLog(@"onLeave = %@",data);
        NSString *name = [data objectForKey:@"username"];
        
        int i =-1;
        int count = [_contactList count];
        for (int index = 0; index < count; index++) {
            if ([[[_contactList objectAtIndex:index] objectForKey:@"username"] isEqualToString:name]) {
                SSLog(@"index = %d",index);
                i = index;
                break;
            }
        }
        if (i!=-1) {
            [_contactList removeObjectAtIndex:i];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [self.onlinePlayerTableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        self.numLabel.text = [NSString stringWithFormat:@"人数:%d",_contactList.count - 1];
        self.target = @{@"username": @"All",@"userid":@0,@"content":@""};
    }];
}

/**
 *内存不够时清理
 */
- (void)viewDidUnload
{
    SSLog(@"viewDidUnload");
    self.chatTextView = nil;
    self.chatTextField = nil;
    self.chatStr = nil;
    self.target = nil;
    [self.pomelo offRoute:@"onChat"];
    [self setChatTableView:nil];
    _refreshHeaderView = nil;
    [super viewDidUnload];
}


/**
 *加载进来时布局
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_refreshHeaderView == nil) {
        RefreshHeaderView *refreshView = [[RefreshHeaderView alloc] initWithFrame:CGRectMake(0,-self.chatTableView.bounds.size.height, self.chatTableView.bounds.size.width, self.chatTableView.bounds.size.height)];
        refreshView.delegate = self;
        [self.chatTableView addSubview:refreshView];
        _refreshHeaderView = refreshView;
    }
    [_refreshHeaderView refreshLastUpdateDate];
    
    self.nameLabel.text = [NSString stringWithFormat:@"用户名：%@",[[self.userDic objectForKey:@"username"] base64DecodedString]];
    self.roomLabel.text = [NSString stringWithFormat:@"房间名：%@",[[UserDataManager sharedUserDataManager].user.channelName base64DecodedString]];
    self.numLabel.text = [NSString stringWithFormat:@"人数：%d",self.contactList.count - 1];
    [self initEvents];
    [self init2Events];
}
/**
 *键盘打开，chatTextField,chatBgView,chatTextView移动位置动画
 */
- (IBAction)chatEdit:(id)sender
{
    SSLog(@"chatEdit");
    //animation
    SSLog(@"chatanimation");
    float currentX = self.chatBgView.frame.origin.x;
    float currentY = self.chatBgView.frame.origin.y;
    float targetX = 27;
    float targetY = 118;
    float textFieldCurrentX = self.chatTextField.frame.origin.x;
    float textFieldCurrentY = self.chatTextField.frame.origin.y;
    float textFieldTargetX = 30;
    float textFieldTargetY = 340;
    float textViewCurrentX = self.chatTextView.frame.origin.x;
    float textViewCurrentY = self.chatTextView.frame.origin.y;
    float textViewTargetX = 30;
    float textViewTargetY = 119;
    float chatTableViewCurrentX = self.chatTableView.frame.origin.x;
    float chatTableViewCurrentY = self.chatTableView.frame.origin.y;
    float chatTableViewTargetX = 30;
    float chatTableVeiwTargetY = 119;
    [UIView beginAnimations:@"UIBase Move" context:nil];
    [UIView setAnimationDuration:.3];
    self.chatBgView.transform = CGAffineTransformMakeTranslation(targetX - currentX, targetY - currentY);
    self.chatBgView.frame = CGRectMake(27, 104, 576, 256);
    self.chatTextField.transform = CGAffineTransformMakeTranslation(textFieldTargetX - textFieldCurrentX, textFieldTargetY - textFieldCurrentY);
    self.chatTextField.frame = CGRectMake(30, 326, 576, 34);
    self.chatTextView.transform = CGAffineTransformMakeTranslation(textViewTargetX - textViewCurrentX, textViewTargetY - textViewCurrentY);
    self.chatTextView.frame = CGRectMake(30, 119, 576, 220);
    self.chatTableView.transform = CGAffineTransformMakeTranslation(chatTableViewTargetX - chatTableViewCurrentX, chatTableVeiwTargetY - chatTableViewCurrentY);
    self.chatTableView.frame = CGRectMake(30, 105, 576, 220);
    [UIView commitAnimations];
}
/**
 *完成编辑后回到原始状态。
 */
- (IBAction)chatEditEnd:(id)sender {
    SSLog(@"end");
    [UIView beginAnimations:@"UIBase Move" context:nil];
    [UIView setAnimationDuration:.4];
    self.chatBgView.transform = CGAffineTransformIdentity;
    [self.chatBgView setFrame:CGRectMake(27, 643, 576, 106)];
    self.chatTextField.transform = CGAffineTransformIdentity;
    [self.chatTextField setFrame:CGRectMake(30, 715, 359, 34)];
    self.chatTextView.transform = CGAffineTransformIdentity;
    [self.chatTextView setFrame:CGRectMake(30, 644, 359, 70)];
    self.chatTableView.transform = CGAffineTransformIdentity;
    [self.chatTableView setFrame:CGRectMake(30, 644, 359, 70)];
    [UIView commitAnimations];
}

/**
 *退出
 */
- (IBAction)exit:(id)sender {
    NSDictionary *params = @{@"userid": [UserDataManager sharedUserDataManager].user.userid,
                             @"username":[UserDataManager sharedUserDataManager].user.username};
    [self.pomelo requestWithRoute:@"connector.entryHandler.quit"
                        andParams:params
                      andCallback:^(NSDictionary *result) {
                      SSLog(@"quitResult=%@",result);
          if ([[result objectForKey:@"code"] intValue] == 200) {
              [self.navigationController popViewControllerAnimated:YES];
              [self.pomelo offRoute:@"onChat"];
              [self.pomelo offRoute:@"onLeave"];
              [self.pomelo offRoute:@"onAdd"];
            }
    }];
}

- (void)dealloc
{
    SSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    SSLog(@"beginEdit");
    return YES;
}

#pragma mark -
#pragma mark SocketIOTransportDelegate
- (void)onDisconnect:(NSError *)error
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *实现UItableViewDataSoure和UITableViewDelegate方法，填充onlinePlayerTableView
 */
#pragma mark -
#pragma mark UITableViewDataSource&&UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SSLog(@"self.contactList.count = %d",self.contactList.count);
    if (self.onlinePlayerTableView == tableView)
        return [self.contactList count];
    else {
        SSLog(@"用于显示多少行的chatLogArray = %@",self.chatLogArray);
        return [self.chatLogArray count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //onlinePlayerTableView && chatTableView
    if (self.onlinePlayerTableView == tableView) {
        static NSString *CellIdentifier = @"ContactsTableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSInteger row = indexPath.row;
        cell.textLabel.text = [[[self.contactList objectAtIndex:row] objectForKey:@"username"] base64DecodedString];
        if (row == 0) {
            cell.backgroundColor = [UIColor yellowColor];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"ContactsTableCell2";
        NSString *textStr = nil;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSInteger row = indexPath.row;
        SSLog(@"self.chatLogArrto_user_name = %@",[[[self.chatLogArray objectAtIndex:row] objectForKey:@"to_user_name"] base64DecodedString]);
        BOOL toTargetAll = [[[[_chatLogArray objectAtIndex:row] objectForKey:@"to_user_name"] base64DecodedString] isEqualToString:@"*"]; //如果是*表示对所有人说，否则私聊
        if (toTargetAll) {
            textStr = [NSString stringWithFormat:@"id_%@:%@说:%@",
                                   [[_chatLogArray objectAtIndex:row] objectForKey:@"id"],
                                   [[[_chatLogArray objectAtIndex:row] objectForKey:@"from_user_name"] base64DecodedString],
                                   [[[_chatLogArray objectAtIndex:row] objectForKey:@"context"] base64DecodedString ]];
        } else {
            textStr = [NSString stringWithFormat:@"id_%@:%@对%@说:%@",
                                   [[_chatLogArray objectAtIndex:row] objectForKey:@"id"],
                                   [[[_chatLogArray objectAtIndex:row] objectForKey:@"from_user_name"] base64DecodedString],
                                   [[[_chatLogArray objectAtIndex:row] objectForKey:@"to_user_name"] base64DecodedString],
                                   [[[_chatLogArray objectAtIndex:row] objectForKey:@"context"]base64DecodedString]];
        }
        cell.textLabel.text = textStr;
        //在heighrow 设置高
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.onlinePlayerTableView == tableView) {
        return @"online Player";
    } else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.onlinePlayerTableView == tableView) {
        return 44;
    } else
        return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.onlinePlayerTableView == tableView) {
        
        NSDictionary *cellDic = [self.contactList objectAtIndex:indexPath.row];
        SSLog(@"self.target for username = %@",[cellDic objectForKey:@"username"]);
        SSLog(@"base64EncodedString:self.target for username = %@",[[cellDic objectForKey:@"username"] base64DecodedString]);
        if ([[[cellDic objectForKey:@"username"] base64DecodedString] isEqualToString:@"All"]) {
            self.target = @{@"username": [[cellDic objectForKey:@"username"] base64DecodedString],
                            @"userid":@0};
            SSLog(@"self.targetAll=%@",self.target);
        } else {
            self.target = @{@"username": [[cellDic objectForKey:@"username"] base64DecodedString],
                            @"userid":[cellDic objectForKey:@"userid"]};
            SSLog(@"self.targetSingle = %@",self.target);
        }
    } else
        SSLog(@"indexPath = %@",indexPath);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.chatTableView) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        NSString *textStr2 = cell.textLabel.text;
        SSLog(@"textStr2 = %@",textStr2);
        CGFloat conentWidth = self.chatTableView.frame.size.width - 25;
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [textStr2 sizeWithFont:font constrainedToSize:CGSizeMake(conentWidth, 5000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        SSLog(@"textSize = %@",NSStringFromCGSize(size));
        return size.height + 5;
    } else {
        return 44;
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

/**
 *下拉刷新，一次只显示10条
 */
- (void)doneLoadingTableViewData
{
     if (!self.hasLoad) {
        NSNumber *userid = [UserDataManager sharedUserDataManager].user.userid;
        NSNumber *roomid = [self.userDic objectForKey:@"roomid"];
        NSDictionary *params = @{@"userid": userid,
                                  @"roomid": roomid};
        SSLog(@"query paramas = %@",params);
        [self.pomelo requestWithRoute:@"chat.chatHandler.query"
                            andParams:params
                          andCallback:^(NSDictionary *result) {
                              SSLog(@"query result = %@", result);
                              if ([[result objectForKey:@"code"] intValue] == 200) {
                                  if ([[result objectForKey:@"chatlog"] count] == 0) {
                                      return ;
                                  }
                                  //传回来的是降序 所以直接加到tempArray里面
                                  [self.tempArray addObjectsFromArray:[result objectForKey:@"chatlog"]];
                                  SSLog(@"tempArray = %@",self.tempArray);
                                  [self.chatLogArray removeAllObjects];
                                  for (int i = 0; i < 10 && [self.tempArray count] > 0; i++) {
                                      [self.chatLogArray addObject:[self.tempArray objectAtIndex:0]];
                                      [self.tempArray removeObjectAtIndex:0];
                                  }
                                  //对chatLogArray排列
                                  NSSortDescriptor *chat_sort_by_id = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
                                  [self.chatLogArray sortUsingDescriptors:[NSMutableArray arrayWithObject:chat_sort_by_id]];
                                   SSLog(@"升序排序后的chatLogArray = %@",self.chatLogArray);
                                  [self.chatTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                              }
                              self.hasLoad = YES;
        }];
    } else {
        for (int i = 0; i < 10 && [self.tempArray count] > 0; i++) {
            [self.chatLogArray addObject:[self.tempArray objectAtIndex:0]];
            [self.tempArray removeObjectAtIndex:0];
        }
        NSSortDescriptor *chat_sort_by_id = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
        [self.chatLogArray sortUsingDescriptors:[NSMutableArray arrayWithObject:chat_sort_by_id]];
        [self.chatTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.chatTableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.chatTableView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.chatTableView];
}

#pragma mark -
#pragma mark RefreshHeaderViewDelegate
- (void)egoRefreshHeaderDidTriggerRefresh:(RefreshHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshHeaderDataSourceIsLoading:(RefreshHeaderView *)view
{
    return _reloading;
}

- (NSDate *)egoRefreshHeaderDataSourceLastUpdated:(RefreshHeaderView *)view
{
    return [NSDate date];
}

/**
 *实现UITextViewDelegate方法，发送聊天消息。
 */
#pragma mark -
#pragma mark UITextViewDelegate
/**
 *key Return键发送
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    SSLog(@"should Return");
    //对所有人userid为空
    SSLog(@"self.target = %@",self.target);
    NSNumber *type = @([[self.target objectForKey:@"username"] isEqualToString:@"All"]?CHATLOGTYPE_ALL:CHATLOGTYPE_SINGLE);
    SSLog(@"target type = %@",type);
    SSLog(@"userDic = %@",self.userDic);
    SSLog(@"_chatTextField.text base64EncodedString = %@",[_chatTextField.text base64EncodedString]);
    if ([_chatTextField.text base64EncodedString] == NULL) {
        SSLog(@"输入为空");
    } else {
        NSDictionary *params = @{@"target": [[self.target objectForKey:@"username"] isEqualToString:@"All"]?[@"*" base64EncodedString]:[[self.target objectForKey:@"username"] base64EncodedString],
                                 @"userid":[self.target objectForKey:@"userid"]?[self.target objectForKey:@"userid"]:@0,
                                 @"content":[_chatTextField.text base64EncodedString],
                                 @"roomid":[self.userDic objectForKey:@"roomid"],
                                 @"type":type
                                 };
        SSLog(@"shouldReturn Params = %@",params);
        if ([[self.target objectForKey:@"username"] isEqualToString:[[self.userDic objectForKey:@"username"] base64DecodedString]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"不能对自己讲话"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];

        } else {
            [_pomelo requestWithRoute:@"chat.chatHandler.send"
                            andParams:params
                          andCallback:^(NSDictionary *result) {
                              SSLog(@"chatHandler.send = %@",result);
                              if ([[result objectForKey:@"code"] intValue] == 200) {
                                  [_chatLogArray addObject:[result objectForKey:@"chat"]];
                                  //TODO:刷新数组
                                  [self updateChat];
                              } else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"发送失败"
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil, nil];
                                  [alert show];
                              }
                          }];
        }
    }
    _chatTextField.text = @"";
    return YES;
}
/**
 *更新chatTextView内容，文字能自动滑到最后一行
 */
- (void)updateChat
{
    //bug here!
    [self.chatTableView beginUpdates];
    NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_chatLogArray count] - 1 inSection:0]];
    [self.chatTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
    [self.chatTableView endUpdates];
    
    [self.chatTableView scrollRectToVisible:CGRectMake(0, _chatTableView.contentSize.height-30, _chatTableView.contentSize.width, 50) animated:YES];
}

@end
