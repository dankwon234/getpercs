//
//  PCJoinUsViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/24/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCJoinUsViewController.h"

@interface PCJoinUsViewController ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblJoinus;
@property (strong, nonatomic) UILabel *lblDescription;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *phoneField;
@property (strong, nonatomic) UITextView *bioTextView;
@end

@implementation PCJoinUsViewController


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgDinner.png"]];
    CGRect frame = view.frame;
    
    CGFloat width = frame.size.width;
    
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    self.icon.center = CGPointMake(0.5f*width, 88.0f);
    self.icon.layer.cornerRadius = 0.5f*self.icon.frame.size.height;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.borderWidth = 1.0f;
    self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    [view addSubview:self.icon];
    CGFloat y = self.icon.frame.origin.y+self.icon.frame.size.height+16.0f;

    self.lblJoinus = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, width-40.0f, 22.0f)];
    self.lblJoinus.textAlignment = NSTextAlignmentCenter;
    self.lblJoinus.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblJoinus.textColor = [UIColor whiteColor];
    self.lblJoinus.text = @"JOIN US";
    [view addSubview:self.lblJoinus];
    y += self.lblJoinus.frame.size.height;
    
    self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, width-40.0f, 120.0f)];
    self.lblDescription.numberOfLines = 0;
    self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblDescription.textAlignment = NSTextAlignmentCenter;
    self.lblDescription.textColor = [UIColor whiteColor];
    self.lblDescription.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblDescription.backgroundColor = [UIColor clearColor];
    self.lblDescription.text = @"Driving for Perc is like being your own boss. Set your own hours, work from home, and even set delivery fees. If you are interested in joining the Perc team, fill out the questionaire below.";
    [view addSubview:self.lblDescription];
    y += self.lblDescription.frame.size.height;

    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, frame.size.height)];
    self.theScrollview.delegate = self;
    self.theScrollview.showsVerticalScrollIndicator = NO;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];

    CGFloat h = 44.0f;
    UIColor *gray = [UIColor grayColor];
    UIColor *white = [UIColor whiteColor];
    self.firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.firstNameField.delegate = self;
    self.firstNameField.backgroundColor = white;
    self.firstNameField.alpha = 0.8f;
    self.firstNameField.placeholder = @"First Name";
    self.firstNameField.textColor = gray;
    self.firstNameField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.firstNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    self.firstNameField.leftViewMode = UITextFieldViewModeAlways;
    self.firstNameField.text = (self.profile.isPopulated) ? [self.profile.firstName uppercaseString] : nil;
    [self.theScrollview addSubview:self.firstNameField];
    y += self.firstNameField.frame.size.height+1.0f;

    self.lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.lastNameField.delegate = self;
    self.lastNameField.backgroundColor = white;
    self.lastNameField.alpha = 0.8f;
    self.lastNameField.placeholder = @"Last Name";
    self.lastNameField.textColor = gray;
    self.lastNameField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lastNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];;
    self.lastNameField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameField.text = (self.profile.isPopulated) ? [self.profile.lastName uppercaseString] : nil;
    [self.theScrollview addSubview:self.lastNameField];
    y += self.lastNameField.frame.size.height+1.0f;

    
    self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.emailField.delegate = self;
    self.emailField.backgroundColor = white;
    self.emailField.alpha = 0.8f;
    self.emailField.placeholder = @"Email";
    self.emailField.textColor = gray;
    self.emailField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.emailField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];;
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    self.emailField.text = (self.profile.isPopulated) ? self.profile.email : nil;
    [self.theScrollview addSubview:self.emailField];
    y += self.emailField.frame.size.height+1.0f;

    
    self.phoneField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    self.phoneField.delegate = self;
    self.phoneField.backgroundColor = white;
    self.phoneField.alpha = 0.8f;
    self.phoneField.placeholder = @"Phone";
    self.phoneField.textColor = gray;
    self.phoneField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.phoneField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];;
    self.phoneField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneField.text = (self.profile.isPopulated) ? self.profile.phone : nil;
    [self.theScrollview addSubview:self.phoneField];
    y += self.phoneField.frame.size.height;
    
    UILabel *lblBio = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, width, h)];
    lblBio.backgroundColor = gray;
    lblBio.textAlignment = NSTextAlignmentCenter;
    lblBio.textColor = white;
    lblBio.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblBio.text = @"TELL US ABOUT YOURSELF";
    [self.theScrollview addSubview:lblBio];
    y += lblBio.frame.size.height;

    UIView *bioBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 240.0f)];
    bioBackground.backgroundColor = white;
    bioBackground.alpha = 0.8f;
    self.bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, width-40.0f, 220.0f)];
    self.bioTextView.delegate = self;
    self.bioTextView.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.bioTextView.backgroundColor = [UIColor clearColor];
    self.bioTextView.textColor = gray;
    [bioBackground addSubview:self.bioTextView];
    [self.theScrollview addSubview:bioBackground];
    y += bioBackground.frame.size.height;
    
    UIView *bgSubmit = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgSubmit.backgroundColor = gray;
    
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnSubmit.frame = CGRectMake(20.0f, 0.5f*(bgSubmit.frame.size.height-h), width-40.0f, h);
    btnSubmit.backgroundColor = [UIColor clearColor];
    btnSubmit.layer.cornerRadius = 0.5f*h;
    btnSubmit.layer.masksToBounds = YES;
    btnSubmit.layer.borderColor = [white CGColor];
    btnSubmit.layer.borderWidth = 1.0f;
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSubmit setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnSubmit addTarget:self action:@selector(submitApplication:) forControlEvents:UIControlEventTouchUpInside];
    [bgSubmit addSubview:btnSubmit];
    [self.theScrollview addSubview:bgSubmit];
    y += bgSubmit.frame.size.height;

    
    self.theScrollview.contentSize = CGSizeMake(0, y+44.0f);
    
    [view addSubview:self.theScrollview];
    
    self.view = view;
}

- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *imgHamburger = [UIImage imageNamed:@"iconHamburger.png"];
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame = CGRectMake(0.0f, 0.0f, 0.5f*imgHamburger.size.width, 0.5f*imgHamburger.size.height);
    [btnMenu setBackgroundImage:imgHamburger forState:UIControlStateNormal];
    [btnMenu addTarget:self action:@selector(viewMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        UIScrollView *scrollview = self.theScrollview;
        CGFloat offset = scrollview.contentOffset.y;
        if (offset < 0){
            self.icon.alpha = 1.0f;
            self.lblDescription.alpha = self.icon.alpha;
            self.lblJoinus.alpha = self.icon.alpha;
            return;
        }
        
        self.icon.alpha = 1.0f-(offset/100.0f);
        self.lblDescription.alpha = self.icon.alpha;
        self.lblJoinus.alpha = self.icon.alpha;
        
    }
}

- (void)submitApplication:(UIButton *)btn
{
    NSLog(@"submitApplication: ");
    
    if (self.firstNameField.text.length==0){
        [self showAlertWithTitle:@"Missing First Name" message:@"Please enter your first name."];
        return;
    }

    if (self.lastNameField.text.length==0){
        [self showAlertWithTitle:@"Missing Last Name" message:@"Please enter your last name."];
        return;
    }

    if (self.emailField.text.length==0){
        [self showAlertWithTitle:@"Missing Email" message:@"Please enter your email."];
        return;
    }

    if (self.phoneField.text.length==0){
        [self showAlertWithTitle:@"Missing Phone Number" message:@"Please enter your phone number."];
        return;
    }

    if (self.bioTextView.text.length==0){
        [self showAlertWithTitle:@"Missing Description" message:@"Please add a description about yourself."];
        return;
    }

    
    NSDictionary *application = @{@"firstName":self.firstNameField.text, @"lastName":self.lastNameField.text, @"email":self.emailField.text, @"bio":self.bioTextView.text, @"phone":self.phoneField.text, @"location":self.locationMgr.cities[0], @"id":self.profile.uniqueId};
    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] submitDriverApplication:application completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:@"Thank You!" message:@"Thank you for showing interest in working with us! We will reach out to you shortly with more information."];
        });
        
    }];
}


- (void)resetDelegate
{
    self.theScrollview.delegate = self;
    //    self.addressField.delegate = self;
}

- (void)dismissKeyboard
{
    for (UITextField *tf in @[self.emailField, self.firstNameField, self.lastNameField, self.phoneField])
        [tf resignFirstResponder];
    
    [self.bioTextView resignFirstResponder];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    [self dismissKeyboard];
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 220.0f) animated:YES];
    [self performSelector:@selector(resetDelegate) withObject:nil afterDelay:0.6f];
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 350.0f) animated:YES];
    [self performSelector:@selector(resetDelegate) withObject:nil afterDelay:0.6f];
    
    return YES;
}




@end
