//
//  RoomListTableViewFooter.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-26.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "RoomListTableViewFooter.h"

@implementation RoomListTableViewFooter

#pragma mark -
#pragma mark life cycle
+ (RoomListTableViewFooter *)createRoomListTableViewFooter
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RoomListTableViewFooter" owner:nil options:nil];
    RoomListTableViewFooter *roomlistFooter = [arr objectAtIndex:0];
    return roomlistFooter;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)hiddenNoUsersChannel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenNoUsersChannel:)]) {
        [self.delegate hiddenNoUsersChannel:self.hiddenNoUsersChannelSwitch.on];
    }
}

- (IBAction)hiddenAllUsersChannel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenAllUsersChannel:)]) {
        [self.delegate hiddenAllUsersChannel:self.hiddenAllUsersChannelSwitch.on];
    }
}

- (IBAction)quickEnterChannel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(quickEnterChannel)]) {
        [self.delegate quickEnterChannel];
    }
}

@end
