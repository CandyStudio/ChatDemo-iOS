//
//  RoomViewController.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-14.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pomelo.h"
#import "CreatRoomView.h"
#import "RoomListTableViewHeader.h"
#import "RoomListTableViewFooter.h"
@interface RoomViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,CreatRoomViewDelegate,UIAlertViewDelegate,RoomListTableViewHeaderDelegate,RoomListTableViewFooterDelegate>
@property (weak, nonatomic) IBOutlet UITextField *creatRoomTextField;
@property (weak, nonatomic) IBOutlet UIButton *creatRoomButton;
@property (weak, nonatomic) IBOutlet UITableView *romeList;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UILabel *useridLbl;
@property (weak, nonatomic) IBOutlet UIImageView *userheadImgView;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (strong,nonatomic) NSMutableArray *roomlistArray;
@property (strong,nonatomic) NSMutableDictionary *onlineDict;
@property (strong,nonatomic) Pomelo *pomelo;
@property (strong,nonatomic) LoadingView *spinner;
@end
