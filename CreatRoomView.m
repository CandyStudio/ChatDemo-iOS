//
//  creatRoomView.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "CreatRoomView.h"

@implementation CreatRoomView


#pragma mark -
#pragma mark life cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CreatRoomView *)creatRoomViewWithDelegate:(id)theDelegate
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"CreatRoomView" owner:nil options:nil];
    CreatRoomView *view = [arr objectAtIndex:0];
    view.delegate = theDelegate;
    return view;
}

- (IBAction)clickCreatRoom:(id)sender
{
    [self creatRoom];
}
- (IBAction)editEndCreatRoom:(id)sender
{
    [self creatRoom];
}

- (void)creatRoom
{
    NSString *creatChannelName = _creatRoomTextField.text;
    if ([creatChannelName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"房间名不能为空"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(creatRoomWithChannelName:)]) {
            [self.delegate creatRoomWithChannelName:creatChannelName];
            [self close];
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:_confirmBtn];
    [self addSubview:_creatRoomLbl];
    [self addSubview:_backBtn];
    [self addSubview:_creatRoomTextField];
}

#pragma mark -
#pragma mark Public Methods


#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
