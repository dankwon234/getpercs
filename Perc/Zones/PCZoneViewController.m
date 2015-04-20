//
//  PCZoneViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/15/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCZoneViewController.h"
#import "PCVenuesViewController.h"
#import "PCPostsViewController.h"


@interface PCZoneViewController ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblLocation;
@end

@implementation PCZoneViewController

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor blackColor];
    CGRect frame = view.frame;

    CGFloat width = frame.size.width;
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    self.icon.center = CGPointMake(0.5f*width, 88.0f);
    self.icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.icon.layer.cornerRadius = 0.5f*self.icon.frame.size.height;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.borderWidth = 1.0f;
    self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    [view addSubview:self.icon];
    
    CGFloat y = self.icon.frame.origin.y+self.icon.frame.size.height+20.0f;
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, width-40.0f, 22.0f)];
    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblLocation.textAlignment = NSTextAlignmentCenter;
    self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblLocation.textColor = [UIColor whiteColor];
    [view addSubview:self.lblLocation];
    y += self.lblLocation.frame.size.height+24.0f;
    
    
    UIButton *btnFood = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFood.frame = CGRectMake(20, y, width-40.0f, 44.0f);
    btnFood.backgroundColor = [UIColor redColor];
    [btnFood setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnFood setTitle:@"Order Food" forState:UIControlStateNormal];
    [btnFood addTarget:self action:@selector(viewVenues:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnFood];
    y += btnFood.frame.size.height+12.0f;
    
    
    UIButton *btnBoard = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBoard.frame = CGRectMake(20, y, width-40.0f, 44.0f);
    btnBoard.backgroundColor = [UIColor redColor];
    [btnBoard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBoard setTitle:@"Bulletin Board" forState:UIControlStateNormal];
    [btnBoard addTarget:self action:@selector(viewPosts:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnBoard];
    y += btnBoard.frame.size.height+12.0f;

    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLocation.frame = CGRectMake(20, y, width-40.0f, 44.0f);
    btnLocation.backgroundColor = [UIColor redColor];
    [btnLocation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLocation setTitle:@"Update Location" forState:UIControlStateNormal];
    //    [btnJobs addTarget:self action:@selector(viewJobs:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnLocation];
    y += btnLocation.frame.size.height+12.0f;

    
//    UIButton *btnBulletinBoard = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnBulletinBoard.frame = CGRectMake(20, y, width-40.0f, 44.0f);
//    btnBulletinBoard.backgroundColor = [UIColor redColor];
//    [btnBulletinBoard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btnBulletinBoard setTitle:@"Bulletin Board" forState:UIControlStateNormal];
//    //    [btnJobs addTarget:self action:@selector(viewJobs:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:btnBulletinBoard];

    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewMenu:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    
    BOOL connected = [[PCWebServices sharedInstance] checkConnection];
    if (connected==NO){
        [self showAlertWithTitle:@"No Connection" message:@"Please find an internet connection."];
        return;
    }

    [self.loadingIndicator startLoading];
    [self.locationMgr findLocation:^(NSError *error){
        
        if (error) {
            [self.loadingIndicator stopLoading];
            NSLog(@"ERROR: %@", [error localizedDescription]);
            [self showAlertWithTitle:@"Error" message:@"Failed to Get Your Location. Please check your settings to make sure location services is ativated (under 'Privacy' section).\n\nTo choose your location, tap the icon in the upper right corner."];
            return;
        }
        
        NSLog(@"CURRENT LOCATION: %.2f, %.2f", self.locationMgr.currentLocation.latitude, self.locationMgr.currentLocation.longitude);
        
        [self.locationMgr reverseGeocode:self.locationMgr.currentLocation completion:^{
            NSLog(@"%@", [self.locationMgr.cities description]);
            NSString *townState = self.locationMgr.cities[0];
            self.lblLocation.text = [townState uppercaseString];
            
            NSArray *parts = [townState componentsSeparatedByString:@", "];
            
            if (parts.count < 2){ // not a valid city, state.
                [self showAlertWithTitle:@"No Venues" message:@"We don't serve your area yet. Sorry."];
                return;
            }
            
            NSDictionary *params = @{@"town":parts[0], @"state":parts[1]};
            [[PCWebServices sharedInstance] fetchZone:params completion:^(id result, NSError *error){
                if (error){
                    [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
                    return;
                }
                
                NSDictionary *results = result;
                NSLog(@"%@", [results description]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *z = results[@"zones"];
                    if (z.count == 0){
                        [self.loadingIndicator stopLoading];
                        [self showAlertWithTitle:@"No Service" message:@"Sorry, Perc is not in your area yet. Hopefully we will be in your town soon!"];
                        return;
                    }
                    
                    NSDictionary *zoneInfo = z[0];
                    [self.currentZone populate:zoneInfo];
                    self.profile.lastZone = self.currentZone.uniqueId;
                    [self.profile updateProfile]; // update profile with last zone info on backend
                    [self.loadingIndicator stopLoading];
                    if ([self.currentZone.status isEqualToString:@"open"]==NO){
//                        NSString *message = self.currentZone.message;
//                        CGRect boundingRect = [message boundingRectWithSize:CGSizeMake(self.lblMessage.frame.size.width, 250.0f)
//                                                                    options:NSStringDrawingUsesLineFragmentOrigin
//                                                                 attributes:@{NSFontAttributeName:self.lblMessage.font}
//                                                                    context:nil];
//                        
//                        CGRect frame = self.lblMessage.frame;
//                        frame.size.height = boundingRect.size.height;
//                        self.lblMessage.frame = frame;
//                        self.lblMessage.text = message;
//                        self.lblMessage.alpha = 1.0f;
                        return;
                    }
                    
                    
//                    self.lblMessage.alpha = 0.0f;
//                    [self fetchVenuesForCurrentLocation];
                    
                });
            }];
        }];
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewVenues:(UIButton *)btn
{
    PCVenuesViewController *venuesVc = [[PCVenuesViewController alloc] init];
    [self.navigationController pushViewController:venuesVc animated:YES];
}

- (void)viewPosts:(UIButton *)btn
{
    if (self.currentZone.isPopulated==NO)
        return;
        
    PCPostsViewController *postsVc = [[PCPostsViewController alloc] init];
    [self.navigationController pushViewController:postsVc animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
