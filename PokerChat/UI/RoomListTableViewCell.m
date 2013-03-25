//
//  RoomListTableViewCell.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "RoomListTableViewCell.h"

@implementation RoomListTableViewCell

+ (RoomListTableViewCell *)creatRoomListCell
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RoomListTableViewCell" owner:nil options:nil];
    RoomListTableViewCell *cell = [arr objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
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
