//
//  RoomListTableViewHeader.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-26.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoomListTableViewHeader;
@protocol RoomListTableViewHeaderDelegate <NSObject>
- (void)channelSortByChannelid;
- (void)channelSortByChannelName;
- (void)channelSortByChannelOnlineNumber;
@end

@interface RoomListTableViewHeader : UIView

@property (assign, nonatomic) id <RoomListTableViewHeaderDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *channelidSortBtn;
@property (weak, nonatomic) IBOutlet UIButton *channelNameSortBtn;
@property (weak, nonatomic) IBOutlet UIButton *channelOnlineNumSortBtn;
@property (copy, nonatomic) NSString *channelidSortBtnFrame;
@property (copy, nonatomic) NSString *channelNameSortBtnFrame;
@property (copy, nonatomic) NSString *channelOnlineNumSortBtnFrame;
+ (RoomListTableViewHeader *)createRoomListTableViewHeader;

@end
