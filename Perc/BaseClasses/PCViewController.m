//
//  PCViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCViewController.h"
#import "PCLoginViewController.h"
#import "PCAccountViewController.h"

@implementation PCViewController
@synthesize loadingIndicator;
@synthesize profile;
@synthesize currentZone;
@synthesize locationMgr;
@synthesize session;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        [self addNavigationTitleView];
        self.profile = [PCProfile sharedProfile];
        self.currentZone = [PCZone sharedZone];
        self.session = [PCSession sharedSession];
        self.locationMgr = [PCLocationManager sharedLocationManager];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingIndicator = [[PCLoadingIndicator alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    self.loadingIndicator.alpha = 0.0f;
    [self.view addSubview:self.loadingIndicator];
}


- (UIView *)baseView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    
    return view;
}

- (UIView *)baseViewWithNavBar
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-kNavBarHeight)];
    view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    
    return view;
}

//- (void)addNavigationTitleView
//{
//    static CGFloat width = 200.0f;
//    static CGFloat height = 46.0f;
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
//    titleView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
//    titleView.backgroundColor = [UIColor clearColor];
//    UIImage *imgLogo = [UIImage imageNamed:@"logo-white.png"];
//    UIImageView *logo = [[UIImageView alloc] initWithImage:imgLogo];
//    static double scale = 0.7f;
//    CGRect frame = logo.frame;
//    frame.size.width = scale*imgLogo.size.width;
//    frame.size.height = scale*imgLogo.size.height;
//    logo.frame = frame;
//    logo.center = CGPointMake(0.5f*width, 20.0f);
//    
//    [titleView addSubview:logo];
//    
//    self.navigationItem.titleView = titleView;
//    
//}


- (void)addNavigationTitleView
{
    static CGFloat width = 200.0f;
    static CGFloat height = 46.0f;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    titleView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    titleView.backgroundColor = [UIColor clearColor];
    UIImage *imgLogo = [UIImage imageNamed:@"logoTransparent.png"];
    UIImageView *logo = [[UIImageView alloc] initWithImage:imgLogo];
    static double scale = 0.45f;
    CGRect frame = logo.frame;
    frame.size.width = scale*imgLogo.size.width;
    frame.size.height = scale*imgLogo.size.height;
    logo.frame = frame;
    logo.center = CGPointMake(0.5f*width, 20.0f);
    
    [titleView addSubview:logo];
    
    self.navigationItem.titleView = titleView;
}


- (void)shiftUp:(CGFloat)distance
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = -distance;
                         self.view.frame = frame;
                     }
                     completion:NULL];
}

- (void)shiftBack:(CGFloat)origin
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = origin; // accounts for nav bar
                         self.view.frame = frame;
                     }
                     completion:NULL];
    
}


- (void)addCustomBackButton
{
    UIColor *white = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = white;
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:18.0f], NSForegroundColorAttributeName : white};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIImage *imgExit = [UIImage imageNamed:@"backArrow.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.8f*imgExit.size.width, 0.8f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];
}

- (void)addMenuButton
{
    UIImage *imgHamburger = [UIImage imageNamed:@"iconHamburger.png"];
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame = CGRectMake(0.0f, 0.0f, 0.5f*imgHamburger.size.width, 0.5f*imgHamburger.size.height);
    [btnMenu setBackgroundImage:imgHamburger forState:UIControlStateNormal];
    [btnMenu addTarget:self action:@selector(viewMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
}

- (void)addOptionsButton
{
    UIImage *imgDots = [UIImage imageNamed:@"dots"];
    UIButton *btnDots = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDots.frame = CGRectMake(0.0f, 0.0f, 0.6f*imgDots.size.width, 0.6f*imgDots.size.height);
    [btnDots setBackgroundImage:imgDots forState:UIControlStateNormal];
    [btnDots addTarget:self action:@selector(toggleOptionsView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnDots];
}

- (void)toggleOptionsView:(UIButton *)btn
{
    
}


- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showLoginView:(BOOL)animated
{
    PCLoginViewController *loginVc = [[PCLoginViewController alloc] init];
    UINavigationController *navController = [self clearNavigationControllerWithRoot:loginVc];
    [self presentViewController:navController animated:animated completion:^{
        
    }];
}

- (void)showAccountView
{
    if (self.profile.isPopulated==NO){
        [self showLoginView:YES];
        return;
    }
    
    PCAccountViewController *accountVc = [[PCAccountViewController alloc] init];
    UINavigationController *navController = [self clearNavigationControllerWithRoot:accountVc];
    
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

- (void)viewMenu:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kViewMenuNotification object:nil]];
}

- (UINavigationController *)clearNavigationControllerWithRoot:(UIViewController *)root
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:root];
    
    // makes nav bar clear:
    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.view.backgroundColor = [UIColor clearColor];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    return navController;
}


#pragma mark - Alert
- (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)msg
{
     return [self showAlertWithTitle:title message:msg buttons:nil];
}

- (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)msg buttons:(NSString *)btns
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:btns, nil];
    [alert show];
    return alert;
}




@end
