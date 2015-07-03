//
//  PCVenuesViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenuesViewController.h"
#import "PCVenueViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCOrderViewController.h"
#import "PCVenue.h"
#import "PCOrder.h"
#import "PCVenueCell.h"


@interface PCVenuesViewController ()
@property (strong, nonatomic) UICollectionView *venuesTable;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UIButton *btnOrderHistory;
@property (strong, nonatomic) UIButton *btnVenues;
@property (strong, nonatomic) UIView *optionsView;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f

@implementation PCVenuesViewController
@synthesize mode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.mode = 0;
        
    }
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor yellowColor];
    CGRect frame = view.frame;
    
    UIImage *imgBackground = [UIImage imageNamed:@"bgCoffeeLarge.png"];
    self.background = [[UIImageView alloc] initWithImage:imgBackground];
    self.background.frame = CGRectMake(0.0f, 0.0f, imgBackground.size.width, imgBackground.size.height);
    self.background.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:self.background];
    
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    self.icon.center = CGPointMake(0.5f*frame.size.width, 88.0f);
    self.icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.icon.layer.cornerRadius = 0.5f*self.icon.frame.size.height;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.borderWidth = 1.0f;
    self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    [view addSubview:self.icon];
    
    CGFloat h = 44.0f;
    CGFloat x = 20.0f;
    CGFloat y = self.icon.frame.origin.y+self.icon.frame.size.height+20.0f;
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, frame.size.width-2*x, 18.0f)];
    self.lblTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.text = @"Venues";
    [view addSubview:self.lblTitle];
//    y += self.lblTitle.frame.size.height+6.0f;

    
    y = 240.0f;
    self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, frame.size.width-40.0f, 22.0f)];
    self.lblMessage.textColor = [UIColor darkGrayColor];
    self.lblMessage.numberOfLines = 0;
    self.lblMessage.textAlignment = NSTextAlignmentCenter;
    self.lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblMessage.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblMessage.alpha = 0.0f;
    self.lblMessage.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.lblMessage];
    
    self.optionsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.optionsView.backgroundColor = [UIColor blackColor];
    self.optionsView.alpha = 0.0f;
    
    y = 180.0f;
    self.btnOrderHistory = [self optionButtonWithFrame:CGRectMake(x, y, frame.size.width-2*x, h) withTite:@"Order History"];
    [self.btnOrderHistory addTarget:self action:@selector(viewOrderHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsView addSubview:self.btnOrderHistory];
    y += self.btnOrderHistory.frame.size.height+20.0f;

    self.btnVenues = [self optionButtonWithFrame:CGRectMake(x, y, frame.size.width-2*x, h) withTite:@"Venues"];
    [self.btnVenues addTarget:self action:@selector(viewVenues:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsView addSubview:self.btnVenues];

    
    [self.optionsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOptionsView:)]];
    [view addSubview:self.optionsView];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    
    self.view = view;
}

- (void)dealloc
{
    [self.venuesTable removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    UIImage *imgDots = [UIImage imageNamed:@"dots"];
    UIButton *btnDots = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDots.frame = CGRectMake(0.0f, 0.0f, 0.6f*imgDots.size.width, 0.6f*imgDots.size.height);
    [btnDots setBackgroundImage:imgDots forState:UIControlStateNormal];
    [btnDots addTarget:self action:@selector(toggleOptionsView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnDots];

    
    [UIView animateWithDuration:45.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGPoint center = self.background.center;
                         center.y -= 200.0f;
                         center.x += 90.0f;
                         self.background.center = center;
                         self.background.transform = CGAffineTransformMakeScale(1.4f, 1.4f);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    if (self.currentZone.isPopulated==NO){
        self.lblMessage.alpha = 0.7f;
        NSString *msg = [NSString stringWithFormat:@"Sorry, PERC is not in your area yet. Hopefully we'll be in %@ soon!", [self.locationMgr.cities[0] uppercaseString]];
        
        CGRect textBounds = [msg boundingRectWithSize:CGSizeMake(self.lblMessage.frame.size.width, 360.0f)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:self.lblMessage.font}
                                              context:nil];
        CGRect frame = self.lblMessage.frame;
        frame.size.height = textBounds.size.height+24.0f;
        self.lblMessage.frame = frame;
        
        self.lblMessage.text = msg;
        return;
    }

    
    if (self.currentZone.venues){
        [self layoutListsCollectionView];
        return;
    }
    
    [self.loadingIndicator startLoading];
    [self fetchVenuesForCurrentLocation];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.venuesTable.collectionViewLayout invalidateLayout];
}

- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (UIButton *)optionButtonWithFrame:(CGRect)frame withTite:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.frame = frame;
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.cornerRadius = 0.5f*frame.size.height;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn.layer.borderWidth = 1.0f;
    btn.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}



- (void)toggleOptionsView:(id)sender
{
    if (self.optionsView.alpha == 0.0f){
        [self showOptionsView:nil];
        return;
    }
    
    [self hideOptionsView:nil];
}

- (void)hideOptionsView:(UIGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.35f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.optionsView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)showOptionsView:(UIButton *)btn
{
    [UIView animateWithDuration:0.35f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.optionsView.alpha = 0.90f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)viewVenues:(UIButton *)btn
{
    [self hideOptionsView:nil];
    if (self.mode==0)
        return;

    self.mode = 0;
    self.lblTitle.text = @"Venues";
    [self layoutListsCollectionView];
}

- (void)viewOrderHistory:(UIButton *)btn
{
    if (self.profile.isPopulated==NO){
        UIAlertView *alert = [self showAlertWithTitle:@"Log In" message:@"Please log in or register to view your order history."];
        alert.delegate = self;
        return;
    }

    [self hideOptionsView:nil];
    if (self.mode==1)
        return;
    
   self.mode = 1;
    self.lblTitle.text = @"Order History";
    
    if (self.profile.orderHistory != nil){
        if (self.profile.orderHistory.count==0){
            self.venuesTable.alpha = 0.0f;
            self.lblMessage.alpha = 1.0f;
            self.lblMessage.text = @"You have no previous orders.";
        }
        else{
            self.lblMessage.alpha = 0.0f;
            [self layoutListsCollectionView];
        }
        
        return;
    }
    
    self.profile.orderHistory = [NSMutableArray array];
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] fetchOrdersForProfile:self.profile completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"ORDER HISTORY: %@", [results description]);
        NSArray *list = results[@"orders"];
        if (list.count==0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3f
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.venuesTable.alpha = 0.0f;
                                     self.lblMessage.alpha = 1.0f;
                                     self.lblMessage.text = @"You have no previous orders.";
                                 }
                                 completion:NULL];
            });
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CLLocation *zoneLocation = [[CLLocation alloc] initWithLatitude:self.currentZone.latitude longitude:self.currentZone.longitude];
            
            for (int i=0; i<list.count; i++) {
                NSDictionary *orderInfo = list[i];
                PCOrder *order = [PCOrder orderWithInfo:orderInfo];
                
                order.venue.distance = [order.venue calculateDistanceFromLocation:self.locationMgr.clLocation];
                order.venue.fee = self.currentZone.baseFee;
                
                
                if ([self.currentZone.uniqueId isEqualToString:order.venue.orderZone]==NO){
                    double distance = [order.venue calculateDistanceFromLocation:zoneLocation];
                    
                    if (distance >= 2.0f)
                        distance -= 2.0f;
                    
                    order.venue.fee += (int)lround(distance);
                }
                
                [self.profile.orderHistory addObject:order];
            }
            
            [self layoutListsCollectionView];
        });
        
    }];
    
}

- (void)fetchVenuesForCurrentLocation
{
    NSLog(@"FETCH VENUES FOR CURRENT LOCATION");
    CLLocationCoordinate2D coordinate = self.locationMgr.currentLocation;
    NSString *lat = [NSString stringWithFormat:@"%.6f", coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%.6f", coordinate.longitude];
    
    [[PCWebServices sharedInstance] fetchVenuesNearLocation:@{@"lat":lat, @"lng":lng} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = result;
        NSLog(@"%@", [results description]);
        
        CLLocation *zoneLocation = [[CLLocation alloc] initWithLatitude:self.currentZone.latitude longitude:self.currentZone.longitude];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentZone.venues = [NSMutableArray array];
            NSArray *list = results[@"venues"];
            for (int i=0; i<list.count; i++) {
                NSDictionary *venueInfo = list[i];
                PCVenue *venue = [PCVenue venueWithInfo:venueInfo];
                venue.fee = self.currentZone.baseFee;
                venue.distance = [venue calculateDistanceFromLocation:self.locationMgr.clLocation];
                
                if ([self.currentZone.uniqueId isEqualToString:venue.orderZone]==NO){
                    double distance = [venue calculateDistanceFromLocation:zoneLocation];
                    if (distance >= 2.0f)
                        distance -= 2.0f;
                    
                    venue.fee += (int)lround(distance);
                }
                
                [self.currentZone.venues addObject:venue];
            }
            
            [self layoutListsCollectionView];
        });
        
    }];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"iconData"]){
        PCVenue *venue = (PCVenue *)object;
        [venue removeObserver:self forKeyPath:@"iconData"];
        
        //this is smoother than a conventional reload. it doesn't stutter the UI:
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = (int)[self.currentZone.venues indexOfObject:venue];
            PCVenueCell *cell = (PCVenueCell *)[self.venuesTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = venue.iconData;
        });
    }
    
    if ([keyPath isEqualToString:@"imageData"]){
        PCOrder *order = (PCOrder *)object;
        [order removeObserver:self forKeyPath:@"imageData"];
        
        //this is smoother than a conventional reload. it doesn't stutter the UI:
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = (int)[self.profile.orderHistory indexOfObject:order];
            PCVenueCell *cell = (PCVenueCell *)[self.venuesTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = order.imageData;
        });
    }
    

    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.venuesTable.contentOffset.y;
        if (offset < -kTopInset){
            self.icon.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        self.icon.alpha = 1.0f-(distance/100.0f);
        self.lblTitle.alpha = self.icon.alpha;
    }
}





- (void)layoutListsCollectionView
{
    if (self.venuesTable){
        [self.loadingIndicator startLoading];
        [UIView animateWithDuration:0.40f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = self.venuesTable.frame;
                             self.venuesTable.frame = CGRectMake(frame.origin.x, self.view.frame.size.height, frame.size.width, frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             [self.venuesTable removeObserver:self forKeyPath:@"contentOffset"];
                             self.venuesTable.delegate = nil;
                             self.venuesTable.dataSource = nil;
                             [self.venuesTable removeFromSuperview];
                             self.venuesTable = nil;
                             [self layoutListsCollectionView];
                         }];
        
        return;
    }
    
    self.lblMessage.alpha = 0.0f;
    CGRect frame = self.view.frame;
    
    self.venuesTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-20.0f) collectionViewLayout:[[PCCollectionViewFlowLayout alloc] init]];
    self.venuesTable.backgroundColor = [UIColor clearColor];
    
    [self.venuesTable registerClass:[PCVenueCell class] forCellWithReuseIdentifier:cellId];
    self.venuesTable.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, 24.0f, 0);
    self.venuesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.venuesTable.dataSource = self;
    self.venuesTable.delegate = self;
    self.venuesTable.showsVerticalScrollIndicator = NO;
    [self.venuesTable addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [self.view addSubview:self.venuesTable];
    [self.view bringSubviewToFront:self.optionsView];
    
    [self refreshVenuesCollectionView];
    
    
    [self.loadingIndicator stopLoading];
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.venuesTable.frame;
                         self.venuesTable.frame = CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)refreshVenuesCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.venuesTable.collectionViewLayout invalidateLayout];
        [self.venuesTable reloadData];
        
        NSArray *dataArray = (self.mode==0) ? self.currentZone.venues : self.profile.orderHistory;
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<dataArray.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.venuesTable reloadItemsAtIndexPaths:indexPaths];
    });
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex == %ld", (long)buttonIndex);
    [self showLoginView:YES]; // not logged in - go to log in / register view controller
}




#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    NSLog(@"collectionView numberOfItemsInSection: %d", self.posts.count);
    if (self.mode==0)
        return self.currentZone.venues.count;
        

    return self.profile.orderHistory.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCVenueCell *cell = (PCVenueCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
//    [cell.btnOrder addTarget:self action:@selector(viewVenue:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.mode==0){
        PCVenue *venue = (PCVenue *)self.currentZone.venues[indexPath.row];
        cell.lblTitle.text = venue.name;
        cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [venue.city capitalizedString], [venue.state uppercaseString]];
        cell.tag = indexPath.row+1000;
//        cell.btnOrder.tag = cell.tag;
        cell.lblDetails.text = [NSString stringWithFormat:@"Min Delivery Fee: $%d \u00b7 %.1f mi", venue.fee, venue.distance];
//        cell.btnOrder.alpha = 1.0f;
        
        if ([venue.icon isEqualToString:@"none"]){
            cell.icon.image = [UIImage imageNamed:@"logo.png"];
            return cell;
        }
        
        if (venue.iconData){
            cell.icon.image = venue.iconData;
            return cell;
        }
        
        cell.icon.image = [UIImage imageNamed:@"icon.png"];
        [venue addObserver:self forKeyPath:@"iconData" options:0 context:nil];
        [venue fetchImage];
        return cell;
    }
    
    
    //ORDER HISTORY:
    PCOrder *order = (PCOrder *)self.profile.orderHistory[indexPath.row];
    cell.lblTitle.text = order.venue.name;
    cell.lblLocation.text = order.formattedDate;
    cell.tag = indexPath.row+1000;
//    cell.btnOrder.tag = cell.tag;
    cell.lblDetails.text = order.address;
//    cell.btnOrder.alpha = 0;
    
    if ([order.image isEqualToString:@"none"]){
        cell.icon.image = [UIImage imageNamed:@"logo.png"];
        return cell;
    }
    
    if (order.imageData){
        cell.icon.image = order.imageData;
        return cell;
    }
    
    [order addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [order fetchImage];

    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([PCCollectionViewFlowLayout cellWidth], [PCCollectionViewFlowLayout cellHeight]);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mode==0){
        PCVenue *venue = self.currentZone.venues[indexPath.row];
        [self segueToVenue:venue];
        return;
    }
    
    PCOrder *order = (PCOrder *)self.profile.orderHistory[indexPath.row];
    [self segueToOrder:order];
    
}

- (void)viewVenue:(UIButton *)btn
{
    PCVenue *venue = self.currentZone.venues[btn.tag-1000];
    [self segueToVenue:venue];
    return;
}

- (void)segueToVenue:(PCVenue *)venue
{
    NSLog(@"segueToVenue: %@", venue.name);
    PCVenueViewController *venueVc = [[PCVenueViewController alloc] init];
    venueVc.venue = venue;
    [self.navigationController pushViewController:venueVc animated:YES];
    
}


- (void)viewOrder:(UIButton *)btn
{
    PCOrder *order = (PCOrder *)self.profile.orderHistory[btn.tag-1000];
    [self segueToOrder:order];
}


- (void)segueToOrder:(PCOrder *)order
{
    //    NSLog(@"segueToVenue: %@", venue.name);
    PCOrderViewController *orderVc = [[PCOrderViewController alloc] init];
    orderVc.order = order;
    [self.navigationController pushViewController:orderVc animated:YES];
    
}




@end
