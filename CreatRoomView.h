//
//  creatRoomView.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "PopupView.h"

@class CreatRoomView;
@protocol CreatRoomViewDelegate <NSObject>
- (void)creatRoomWithChannelName:(NSString *)theChannelName;
@end

@interface CreatRoomView : PopupView

@property (assign, nonatomic) id<CreatRoomViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *creatRoomLbl;
@property (weak, nonatomic) IBOutlet UITextField *creatRoomTextField;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

+ (CreatRoomView *)creatRoomViewWithDelegate:(id)theDelegate;
- (IBAction)clickCreatRoom:(id)sender;

@end
