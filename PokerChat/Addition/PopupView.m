//
//  PopupView.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "PopupView.h"
#import "AppDelegate.h"

#define WINDOW [[[UIApplication sharedApplication] delegate] window]

@interface PopupView(PrivateMethod)
- (void)willClose;
- (void)didShow;
- (void)didClose;
@end

@implementation PopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _touchBtn = [[UIButton alloc] initWithFrame:CGRectMake(-(WINDOW.frame.size.height - self.frame.size.width) / 2, - (WINDOW.frame.size.width - self.frame.size.height) / 2, WINDOW.frame.size.height, WINDOW.frame.size.width)];
        _closeAbsorb = NO;
        [self addSubview:_touchBtn];
    }
    return self;
}

#pragma mark - 
#pragma mark public methods
- (IBAction)clickClose:(id)sender
{
    [self willClose];
    [self removeFromSuperview];
    [self didClose];
}

- (void)close
{
    [self willClose];
    [self removeFromSuperview];
    [self didClose];
}

#pragma mark -
#pragma mark private methods
- (void)willClose
{
    if (_delegate && [_delegate respondsToSelector:@selector(popupView:willCloseAnimate:)]) {
        [_delegate popupView:self willCloseAnimate:YES];
    }
}

- (void)didClose
{
    if (_delegate && [_delegate respondsToSelector:@selector(popupView:didCloseAnimate:)]) {
        [_delegate popupView:self didCloseAnimate:YES];
    }
}

@end
