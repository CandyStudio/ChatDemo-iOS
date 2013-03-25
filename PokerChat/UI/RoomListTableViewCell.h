//
//  RoomListTableViewCell.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *channelidLbl;
@property (weak, nonatomic) IBOutlet UILabel *channelNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *channelOnlineNumLbl;

+ (RoomListTableViewCell *)creatRoomListCell;
@end
