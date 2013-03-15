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

@protocol RefreshHeaderViewDelegat<NSObject>

- (void)egoRefreshHeaderDidTriggerRefresh:(RefreshHeaderView *)view;
- (void)egoRefreshHeaderDataSourceIsLoading:(RefreshHeaderView *)view;
@optional
- (NSDate *)egoRefreshHeaderDataSourceLastUpdated:(RefreshHeaderView *)view;

@end

@interface RefreshHeaderView : UIView

@property (weak, nonatomic) id<RefreshHeaderViewDelegat>delegate;
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
