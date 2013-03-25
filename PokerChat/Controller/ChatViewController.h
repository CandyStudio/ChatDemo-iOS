//
//  ChatViewController.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-7.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//
/*!
    @header ChatView
    @discussion 聊天室
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Pomelo.h"
#import "RefreshHeaderView.h"
/*!
    @class ChatViewController
    @superclass UIViewController
 */
@interface ChatViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,RefreshHeaderViewDelegate,SocketIOTransportDelegate>

@property (strong, nonatomic) RefreshHeaderView *refreshHeaderView;
@property (assign, nonatomic) BOOL reloading;
/**
 *chatTextField
 */
@property (strong, nonatomic) IBOutlet UITextField *chatTextField;
/**
 *chatBgView背景
 */
@property (strong, nonatomic) IBOutlet UIView *chatBgView;
/**
 *chatText
 */
@property (strong, nonatomic) IBOutlet UITextView *chatTextView;
/**
 *headImage头像
 */
@property (strong, nonatomic) IBOutlet UIImageView *headImg;
/**
 *nameLabel
 */
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
/**
 *roomLabel
 */
@property (strong, nonatomic) IBOutlet UILabel *roomLabel;
/**
 *人数
 */
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
/**
 *exitButton
 */
@property (strong, nonatomic) IBOutlet UIButton *exitBtn;
/**
 *onlinePlayerTableView 在线玩家
 */
@property (strong, nonatomic) IBOutlet UITableView *onlinePlayerTableView;

/**
 *chatTableView 聊天
 */
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
/**
 *pomelo
 */
@property (strong, nonatomic) Pomelo *pomelo;
/**
 *target 对话的对象
 */
@property (strong, nonatomic) NSDictionary *target;
/**
 *保存在线玩家
 */
@property (strong, nonatomic) NSMutableArray *contactList;
/**
 *保存个人玩家基本信息。
 */
@property (strong, nonatomic) NSMutableDictionary *userDic;
/**
 *显示的聊天记录
 */
@property (strong, nonatomic) NSMutableArray *chatLogArray;

/**
 *接受总的聊天记录
 */
@property (strong, nonatomic) NSMutableArray *tempArray;

/**
 *已经load过
 */
@property (assign,nonatomic) BOOL hasLoad;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
//方法的规范注释
/*!
 @method        方法名
 @param         参数（类型）
 @abstract      简要
 @discussion    详细
 @result        结果
 */
