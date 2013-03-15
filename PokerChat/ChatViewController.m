//
//  ChatViewController.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "ChatViewController.h"
#import "LoginViewController.h"
#import "UserDataManager.h"
#import "UserData.h"

@interface ChatViewController ()
/**
 *chatStr 发送的文字
 */
@property (strong, nonatomic) NSMutableString *chatStr;
@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chatStr = [[NSMutableString alloc] initWithCapacity:10];
        self.contactList = [[NSMutableArray alloc] initWithCapacity:1];
        self.userDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self.contactList addObject:@{@"username": @"All"}];
        self.target = @"*";
        NSLog(@"self.contactList = %@",self.contactList);
    }
    return self;
}
/**
 *对话
 */
- (void)initEvents
{
    [_pomelo onRoute:@"onChat" withCallback:^(NSDictionary *data) {
        NSLog(@"onChat...");
        NSString *target = [[data objectForKey:@"target"] isEqualToString:@"*"]?@"":@" to you";
        [_chatStr appendFormat:@"%@ says%@: %@\n",[data objectForKey:@"from"], target, [data objectForKey:@"msg"]];
        [self updateChat];
    }];
}
/**
 *刷新onlinePlayerTableView上玩家信息。
 */
- (void)init2Events
{
    [_pomelo onRoute:@"onAdd" withCallback:^(NSDictionary *data) {
        NSLog(@"user add -----");
        NSLog(@"onAdd = %@",data);
        NSString *name = [data objectForKey:@"username"];
        
        [self.onlinePlayerTableView beginUpdates];
        [_contactList addObject:name];
        self.numLabel.text = [NSString stringWithFormat:@"人数:%d",_contactList.count];
        NSLog(@"addContactList=%@",_contactList);
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_contactList count] - 1 inSection:0]];
        [self.onlinePlayerTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
        [self.onlinePlayerTableView endUpdates];        
    }];
    [_pomelo onRoute:@"onLeave" withCallback:^(NSDictionary *data) {
        NSLog(@"user leave ----");
        NSString *name = [data objectForKey:@"user"];
        NSLog(@"leaveContactList=%@",name);
        if ([_contactList containsObject:name]) {
            NSUInteger index = [_contactList indexOfObject:name];
            [_contactList removeObjectAtIndex:index];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
            [self.onlinePlayerTableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
            self.numLabel.text = [NSString stringWithFormat:@"人数:%d",_contactList.count];
        }
    }];
}
/**
 *内存不够时清理
 */
- (void)viewDidUnload
{
    NSLog(@"viewDidUnload");
    self.chatTextView = nil;
    self.chatTextField = nil;
    self.chatStr = nil;
    self.target = nil;
    [self.pomelo offRoute:@"onChat"];
    [super viewDidUnload];
}

/**
 *加载进来时布局
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = [NSString stringWithFormat:@"昵称：%@",[self.userDic objectForKey:@"username"]];
    self.roomLabel.text = [NSString stringWithFormat:@"房间：%@",[self.userDic objectForKey:@"channel"]];
    self.numLabel.text = [NSString stringWithFormat:@"人数：%d",self.contactList.count];
    [self initEvents];
    [self init2Events];
}

/**
 *键盘打开，chatTextField,chatBgView,chatTextView移动位置动画
 */
- (IBAction)chatEdit:(id)sender
{
    NSLog(@"chatEdit");
    //animation
    NSLog(@"chatanimation");
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
    [UIView beginAnimations:@"UIBase Move" context:nil];
    [UIView setAnimationDuration:.3];
    self.chatBgView.transform = CGAffineTransformMakeTranslation(targetX - currentX, targetY - currentY);
    self.chatBgView.frame = CGRectMake(27, 118, 365, 256);
    self.chatTextField.transform = CGAffineTransformMakeTranslation(textFieldTargetX - textFieldCurrentX, textFieldTargetY - textFieldCurrentY);
    self.chatTextField.frame = CGRectMake(30, 340, 359, 34);
    self.chatTextView.transform = CGAffineTransformMakeTranslation(textViewTargetX - textViewCurrentX, textViewTargetY - textViewCurrentY);
    self.chatTextView.frame = CGRectMake(30, 119, 359, 220);
    [UIView commitAnimations];
}
/**
 *完成编辑后回到原始状态。
 */
- (IBAction)chatEditEnd:(id)sender {
    NSLog(@"end");
    [UIView beginAnimations:@"UIBase Move" context:nil];
    [UIView setAnimationDuration:.4];
    self.chatBgView.transform = CGAffineTransformIdentity;
    [self.chatBgView setFrame:CGRectMake(27, 643, 576, 106)];
    self.chatTextField.transform = CGAffineTransformIdentity;
    [self.chatTextField setFrame:CGRectMake(30, 715, 359, 34)];
    self.chatTextView.transform = CGAffineTransformIdentity;
    [self.chatTextView setFrame:CGRectMake(30, 644, 359, 70)];
    [UIView commitAnimations];
}

/**
 *退出
 */
- (IBAction)exit:(id)sender {
    NSLog(@"exit");
    [self.pomelo disconnect];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"beginedit");
    return YES;
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
    return self.contactList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSInteger row = indexPath.row;
    NSLog(@"contactList=%@",[self.contactList objectAtIndex:row]);
    cell.textLabel.text = [[self.contactList objectAtIndex:row] objectForKey:@"username"];
//    在线玩家的名称
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"online Player";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellStr = [[self.contactList objectAtIndex:indexPath.row] objectForKey:@"All"];
    NSLog(@"cell = %@",cellStr);
    if ([cellStr isEqualToString:@"All"]){
        self.target = @"*";
    } else {
        self.target = cellStr;
    }
}

/**
 *实现UITextViewDelegate方法，发送聊天消息。
 */
#pragma mark -
#pragma mark UITextViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"should Return");
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          _chatTextField.text, @"content",
                          self.target, @"target",[UserDataManager sharedUserDataManager].user.userid,@"userid",
                          nil];
    NSLog(@"data=%@",data);
    if ([[data objectForKey:@"content"] isEqual:@""]) {
        NSLog(@"输入为空");  //这段逻辑以后可能会用
    } else {
        if ([self.target isEqualToString:@"*"]) {
            [_pomelo notifyWithRoute:@"chat.chatHandler.send" andParams:data];
        } else {
            [_pomelo requestWithRoute:@"chat.chatHandler.send" andParams:data andCallback:^(NSDictionary *result) {
                [_chatStr appendFormat:@"you says to %@: %@\n",self.target, [data objectForKey:@"content"]];
                [self updateChat];
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
    self.chatTextView.text = _chatStr;
    [self.chatTextView scrollRectToVisible:CGRectMake(0, _chatTextView.contentSize.height-30, _chatTextView.contentSize.width, 10) animated:YES];
}

@end
