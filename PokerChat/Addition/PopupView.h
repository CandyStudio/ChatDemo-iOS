//
//  PopupView.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupView;

@protocol PopupViewDelegate <NSObject>
- (void)popupView:(PopupView *)popupView willCloseAnimate:(BOOL)animate;
- (void)popupView:(PopupView *)popupView didCloseAnimate:(BOOL)animate;
@end

@interface PopupView : UIView

@property (weak, nonatomic) id<PopupViewDelegate>delegate;
@property (strong, nonatomic) UIButton *touchBtn;
@property (assign, nonatomic) BOOL closeAbsorb;
@property (strong, nonatomic) UIView *parentView;

- (IBAction)clickClose:(id)sender;
- (IBAction)clickCloseWithAnimation:(id)sender;
- (void)close;
@end
