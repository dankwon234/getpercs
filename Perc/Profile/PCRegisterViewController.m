//
//  PCRegisterViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCRegisterViewController.h"

@interface PCRegisterViewController ()
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *phoneField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *promoCodeField;
@end

@implementation PCRegisterViewController


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgCoffee.png"]];
    CGRect frame = view.frame;
    
    static CGFloat x = 20.0f;
    CGFloat y = 0.12f*frame.size.height;
    CGFloat width = frame.size.width;
    
    UILabel *lblSignup = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblSignup.textColor = [UIColor whiteColor];
    lblSignup.textAlignment = NSTextAlignmentCenter;
    lblSignup.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblSignup.text = @"Sign Up";
    [view addSubview:lblSignup];
    y += lblSignup.frame.size.height+32.0f;


    CGFloat h = 44.0f;
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.nameField.delegate = self;
    self.nameField.placeholder = @"Full Name";
    self.nameField.returnKeyType = UIReturnKeyNext;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 44.0f)];;
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.backgroundColor = [UIColor whiteColor];
    self.nameField.alpha = 0.8f;
    self.nameField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.nameField.textColor = [UIColor darkGrayColor];
    [view addSubview:self.nameField];
    y += self.nameField.frame.size.height+1.0f;

    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.emailField.delegate = self;
    self.emailField.placeholder = @"Email";
    self.emailField.returnKeyType = UIReturnKeyNext;
    self.emailField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 44.0f)];;
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    self.emailField.backgroundColor = [UIColor whiteColor];
    self.emailField.alpha = 0.8f;
    self.emailField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.emailField.textColor = [UIColor darkGrayColor];
    [view addSubview:self.emailField];
    y += self.emailField.frame.size.height+1.0f;

    self.phoneField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.phoneField.delegate = self;
    self.phoneField.placeholder = @"Phone (We text you when your order is ready)";
    self.phoneField.returnKeyType = UIReturnKeyNext;
    self.phoneField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 44.0f)];;
    self.phoneField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneField.backgroundColor = [UIColor whiteColor];
    self.phoneField.alpha = 0.8f;
    self.phoneField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.phoneField.textColor = [UIColor darkGrayColor];
    [view addSubview:self.phoneField];
    y += self.phoneField.frame.size.height+1.0f;


    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.passwordField.delegate = self;
    self.passwordField.placeholder = @"Password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyNext;
    self.passwordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 44.0f)];;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.passwordField.alpha = 0.8f;
    self.passwordField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.passwordField.textColor = [UIColor darkGrayColor];
    [view addSubview:self.passwordField];
    y += self.passwordField.frame.size.height+1.0f;

    self.promoCodeField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.promoCodeField.delegate = self;
    self.promoCodeField.placeholder = @"Referral Code";
    self.promoCodeField.returnKeyType = UIReturnKeyGo;
    self.promoCodeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 44.0f)];;
    self.promoCodeField.leftViewMode = UITextFieldViewModeAlways;
    self.promoCodeField.backgroundColor = [UIColor whiteColor];
    self.promoCodeField.alpha = 0.8f;
    self.promoCodeField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.promoCodeField.textColor = [UIColor darkGrayColor];
    [view addSubview:self.promoCodeField];
    y += self.promoCodeField.frame.size.height+20.0f;

    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(x, y, width-2*x, 44.0f);
    btnRegister.backgroundColor = [UIColor clearColor];
    [btnRegister addTarget:self action:@selector(registerProfile:) forControlEvents:UIControlEventTouchUpInside];
    [btnRegister setTitle:@"REGISTER" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnRegister.layer.cornerRadius = 22.0f;
    btnRegister.layer.masksToBounds = YES;
    btnRegister.layer.borderWidth = 1.0f;
    btnRegister.layer.borderColor = [[UIColor whiteColor] CGColor];
    [view addSubview:btnRegister];

    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];


    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dismissKeyboard
{
    [self.nameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [self shiftBack:64.0f];

}


- (void)registerProfile:(UIButton *)btn
{
    if (self.nameField.text.length==0){
        [self showAlertWithTitle:@"Missing Full Name" message:@"Please enter your full name."];
        return;
    }
    
    NSString *fullName = self.nameField.text;
    NSArray *parts = [fullName componentsSeparatedByString:@" "];
    
    if (parts.count < 2){
        [self showAlertWithTitle:@"Missing Full Name" message:@"PLease enter your first and last name."];
        return;
    }


    if (self.emailField.text.length==0){
        [self showAlertWithTitle:@"Missing Email" message:@"PLease enter your email."];
        return;
    }

    if (self.phoneField.text.length<10){
        [self showAlertWithTitle:@"Missing Phone" message:@"PLease enter your phone number. Our drivers text you when your order is ready."];
        return;
    }

    if (self.passwordField.text.length==0){
        [self showAlertWithTitle:@"Missing Password" message:@"PLease enter your password."];
        return;
    }
    
    
    self.profile.firstName = parts[0];
    self.profile.lastName = parts[parts.count-1];
    self.profile.email = self.emailField.text;
    self.profile.phone = self.phoneField.text;
    self.profile.password = self.passwordField.text;
    if (self.promoCodeField.text.length > 0)
        self.profile.referral = self.promoCodeField.text;
    



    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] registerProfile:self.profile completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        [self.profile populate:results[@"profile"]];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }];

}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.emailField]){
        [self shiftUp:64.0f];
    }
    if ([textField isEqual:self.phoneField]){
        [self shiftUp:96.0f];
    }

    if ([textField isEqual:self.passwordField]){
        [self shiftUp:96.0f];
    }

    if ([textField isEqual:self.promoCodeField]){
        [self shiftUp:96.0f];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameField]){
        [self.emailField becomeFirstResponder];
        return YES;
    }
    
    if ([textField isEqual:self.emailField]){
        [self.phoneField becomeFirstResponder];
        [self shiftUp:96.0f];
        return YES;
    }
    
    if ([textField isEqual:self.phoneField]){
        [self.passwordField becomeFirstResponder];
        [self shiftUp:96.0f];
        return YES;
    }

    if ([textField isEqual:self.passwordField]){
        [self.promoCodeField becomeFirstResponder];
        [self shiftUp:96.0f];
        return YES;
    }

    [textField resignFirstResponder];
    [self registerProfile:nil];
    [self shiftBack:64.0f];
    
    return YES;
}




@end
