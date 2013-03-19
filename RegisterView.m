//
//  RegisterView.m
//  PokerChat
//
//  Created by 束 永兴 on 13-3-19.
//  Copyright (c) 2013年 Vienta.su. All rights reserved.
//

#import "RegisterView.h"

@implementation RegisterView


#pragma mark -
#pragma mark life cycle

+ (RegisterView *)createRegisterViewWithDelegate:(id)theDelegate
{
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"RegisterView" owner:nil options:nil];
    RegisterView *view = [arr objectAtIndex:0];
    view.delegate = theDelegate;
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:_confirmBtn];
    [self addSubview:_registerNameTextField];
    [self addSubview:_registerPasswordTextField];
    [self addSubview:_confirmPasswordTextField];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Public methods 

- (IBAction)registerConfirmTapped:(id)sender
{
    SSLog(@"registerTap");
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
                    [self.delegate userRegisterWithName:_registerNameTextField.text andPassword:_registerPasswordTextField.text];
                }
                [self close];
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
@end
