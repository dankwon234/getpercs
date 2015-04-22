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
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) NSArray *backgrounds;
@end

#define kPadding 12.0f

@implementation PCZoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showBackgrounds)
                                                     name:kShowBackgroundsNotification
                                                   object:nil];
    }
    
    return self;
    
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgCityStreet.png"]];
    CGRect frame = view.frame;

    CGFloat width = frame.size.width;
    CGFloat y = kPadding;
    
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, y, width-2*kPadding, 22.0f)];
    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblLocation.textAlignment = NSTextAlignmentCenter;
    self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblLocation.textColor = [UIColor whiteColor];
    [view addSubview:self.lblLocation];
    y += self.lblLocation.frame.size.height+24.0f;
    
    CGFloat w = width-3*kPadding;
    CGFloat bottomButtonHeight = 180.0f;
    CGFloat h = 0.5f*(frame.size.height-3*kPadding-bottomButtonHeight);
    y = kPadding;
    
    UIView *bgBoard = [self sectionBackgroundWithFrame:CGRectMake(kPadding, y, 0.5f*w, h) withTitle:@"Bulletin Board"];
    bgBoard.tag = 1000;
    bgBoard.alpha = 0.0f;
    [view addSubview:bgBoard];
    y += bgBoard.frame.size.height+kPadding;

    UIView *bgAccount = [self sectionBackgroundWithFrame:CGRectMake(kPadding, y, 0.5f*w, h) withTitle:@"Your Account"];
    bgAccount.tag = 1001;
    bgAccount.alpha = 0.0f;
    [view addSubview:bgAccount];
    y += bgAccount.frame.size.height+kPadding;

    UIView *bgLocation = [self sectionBackgroundWithFrame:CGRectMake(kPadding, y, frame.size.width-2*kPadding, frame.size.height-y-4*kPadding-10.0f) withTitle:@"Update Location"];
    bgLocation.tag = 1002;
    bgLocation.alpha = 0.0f;
    [view addSubview:bgLocation];
    y += bgAccount.frame.size.height+kPadding;

    UIView *bgFood = [self sectionBackgroundWithFrame:CGRectMake(2*kPadding+0.5f*w, kPadding, 0.5f*w, 2*h+kPadding) withTitle:@"Order Food"];
    bgFood.tag = 1003;
    bgFood.alpha = 0.0f;
    [view addSubview:bgFood];
    y += bgAccount.frame.size.height+kPadding;
    
    self.backgrounds = @[bgBoard, bgFood, bgLocation, bgAccount];

    
    
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
                    
                });
            }];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView *)sectionBackgroundWithFrame:(CGRect)frame withTitle:(NSString *)title
{
    UIView *background = [[UIView alloc] initWithFrame:frame];
    background.backgroundColor = [UIColor whiteColor];
//    background.alpha = 0.8f;
    background.layer.cornerRadius = 3.0f;
    background.layer.masksToBounds = YES;
    [background addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSection:)]];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 22.0f)];
    lblTitle.center = CGPointMake(lblTitle.center.x, 0.5f*frame.size.height);
    lblTitle.textColor = [UIColor darkGrayColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblTitle.text = title;
    [background addSubview:lblTitle];
    return background;
}

- (void)selectSection:(UIGestureRecognizer *)tap
{
    int tag = (int)tap.view.tag;
    NSLog(@"selectSection: %d", tag);
    
    if (tag==1000){ // view bulletin board posts
        if (self.currentZone.isPopulated==NO)
            return;
        
        PCPostsViewController *postsVc = [[PCPostsViewController alloc] init];
        [self.navigationController pushViewController:postsVc animated:YES];
    }

    if (tag==1001){ // view account
        if (self.profile.isPopulated){
            [self showAccountView];
            return;
        }
        
        [self showLoginView:YES];
    }
    
    if (tag==1002){ // update location

        
    }

    
    if (tag==1003){ // view restaurants
        PCVenuesViewController *venuesVc = [[PCVenuesViewController alloc] init];
        [self.navigationController pushViewController:venuesVc animated:YES];
    }

    
    
}

- (void)showBackgrounds
{
    for (int i=0; i<self.backgrounds.count; i++) {
        UIView *background = self.backgrounds[i];
        [UIView animateWithDuration:0.3f
                              delay:i*0.2f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             background.alpha = 0.8f;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}


//- (void)viewVenues:(UIButton *)btn
//{
//    PCVenuesViewController *venuesVc = [[PCVenuesViewController alloc] init];
//    [self.navigationController pushViewController:venuesVc animated:YES];
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
