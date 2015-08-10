//
//  PCContainerViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCContainerViewController.h"
#import "PCLoginViewController.h"
#import "PCAccountViewController.h"
#import "PCZoneViewController.h"


@interface PCContainerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UINavigationController *navCtr;
@property (strong, nonatomic) PCZoneViewController *zoneVc;
@property (strong, nonatomic) PCViewController *currentVc;
@property (strong, nonatomic) PCWelcomeView *welcomeView;
@property (strong, nonatomic) UITableView *sectionsTable;
@property (strong, nonatomic) NSArray *sections;
@end


@implementation PCContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.sections = @[@"Account"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleMainMenu:)
                                                     name:kViewMenuNotification
                                                   object:nil];

        
    }
    
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    
    self.sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.sectionsTable.dataSource = self;
    self.sectionsTable.delegate = self;
    self.sectionsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    [view addSubview:self.sectionsTable];
    
    self.zoneVc = [[PCZoneViewController alloc] init];
    self.currentVc = self.zoneVc;
    self.navCtr = [[UINavigationController alloc] initWithRootViewController:self.zoneVc];
    
    // makes nav bar clear:
    [self.navCtr.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navCtr.view.backgroundColor = [UIColor clearColor];
    self.navCtr.navigationBar.shadowImage = [UIImage new];
    self.navCtr.navigationBar.translucent = YES;

    [self addChildViewController:self.navCtr];
    [self.navCtr willMoveToParentViewController:self];
    [view addSubview:self.navCtr.view];
    
//    if (self.profile.isPopulated){
//        self.view = view;
//        return;
//    }
    
    [self.profile addObserver:self forKeyPath:@"isPopulated" options:0 context:nil];
    
    self.welcomeView = [[PCWelcomeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.welcomeView.delegate = self;
    self.welcomeView.backgroundColor = [UIColor blackColor];
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
    
    if (self.welcomeView != nil)
        [self.welcomeView introAnimation];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.welcomeView==nil)
        return;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isPopulated"]==NO)
        return;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)toggleMainMenu:(NSNotification *)notfication
{
    [self toggleMenu:0.85f];

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
//                         [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:YES];
                     }];
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
        [UIView animateWithDuration:0.25f
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect frame = self.welcomeView.frame;
                             frame.origin.y = self.view.frame.size.height+200.0f; // get it all the way off the screen
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
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = self.sections[indexPath.row];
    return cell;
}

@end
