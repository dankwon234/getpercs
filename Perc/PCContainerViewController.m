//
//  PCContainerViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCContainerViewController.h"
#import "PCVenuesViewController.h"
#import "PCLoginViewController.h"
#import "PCAccountViewController.h"
#import "PCAboutViewController.h"
#import "PCZoneViewController.h"


@interface PCContainerViewController ()
@property (strong, nonatomic) UITableView *sectionsTable;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) UINavigationController *navCtr;
@property (strong, nonatomic) PCZoneViewController *zoneVc;
@property (strong, nonatomic) PCViewController *currentVc;
@property (strong, nonatomic) PCWelcomeView *welcomeView;
@property (strong, nonatomic) UIButton *btnLogin;
@end


@implementation PCContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
//        self.sections = @[@"Venues", @"Your Account", @"Join Us", @"About"];
        self.sections = @[@"Venues", @"About"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleMenu)
                                                     name:kViewMenuNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMenu)
                                                     name:kLocationUpdatedNotification
                                                   object:nil];

        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    
    CGFloat width = frame.size.width;
    self.sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, frame.size.height) style:UITableViewStylePlain];
    self.sectionsTable.backgroundColor = [UIColor clearColor];
    self.sectionsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.sectionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sectionsTable.dataSource = self;
    self.sectionsTable.delegate = self;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 64.0f)];
    header.backgroundColor = kLightBlue;
    self.sectionsTable.tableHeaderView = header;
    
    self.btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnLogin.frame = CGRectMake(16.0f, 0.0f, width, 58.0f);
    self.btnLogin.backgroundColor = [UIColor clearColor];
    self.btnLogin.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    NSString *btnText = (self.profile.isPopulated) ? [NSString stringWithFormat:@"%@ %@", [self.profile.firstName uppercaseString], [self.profile.lastName uppercaseString]] : @"LOG IN";
    [self.btnLogin setTitle:btnText forState:UIControlStateNormal];
    self.btnLogin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.btnLogin.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [self.btnLogin addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.sectionsTable.tableHeaderView addSubview:self.btnLogin];
    
    [view addSubview:self.sectionsTable];
    
    
//    self.venuesVc = [[PCVenuesViewController alloc] init];
//    self.currentVc = self.venuesVc;
//    self.navCtr = [[UINavigationController alloc] initWithRootViewController:self.venuesVc];
//    self.navCtr.navigationBar.barTintColor = kOrange;

    self.zoneVc = [[PCZoneViewController alloc] init];
    self.currentVc = self.zoneVc;
    self.navCtr = [[UINavigationController alloc] initWithRootViewController:self.zoneVc];
    self.navCtr.navigationBar.barTintColor = kOrange;

    [self addChildViewController:self.navCtr];
    [self.navCtr willMoveToParentViewController:self];
    [view addSubview:self.navCtr.view];
    
    [self.profile addObserver:self forKeyPath:@"isPopulated" options:0 context:nil];
    
    self.welcomeView = [[PCWelcomeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.welcomeView.delegate = self;
    self.welcomeView.backgroundColor = kOrange;
    self.welcomeView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    if (self.profile.isPopulated)
        [self.welcomeView.btnProfile setTitle:@"Your Account" forState:UIControlStateNormal];

    [view addSubview:self.welcomeView];
    
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.navCtr.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.navCtr.view addGestureRecognizer:swipeRight];
    
    [self.welcomeView introAnimation];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.welcomeView==nil)
        return;
    
//    [self.welcomeView introAnimation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isPopulated"]==NO)
        return;
    
    if (self.profile.isPopulated){
        [self.btnLogin setTitle:[NSString stringWithFormat:@"%@ %@", [self.profile.firstName uppercaseString], [self.profile.lastName uppercaseString]] forState:UIControlStateNormal];
        return;
    }
    
    [self.btnLogin setTitle:@"Log In" forState:UIControlStateNormal];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showMenu
{
    CGPoint center = self.navCtr.view.center;
    if (center.x > 0.50f*self.view.frame.size.width)
        return;
    
    [self toggleMenu];
}

- (void)hideMenu
{
    CGPoint center = self.navCtr.view.center;
    if (center.x==0.50f*self.view.frame.size.width)
        return;
    
    [self toggleMenu];
}


- (void)toggleMenu:(NSTimeInterval)duration
{
    CGRect frame = self.view.frame;
    CGFloat halfWidth = 0.50f*frame.size.width;
    
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGPoint center = self.navCtr.view.center;
                         center.x = (center.x==halfWidth) ? 1.15f*frame.size.width : halfWidth;
                         self.navCtr.view.center = center;
                     }
                     completion:^(BOOL finished){
                         CGPoint center = self.navCtr.view.center;
                         self.navCtr.topViewController.view.userInteractionEnabled = (center.x==halfWidth);
                         [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:YES];
                     }];
}

- (void)toggleMenu
{
    [self toggleMenu:0.85f];
}

- (void)login:(UIButton *)btn
{
    // logged in - go to account view controller
    if (self.profile.isPopulated){
        [self showAccountView];
        return;
    }
    
    
    [self showLoginView:YES]; // not logged in - go to log in / register view controller
    
}

- (void)buttonPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *btnTitle = [btn.titleLabel.text lowercaseString];
    NSLog(@"buttonPressed: %@", btnTitle);
    
    if ([btnTitle isEqualToString:@"enter"]){
        [UIView animateWithDuration:0.20f
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect frame = self.welcomeView.frame;
                             frame.origin.y = self.welcomeView.frame.size.height;
                             self.welcomeView.frame = frame;
                         }
                         completion:^(BOOL finished){
                             [self.welcomeView removeFromSuperview];
                             self.welcomeView = nil;
                             [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kShowBackgroundsNotification object:nil]];
                         }];
        return;
    }
    
    if (self.profile.isPopulated)
        [self showAccountView];
    else
        [self showLoginView:YES];
}

// Once location is found, update main menu with current location:
- (void)updateMenu
{
    if (self.locationMgr.cities.count==0)
        return;
    
    self.sections = @[[self.locationMgr.cities[0] uppercaseString], @"Order History", @"Messages", @"Posts", @"About"];
    [self.sectionsTable reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 53.0f, tableView.frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];

    }
    
    cell.textLabel.text = self.sections[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==self.sections.count-1){ // about page
        PCAboutViewController *aboutVc = [[PCAboutViewController alloc] init];
        [self presentViewController:aboutVc animated:YES completion:^{
            [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:NO];
        }];
        
        return;
    }
    
    NSString *section = [self.sections[indexPath.row] lowercaseString];
    NSLog(@"SECTION = %@", section);
    
    if (indexPath.row==0){
        if ([self.currentVc isEqual:self.zoneVc]){
            [self toggleMenu];
            return;
        }
        
        self.currentVc = self.zoneVc;
    }
    
//    if (indexPath.row==1){
//        if (self.orderHistoryVc){
//            if ([self.currentVc isEqual:self.orderHistoryVc]){
//                [self toggleMenu];
//                return;
//            }
//        }
//        else{
//            self.orderHistoryVc = [[PCOrderHistoryViewController alloc] init];
//        }
//        
//        self.currentVc = self.orderHistoryVc;
//    }

    
//    if (indexPath.row==2){
//        if (self.messagesVc){
//            if ([self.currentVc isEqual:self.messagesVc]){
//                [self toggleMenu];
//                return;
//            }
//        }
//        else{
//            self.messagesVc = [[PCMessagesViewController alloc] init];
//        }
//        
//        self.currentVc = self.messagesVc;
//    }
    
    CGRect frame = self.view.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect navFrame = self.navCtr.view.frame;
                         navFrame.origin.x = frame.size.width;
                         self.navCtr.view.frame = navFrame;
                     }
                     completion:^(BOOL finished){
                         [self.navCtr popToRootViewControllerAnimated:NO];
                         if (indexPath.row != 0)
                             [self.navCtr pushViewController:self.currentVc animated:NO];
                         
                         [self toggleMenu:0.85f];
                     }];


    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

@end
