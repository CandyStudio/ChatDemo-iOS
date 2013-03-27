//
//  RoomListTableViewCell.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "RoomListTableViewCell.h"
#import "RoomListTableViewHeader.h"

@implementation RoomListTableViewCell

#pragma mark -
#pragma mark life cycle
+ (RoomListTableViewCell *)creatRoomListCell
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RoomListTableViewCell" owner:nil options:nil];
    RoomListTableViewCell *cell = [arr objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    RoomListTableViewHeader *headerPos = [RoomListTableViewHeader createRoomListTableViewHeader];
    self.channelidLbl.frame = CGRectFromString(headerPos.channelidSortBtnFrame);
    SSLog(@"self.channelidLbl.frame = %@",NSStringFromCGRect(self.channelidLbl.frame));
    self.channelNameLbl.frame = CGRectFromString(headerPos.channelNameSortBtnFrame);
    self.channelOnlineNumLbl.frame = CGRectFromString(headerPos.channelOnlineNumSortBtnFrame);
    [self addSubview:self.channelidLbl];
    [self addSubview:self.channelNameLbl];
    [self addSubview:self.channelOnlineNumLbl];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
