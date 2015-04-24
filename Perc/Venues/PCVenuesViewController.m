//
//  PCVenuesViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenuesViewController.h"
#import "PCVenueViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCOrderHistoryViewController.h"
#import "PCVenue.h"
#import "PCVenueCell.h"


@interface PCVenuesViewController ()
@property (strong, nonatomic) UICollectionView *venuesTable;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UIButton *btnOrderHistory;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f

@implementation PCVenuesViewController


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
    self.btnOrderHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnOrderHistory.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnOrderHistory.frame = CGRectMake(x, y, frame.size.width-2*x, h);
    self.btnOrderHistory.backgroundColor = [UIColor clearColor];
    self.btnOrderHistory.layer.cornerRadius = 0.5f*h;
    self.btnOrderHistory.layer.masksToBounds = YES;
    self.btnOrderHistory.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnOrderHistory.layer.borderWidth = 1.0f;
    self.btnOrderHistory.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.btnOrderHistory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnOrderHistory setTitle:@"Order History" forState:UIControlStateNormal];
    [self.btnOrderHistory addTarget:self action:@selector(viewOrderHistory:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnOrderHistory];
    y += self.btnOrderHistory.frame.size.height+20.0f;

    
    self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, frame.size.width-40.0f, 22.0f)];
    self.lblMessage.textColor = [UIColor darkGrayColor];
    self.lblMessage.numberOfLines = 0;
    self.lblMessage.textAlignment = NSTextAlignmentCenter;
    self.lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblMessage.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblMessage.alpha = 0.0f;
    self.lblMessage.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.lblMessage];
    
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
    
    [UIView animateWithDuration:45.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGPoint center = self.background.center;
                         center.y -= 200.0f;
                         center.x -= 110.0f;
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

- (void)viewOrderHistory:(UIButton *)btn
{
    PCOrderHistoryViewController *orderHistoryVc = [[PCOrderHistoryViewController alloc] init];
    [self.navigationController pushViewController:orderHistoryVc animated:YES];
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
    

    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.venuesTable.contentOffset.y;
        if (offset < -kTopInset){
            self.icon.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        self.icon.alpha = 1.0f-(distance/100.0f);
        self.btnOrderHistory.alpha = self.icon.alpha;
    }
}





- (void)layoutListsCollectionView
{
    if (self.venuesTable){
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
    [self.view bringSubviewToFront:self.btnOrderHistory];
    
    [self refreshVenuesCollectionView];
    
    
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
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.currentZone.venues.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.venuesTable reloadItemsAtIndexPaths:indexPaths];
    });
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    NSLog(@"collectionView numberOfItemsInSection: %d", self.posts.count);
    return self.currentZone.venues.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCVenueCell *cell = (PCVenueCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    [cell.btnOrder addTarget:self action:@selector(viewVenue:) forControlEvents:UIControlEventTouchUpInside];
    
    PCVenue *venue = (PCVenue *)self.currentZone.venues[indexPath.row];
    cell.lblTitle.text = venue.name;
    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [venue.city capitalizedString], [venue.state uppercaseString]];
    cell.tag = indexPath.row+1000;
    cell.btnOrder.tag = cell.tag;
    cell.lblDetails.text = [NSString stringWithFormat:@"Min Delivery Fee: $%d \u00b7 %.1f mi", venue.fee, venue.distance];
    
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


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([PCCollectionViewFlowLayout cellWidth], [PCCollectionViewFlowLayout cellHeight]);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCVenue *venue = self.currentZone.venues[indexPath.row];
    [self segueToVenue:venue];
}

- (void)viewVenue:(UIButton *)btn
{
    PCVenue *venue = self.currentZone.venues[btn.tag-1000];
    [self segueToVenue:venue];
}

- (void)segueToVenue:(PCVenue *)venue
{
    NSLog(@"segueToVenue: %@", venue.name);
    PCVenueViewController *venueVc = [[PCVenueViewController alloc] init];
    venueVc.venue = venue;
    [self.navigationController pushViewController:venueVc animated:YES];
    
}






@end
