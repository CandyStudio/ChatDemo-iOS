//
//  LodingView.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-23.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "LodingView.h"

@implementation LodingView

+ (LodingView *)loadingView
{
    
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float selfHeight = self.frame.size.height;
        float selfWidth = self.frame.size.width;
    }
    return self;
}


@end
