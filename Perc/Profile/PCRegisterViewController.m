//
//  PCRegisterViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCRegisterViewController.h"

@interface PCRegisterViewController ()
@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *phoneField;
@property (strong, nonatomic) UITextField *passwordField;
@end

@implementation PCRegisterViewController


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgCoffee.png"]];
    CGRect frame = view.frame;
    
    static CGFloat x = 20.0f;
    CGFloat y = 0.15f*frame.size.height;
    CGFloat width = frame.size.width;
    
    UILabel *lblSignup = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblSignup.textColor = [UIColor whiteColor];
    lblSignup.textAlignment = NSTextAlignmentCenter;
    lblSignup.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblSignup.text = @"Sign Up";
    [view addSubview:lblSignup];
    y += lblSignup.frame.size.height+32.0f;


    self.firstNameField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.firstNameField.delegate = self;
    self.firstNameField.placeholder = @"First Name";
    self.firstNameField.returnKeyType = UIReturnKeyNext;
    [view addSubview:self.firstNameField];
    y += self.firstNameField.frame.size.height+14.0f;

    self.lastNameField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.lastNameField.delegate = self;
    self.lastNameField.placeholder = @"Last Name";
    self.lastNameField.returnKeyType = UIReturnKeyNext;
    [view addSubview:self.lastNameField];
    y += self.lastNameField.frame.size.height+14.0f;

    
    self.emailField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.emailField.delegate = self;
    self.emailField.placeholder = @"Email";
    self.emailField.returnKeyType = UIReturnKeyNext;
    [view addSubview:self.emailField];
    y += self.emailField.frame.size.height+14.0f;

    self.phoneField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.phoneField.delegate = self;
    self.phoneField.placeholder = @"Phone (We text you when your order is ready)";
    self.phoneField.returnKeyType = UIReturnKeyNext;
    [view addSubview:self.phoneField];
    y += self.phoneField.frame.size.height+14.0f;


    self.passwordField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.passwordField.delegate = self;
    self.passwordField.placeholder = @"Password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    [view addSubview:self.passwordField];
    y += self.passwordField.frame.size.height+20.0f;
    
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
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [self shiftBack:64.0f];

}


- (void)registerProfile:(UIButton *)btn
{
    if (self.firstNameField.text.length==0){
        [self showAlertWithTitle:@"Missing First Name" message:@"PLease enter your first name."];
        return;
    }

    if (self.lastNameField.text.length==0){
        [self showAlertWithTitle:@"Missing Last Name" message:@"PLease enter your last name."];
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
    
    self.profile.firstName = self.firstNameField.text;
    self.profile.lastName = self.lastNameField.text;
    self.profile.email = self.emailField.text;
    self.profile.phone = self.phoneField.text;
    self.profile.password = self.passwordField.text;



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

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.firstNameField]){
        [self.lastNameField becomeFirstResponder];
        return YES;
    }
    
    if ([textField isEqual:self.lastNameField]){
        [self.emailField becomeFirstResponder];
        [self shiftUp:64.0f];
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
    
    [textField resignFirstResponder];
    [self registerProfile:nil];
    [self shiftBack:64.0f];
    
    return YES;
}




@end
