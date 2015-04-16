//
//  PCTextField.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCTextField.h"
#import "Config.h"

@implementation PCTextField



+ (PCTextField *)textFieldWithFrame:(CGRect)frame
{
    PCTextField *textField = [[PCTextField alloc] initWithFrame:frame];
    
    textField.backgroundColor = [UIColor whiteColor];
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 8.0f, 20.0f)];;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.textColor = [UIColor darkGrayColor];
    textField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.layer.borderWidth = 0.5f;
    textField.layer.cornerRadius = 3.0f;
    textField.layer.masksToBounds = YES;

    
    return textField;
}

@end
