//
//  PCLoginViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCLoginViewController.h"
#import "PCRegisterViewController.h"

@interface PCLoginViewController ()
@property (strong, nonatomic) PCTextField *emailField;
@property (strong, nonatomic) PCTextField *passwordField;
@end

@implementation PCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    return self;
}




- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBurger.png"]];
    CGRect frame = view.frame;
    
    static CGFloat x = 20.0f;
    CGFloat y = 0.15f*frame.size.height;
    CGFloat width = frame.size.width;
    
    UILabel *lblLogin = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblLogin.textColor = [UIColor whiteColor];
    lblLogin.textAlignment = NSTextAlignmentCenter;
    lblLogin.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblLogin.text = @"Log In";
    [view addSubview:lblLogin];
    y += lblLogin.frame.size.height+32.0f;

    self.emailField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.emailField.delegate = self;
    self.emailField.placeholder = @"Email";
    self.emailField.returnKeyType = UIReturnKeyNext;
    [view addSubview:self.emailField];
    y += self.emailField.frame.size.height+14.0f;
    
    self.passwordField = [PCTextField textFieldWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    self.passwordField.delegate = self;
    self.passwordField.placeholder = @"Password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    [view addSubview:self.passwordField];
    y += self.passwordField.frame.size.height+20.0f;
    
    
    UILabel *lblOr = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblOr.textColor = [UIColor whiteColor];
    lblOr.textAlignment = NSTextAlignmentCenter;
    lblOr.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblOr.text = @"OR";
    [view addSubview:lblOr];
    
    CGFloat w = 0.35f*width;
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(x, y+16.0f, w, 1.0f)];
    leftLine.backgroundColor = [UIColor whiteColor];
    [view addSubview:leftLine];

    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(width-x-w, y+16.0f, w, 1.0f)];
    rightLine.backgroundColor = [UIColor whiteColor];
    [view addSubview:rightLine];
    y += lblOr.frame.size.height+20.0f;
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(x, y, width-2*x, 44.0f);
    btnRegister.backgroundColor = [UIColor clearColor];
    [btnRegister addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    [btnRegister setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnRegister.layer.cornerRadius = 0.5f*btnRegister.frame.size.height;
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
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)dismissKeyboard
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)signUp:(UIButton *)btn
{
    NSLog(@"signUp: ");
    PCRegisterViewController *registerVc = [[PCRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVc animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailField]){
        [self.passwordField becomeFirstResponder];
        return YES;
    }
    
    // login
    if (self.emailField.text.length==0){
        [self showAlertWithTitle:@"Missing Email" message:@"Please enter your email."];
        return YES;
    }

    if (self.passwordField.text.length==0){
        [self showAlertWithTitle:@"Missing Password" message:@"Please enter your password."];
        return YES;
    }

    
    [textField resignFirstResponder];
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] login:@{@"email":self.emailField.text, @"password":self.passwordField.text} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        [self.profile populate:results[@"profile"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        });
        
    }];
    
    return YES;
}

@end
