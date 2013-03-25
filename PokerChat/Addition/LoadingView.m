//
//  LodingView.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-23.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

+ (LoadingView *)loadingView
{
    
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float selfHeight = self.frame.size.height;
        float selfWidth = self.frame.size.width;
        self.center = CGPointMake(selfWidth / 2, selfHeight / 2);
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
        
        UIView *loadingFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100 *Content_Size, 100 * Content_Size)];
        loadingFrame.center = self.center;
        loadingFrame.layer.backgroundColor = [UIColor blackColor].CGColor;
        loadingFrame.layer.cornerRadius = 4 * Content_Size;
        loadingFrame.layer.masksToBounds = YES;
        loadingFrame.layer.opacity = .5;
        [self addSubview:loadingFrame];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(selfWidth / 2, selfHeight / 2);
        [spinner startAnimating];
        [self addSubview:spinner];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    return;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    return;
}

@end
