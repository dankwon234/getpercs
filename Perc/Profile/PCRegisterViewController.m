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
@end

@implementation PCRegisterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgCoffee.png"]];
    CGRect frame = view.frame;
    
    static CGFloat x = 24.0f;
    CGFloat y = 110.0f;
    CGFloat width = frame.size.width;
    
    UILabel *lblSignup = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblSignup.textColor = [UIColor whiteColor];
    lblSignup.textAlignment = NSTextAlignmentCenter;
    lblSignup.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblSignup.text = @"Sign Up";
    [view addSubview:lblSignup];
    y += lblSignup.frame.size.height+32.0f;


    static CGFloat h = 44.0f;
    self.nameField = [[UITextField alloc] init];
    self.emailField = [[UITextField alloc] init];
    self.phoneField = [[UITextField alloc] init];
    self.passwordField = [[UITextField alloc] init];
    
    NSArray *fields = @[self.nameField, self.emailField, self.phoneField, self.passwordField];
    NSArray *placeholders = @[@"Full Name", @"Email", @"Phone (We text you when your order is ready)", @"Password"];
    UIFont *font = [UIFont fontWithName:kBaseFontName size:14.0];
    UIColor *white = [UIColor whiteColor];
    for (int i=0; i<fields.count; i++) {
        UITextField *field = fields[i];
        field.frame = CGRectMake(12.0f, y, width-2*x, h);
        field.delegate = self;
        field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholders[i] attributes:@{ NSForegroundColorAttributeName : white }];
        field.returnKeyType = UIReturnKeyNext;
        field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, h)];;
        field.leftViewMode = UITextFieldViewModeAlways;
        field.backgroundColor = [UIColor clearColor];
        field.alpha = 0.8f;
        field.font = font;
        field.textColor = white;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, h-6.0f, width-2*x, 1.0f)];
        line.backgroundColor = white;
        [field addSubview:line];
        
        [view addSubview:field];
        y += field.frame.size.height+4.0f;
    }
    
    self.passwordField.secureTextEntry = YES;
    y += 36.0f;
    
    x = 36.0f;
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(x, y, width-2*x, h);
    btnRegister.backgroundColor = [UIColor clearColor];
    [btnRegister addTarget:self action:@selector(registerProfile:) forControlEvents:UIControlEventTouchUpInside];
    [btnRegister setTitle:@"REGISTER" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:kBaseBoldFont size:18.0f];
    btnRegister.layer.cornerRadius = 0.5f*h;
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
    
    [self shiftBack:0.0f];

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


    [textField resignFirstResponder];
    [self registerProfile:nil];
    [self shiftBack:64.0f];
    
    return YES;
}




@end
