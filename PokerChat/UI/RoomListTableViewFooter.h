//
//  RoomListTableViewFooter.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-26.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoomListTableViewFooter;
@protocol RoomListTableViewFooterDelegate <NSObject>
- (void)hiddenNoUsersChannel:(BOOL)swithState;
- (void)hiddenAllUsersChannel:(BOOL)swithState;
- (void)quickEnterChannel;
@end

@interface RoomListTableViewFooter : UIView

@property (assign,nonatomic) id<RoomListTableViewFooterDelegate>delegate;
@property (weak, nonatomic) IBOutlet UISwitch *hiddenNoUsersChannelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hiddenAllUsersChannelSwitch;
@property (weak, nonatomic) IBOutlet UILabel *noUsersLbl;
@property (weak, nonatomic) IBOutlet UILabel *allUsersLbl;
@property (weak, nonatomic) IBOutlet UIButton *quickEnterChannelBtn;
@property (weak, nonatomic) IBOutlet UILabel *onlineUserLbl;
@property (weak, nonatomic) IBOutlet UILabel *onlineUserNumLbl;

+ (RoomListTableViewFooter *)createRoomListTableViewFooter;
@end
