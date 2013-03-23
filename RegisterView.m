//
//  RegisterView.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//
//
//
// 所有本地储存的string 类型 均用base64加密后储存

#import "RegisterView.h"
#import "base64.h"

@implementation RegisterView


#pragma mark -
#pragma mark life cycle

+ (RegisterView *)createRegisterViewWithDelegate:(id)theDelegate addParentView:(UIView *)theParentView;
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RegisterView" owner:nil options:nil];
    RegisterView *view = [arr objectAtIndex:0];
    view.delegate = theDelegate;
    view.parentView = theParentView; 
    
    if (view.parentView && [view.parentView isKindOfClass:[UIView class]]) {
        [view.parentView addSubview:view];
    }
    
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:_confirmBtn];
    [self addSubview:_registerNameTextField];
    [self addSubview:_registerPasswordTextField];
    [self addSubview:_confirmPasswordTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)nofi
{
    SSLog(@"keyboardWillShow");
}

- (void)keyboardWillHide:(NSNotification *)nofi
{
    SSLog(@"keyboardWillHide");
    self.frame = CGRectMake(0, 0, 1024, 768);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)clickBack:(id)sender
{
    [super close];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)close
{
    [super close];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark -
#pragma mark Public methods 

- (IBAction)registerConfirmTapped:(id)sender
{
    SSLog(@"registerTap");
    [self confirmRegister];
}

- (void)confirmRegister
{
    NSString *registerName = _registerNameTextField.text;
    NSString *registerPassword = _registerPasswordTextField.text;
    NSString *againPassword = _confirmPasswordTextField.text;
    
    //注册名字要求
    if ([registerName length] >= 4 && [registerName length] <= 12) {
        //密码要求
        if ([registerPassword isEqualToString:againPassword]) {
            if ([registerPassword length] >= 4 && [registerPassword length] <= 12) {
                //所有的都符合 进入delegate
                SSLog(@"registerName=%@",registerName);
                SSLog(@"registerPassword=%@",registerPassword);
                if (self.delegate && [self.delegate respondsToSelector:@selector(userRegisterWithName:andPassword:)]) {
                    [self.delegate userRegisterWithName:_registerNameTextField.text 
                                            andPassword:_registerPasswordTextField.text];
                }
            } else {
                //密码长度不合要求
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"密码长度不合要求"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
        } else {
            //前后密码不一致
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"前后密码不一致"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    } else {
        //昵称不对
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"昵称不符合要求"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }

}

- (IBAction)textFieldEditEnd:(id)sender
{
    SSLog(@"registtextFieldEditEnd");
    UITextField *selectTextField = (id)sender;
    if (selectTextField == _registerNameTextField) {
        SSLog(@"registtextFieldEditEnd1");
        [_registerPasswordTextField becomeFirstResponder];
    } else if (selectTextField == _registerPasswordTextField) {
        SSLog(@"registtextFieldEditEnd2");
        [_registerPasswordTextField resignFirstResponder];
        [_confirmPasswordTextField becomeFirstResponder];
        if (self.parentView && [self.parentView isKindOfClass:[UIView class]]) {
            CGRect rect = self.frame;
            self.frame = CGRectMake(0, -60, 1024, 768);
            SSLog(@"rect = %@",NSStringFromCGRect(rect));
        }

    } else if (selectTextField == _confirmPasswordTextField) {
        SSLog(@"registtextFieldEditEnd3");
        self.frame = CGRectMake(0, 0, 1024, 768);
        [self confirmRegister];
        [_confirmPasswordTextField resignFirstResponder];
    }
}
#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _confirmPasswordTextField) {
        SSLog(@"conf");
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _confirmPasswordTextField) {
        SSLog(@"_confirmPasswordTextField");
        self.frame = CGRectMake(0, -60, 1024, 768);
    }
    return YES;
}

@end
