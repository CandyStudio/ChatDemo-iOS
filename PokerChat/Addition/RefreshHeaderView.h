//
//  RefreshHeaderView.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-15.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
typedef enum
{
    PullRefreshStatePulling,
    PullRefreshStateNormal,
    PullRefreshStateLoading,
}PullRefreshState;

@class RefreshHeaderView;

@protocol RefreshHeaderViewDelegate<NSObject>

- (void)egoRefreshHeaderDidTriggerRefresh:(RefreshHeaderView *)view;
- (BOOL)egoRefreshHeaderDataSourceIsLoading:(RefreshHeaderView *)view;
@optional
- (NSDate *)egoRefreshHeaderDataSourceLastUpdated:(RefreshHeaderView *)view;

@end

@interface RefreshHeaderView : UIView
{

    PullRefreshState _state;
    UILabel *_lastUpdateLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
}

@property (weak, nonatomic) id<RefreshHeaderViewDelegate>delegate;
@property (assign, nonatomic) PullRefreshState state;
@property (strong, nonatomic) UILabel *lastUpdateLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) CALayer *arrowImage;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

- (void)refreshLastUpdateDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
