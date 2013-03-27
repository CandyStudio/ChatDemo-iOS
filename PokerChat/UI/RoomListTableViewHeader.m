//
//  RoomListTableViewHeader.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-26.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "RoomListTableViewHeader.h"


@implementation RoomListTableViewHeader

#pragma mark -
#pragma mark life cycle
+ (RoomListTableViewHeader *)createRoomListTableViewHeader
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RoomListTableViewHeader" owner:nil options:nil];
    RoomListTableViewHeader *roomlistHeader = [arr objectAtIndex:0];
    return roomlistHeader;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.channelidSortBtnFrame = NSStringFromCGRect(CGRectMake(self.channelidSortBtn.frame.origin.x + 25, self.channelidSortBtn.frame.origin.y, self.channelidSortBtn.frame.size.width, self.channelidSortBtn.frame.size.height));
    self.channelNameSortBtnFrame = NSStringFromCGRect(CGRectMake(self.channelNameSortBtn.frame.origin.x + 10, self.channelNameSortBtn.frame.origin.y, self.channelNameSortBtn.frame.size.width, self.channelNameSortBtn.frame.size.height));
    self.channelOnlineNumSortBtnFrame = NSStringFromCGRect(CGRectMake(self.channelOnlineNumSortBtn.frame.origin.x + 25, self.channelOnlineNumSortBtn.frame.origin.y, self.channelOnlineNumSortBtn.frame.size.width, self.channelOnlineNumSortBtn.frame.size.height));
}


#pragma mark -
#pragma mark IBActions
- (IBAction)channelidSortBtnTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelSortByChannelid)]) {
        [self.delegate channelSortByChannelid];
    }
}
- (IBAction)channelNameSortBtnTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelSortByChannelName)]) {
        [self.delegate channelSortByChannelName];
    }
}
- (IBAction)channelOnlineNumSortBtnTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelSortByChannelOnlineNumber)]) {
        [self.delegate channelSortByChannelOnlineNumber];
    }
}


@end
