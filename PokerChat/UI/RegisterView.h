//
//  RegisterView.h
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "PopupView.h"

@class RegisterView;
@protocol RegisterViewDelegate <NSObject>
- (void)userRegisterWithName:(NSString *)theName andPassword:(NSString *)thePassword;
@end

@interface RegisterView : PopupView<UITextFieldDelegate>

@property (assign, nonatomic) id<RegisterViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *registerNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic)LoadingView *spinner;

+ (RegisterView *)createRegisterViewWithDelegate:(id)theDelegate addParentView:(id)parentView;

- (IBAction)registerConfirmTapped:(id)sender;
@end
