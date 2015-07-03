//
//  PCZoneViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/15/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCZoneViewController.h"
#import "PCVenuesViewController.h"
#import "PCVenueViewController.h"
#import "PCPostsViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCOrderViewController.h"
#import "PCVenue.h"
#import "PCOrder.h"
#import "PCVenueCell.h"


@interface PCZoneViewController ()
@property (strong, nonatomic) UIScrollView *bulletinBoardScroll;
@property (strong, nonatomic) UIView *locationView;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UICollectionView *venuesTable;
@end

#define kPadding 12.0f
#define kTopInset 260.0f
static NSString *cellId = @"cellId";

@implementation PCZoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;

        
    }
    
    return self;
    
}

- (void)dealloc
{
    [self.venuesTable removeObserver:self forKeyPath:@"contentOffset"];
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBlurry.png"]];
    CGRect frame = view.frame;
    
    self.bulletinBoardScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, kTopInset)];
    self.bulletinBoardScroll.backgroundColor = [UIColor blackColor];
    [view addSubview:self.bulletinBoardScroll];
    
    
    CGFloat h = 24.0f;
    self.locationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-h-20.0f, frame.size.width, h)];
    self.locationView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationView.backgroundColor = [UIColor blackColor];
    self.locationView.alpha = 0.75f;
    [view addSubview:self.locationView];

    
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, 22.0f)];
    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblLocation.textAlignment = NSTextAlignmentCenter;
    self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblLocation.textColor = [UIColor whiteColor];
    [view addSubview:self.lblLocation];

    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewMenu:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    self.view = view;
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
    
    
//    if ([keyPath isEqualToString:@"contentOffset"]){
//        CGFloat offset = self.venuesTable.contentOffset.y;
//        if (offset < -kTopInset){
//            self.icon.alpha = 1.0f;
//            return;
//        }
//        
//        double distance = offset+kTopInset;
//        self.icon.alpha = 1.0f-(distance/100.0f);
//        self.lblTitle.alpha = self.icon.alpha;
//    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    [self addOptionsButton];
    

    BOOL connected = [[PCWebServices sharedInstance] checkConnection];
    if (connected==NO){
        [self showAlertWithTitle:@"No Connection" message:@"Please find an internet connection."];
        return;
    }

    [self updateLocation];
}

- (void)updateLocation
{
    [self.loadingIndicator startLoading];
    self.lblLocation.text = @"Finding Location...";
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
            self.lblLocation.text = [NSString stringWithFormat:@"Currently in %@", [townState uppercaseString]];
            [UIView animateWithDuration:0.3f
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 CGRect frame = self.lblLocation.frame;
                                 frame.origin.y = self.locationView.frame.origin.y+2.0f;
                                 self.lblLocation.frame = frame;
                                 
                             }
                             completion:NULL];
            
            
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
                    self.currentZone.venues = nil;
                    self.currentZone.posts = nil;
                    
                    self.profile.lastZone = self.currentZone.uniqueId;
                    [self.profile updateProfile]; // update profile with last zone info on backend
                    [self.loadingIndicator stopLoading];
                    
                    [self fetchVenuesForCurrentLocation];
                    
                    
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


- (void)selectSection:(UIGestureRecognizer *)tap
{
    int tag = (int)tap.view.tag;
    NSLog(@"selectSection: %d", tag);
    
    if (tag==1000){ // order food
        PCVenuesViewController *venuesVc = [[PCVenuesViewController alloc] init];
        [self.navigationController pushViewController:venuesVc animated:YES];
    }

    if (tag==1001){ // view bulletin board posts
        PCPostsViewController *postsVc = [[PCPostsViewController alloc] init];
        [self.navigationController pushViewController:postsVc animated:YES];
    }

    if (tag==1002){ // update location
        [self updateLocation];
    }
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
//        NSLog(@"%@", [results description]);
        
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
            [self fetchPostsForCurrentLocation];
        });
        
    }];
}


- (void)fetchPostsForCurrentLocation
{
    [[PCWebServices sharedInstance] fetchPostsInZone:self.currentZone.uniqueId completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentZone.posts = [NSMutableArray array];
            NSArray *a = results[@"posts"];
            for (NSDictionary *postInfo in a)
                [self.currentZone.posts addObject:[PCPost postWithInfo:postInfo]];
            
            
            int max = (self.currentZone.posts.count > 3) ? 3 : (int)self.currentZone.posts.count;
            for (int i=0; i<max; i++) {
                PCPost *post = self.currentZone.posts[i];
                UIView *postView = [[UIView alloc] initWithFrame:CGRectMake(i*kTopInset, -64.0f, kTopInset, kTopInset)];
                postView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                postView.backgroundColor = [UIColor greenColor];
                [self.bulletinBoardScroll addSubview:postView];
            }
            
            self.bulletinBoardScroll.contentSize = CGSizeMake(max*kTopInset, 0);
            
            
//            if (self.currentZone.posts.count==0)
//                [self showAlertWithTitle:@"No Posts" message:@"This area has no posts. To add one, tap the icon in the upper right corner."];
        });
        
    }];

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
    
    CGRect frame = self.view.frame;
    self.venuesTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-kTopInset-20.0f) collectionViewLayout:[[PCCollectionViewFlowLayout alloc] init]];
    self.venuesTable.backgroundColor = [UIColor clearColor];
    
    [self.venuesTable registerClass:[PCVenueCell class] forCellWithReuseIdentifier:cellId];
    self.venuesTable.contentInset = UIEdgeInsetsMake(24.0f, 0.0f, 48.0f, 0);
    self.venuesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.venuesTable.dataSource = self;
    self.venuesTable.delegate = self;
    self.venuesTable.showsVerticalScrollIndicator = NO;
    [self.venuesTable addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [self.view addSubview:self.venuesTable];
    [self.view bringSubviewToFront:self.locationView];
    [self.view bringSubviewToFront:self.lblLocation];
    
    [self refreshVenuesCollectionView];
    
    
    [self.loadingIndicator stopLoading];
    [UIView animateWithDuration:1.40f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.venuesTable.frame;
                         self.venuesTable.frame = CGRectMake(frame.origin.x, kTopInset, frame.size.width, frame.size.height);
                         
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
    cell.btnOrder.alpha = 1.0f;
    
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
