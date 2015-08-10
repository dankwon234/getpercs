//
//  PCZoneViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/15/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCZoneViewController.h"
#import "PCVenueViewController.h"
#import "PCPostsViewController.h"
#import "PCPostViewController.h"
#import "PCSectionsViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCVenueCell.h"
#import "PCSectionView.h"
#import "UIImage+PQImageEffects.h"


@interface PCZoneViewController ()
@property (strong, nonatomic) UIScrollView *bulletinBoardScroll;
@property (strong, nonatomic) UIImageView *reflection;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UICollectionView *venuesTable;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *btnAccount;
@property (strong, nonatomic) UIButton *btnLocation;
@property (strong, nonatomic) UIButton *btnSections;
@property (strong, nonatomic) UIButton *btnInvited;
@property (nonatomic) int currentPage;
@property (nonatomic) BOOL showNextPage;
@end

#define kPadding 12.0f
#define kPageDuration 10
static NSString *cellId = @"cellId";

@implementation PCZoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.currentPage = 0;
        self.showNextPage = YES;
        
    }
    
    return self;
    
}

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    
    CGFloat width = frame.size.width;
    
    
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoTransparent.png"]];
    self.icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.icon.center = CGPointMake(0.5f*frame.size.width, 0.25f*frame.size.height);
    [view addSubview:self.icon];
    
    self.bulletinBoardScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, width)];
    self.bulletinBoardScroll.delegate = self;
    self.bulletinBoardScroll.backgroundColor = [UIColor clearColor];
    self.bulletinBoardScroll.pagingEnabled = YES;
    self.bulletinBoardScroll.showsHorizontalScrollIndicator = NO;
    [view addSubview:self.bulletinBoardScroll];
    
    CGFloat y = self.bulletinBoardScroll.frame.size.height;
    self.reflection = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, y, width, width)];
    self.reflection.alpha = 0;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.reflection.bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.70f] CGColor], (id)[[UIColor clearColor] CGColor]];
    [self.reflection.layer insertSublayer:gradient atIndex:0];

    [view addSubview:self.reflection];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, y+4.0f, width, 20.0)];
    self.pageControl.numberOfPages = 0;
    self.pageControl.userInteractionEnabled = NO;
    [view addSubview:self.pageControl];
    y += self.pageControl.frame.size.height;

    CGFloat x = 24.0f;
    CGFloat h = 44.0f;
    
    self.btnAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSections = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnInvited = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSArray *buttons = @[self.btnAccount, self.btnLocation, self.btnSections, self.btnInvited];
    NSArray *icons = @[@"iconInfo.png", @"iconLocation.png", @"iconCar.png", @"iconCalendar.png"];
    NSArray *titles = @[@"Account", @"Location", @"Sections", @"Events"];
    UIFont *font = [UIFont fontWithName:kBaseFontName size:16.0f];
    UIColor *white = [UIColor whiteColor];
    
    for (int i=0; i<buttons.count; i++){
        UIButton *button = buttons[i];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        button.frame = CGRectMake(x, y, frame.size.width-2*x, h);
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:white forState:UIControlStateNormal];
        button.titleLabel.font = font;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.layer.cornerRadius = 3.0f;
        button.layer.masksToBounds = YES;
        [button setImage:[UIImage imageNamed:icons[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        y += button.frame.size.height+12.0f;
    }
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint center = self.loadingIndicator.center;
    center.y += 120.0f;
    self.loadingIndicator.center = center;
    
    [self.btnAccount setTitle:(self.profile.isPopulated) ? @"Account" : @"Log In" forState:UIControlStateNormal];
    [self.profile addObserver:self forKeyPath:@"isPopulated" options:0 context:nil];
    
    BOOL connected = [[PCWebServices sharedInstance] checkConnection];
    if (connected == NO){
        [self showAlertWithTitle:@"No Connection" message:@"Please find an internet connection."];
        return;
    }
    
    [self updateLocation];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isPopulated"]){
        if (self.profile.isPopulated)
            [self.btnAccount setTitle:@"Account" forState:UIControlStateNormal];
        else
            [self.btnAccount setTitle:@"Log In" forState:UIControlStateNormal];
        
    }
    
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
    
//    if ([keyPath isEqualToString:@"imageData"]){
//        PCPost *post = (PCPost *)object;
//        [post removeObserver:self forKeyPath:@"imageData"];
//        
//        int index = (int)[self.currentZone.posts indexOfObject:post];
//        if (self.currentPage != index) // this post is not up, ignore
//            return;
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            PCSectionView *sectionView = (PCSectionView *)[self.bulletinBoardScroll viewWithTag:index+1000];
//            if (sectionView==nil) // huh?
//                return;
//            
//            sectionView.postImage.image = post.imageData;
//            if (index==0)
//                [self fadeReflectionImage:post.imageData];
//        });
//    }
    
    
    if ([keyPath isEqualToString:@"imageData"]){
        PCSection *section = (PCSection *)object;
        [section removeObserver:self forKeyPath:@"imageData"];
        
        int index = (int)[self.currentZone.sections indexOfObject:section];
        if (self.currentPage != index) // this post is not up, ignore
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PCSectionView *sectionView = (PCSectionView *)[self.bulletinBoardScroll viewWithTag:index+1000];
            if (sectionView==nil) // huh?
                return;
            
            sectionView.postImage.image = section.imageData;
            if (index==0)
                [self fadeReflectionImage:section.imageData];
        });
    }

}


#pragma mark -
- (void)buttonAction:(UIButton *)btn
{
    if ([btn isEqual:self.btnAccount])
        [self showAccountView];
    
    if ([btn isEqual:self.btnLocation])
        [self updateLocation];
    
    if ([btn isEqual:self.btnSections]){
        PCSectionsViewController *sectionsVc = [[PCSectionsViewController alloc] init];
        [self.navigationController pushViewController:sectionsVc animated:YES];
    }

    if ([btn isEqual:self.btnInvited]){
        if (self.profile.isPopulated==NO){
            [self showLoginView:YES];
            return;
        }
        
        PCPostsViewController *postsVc = [[PCPostsViewController alloc] init];
        postsVc.mode = 1;
        [self.navigationController pushViewController:postsVc animated:YES];
    }
}


- (void)updateLocation
{
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
            NSString *locationString = [NSString stringWithFormat:@"%@ (tap to change)", [townState uppercaseString]];
            [self.btnLocation setTitle:locationString forState:UIControlStateNormal];
            
            
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
                    self.currentZone.sections = nil;
                    
                    self.profile.lastZone = self.currentZone.uniqueId;
                    [self.profile updateProfile]; // update profile with last zone info on backend
                    [self.loadingIndicator stopLoading];
//                    [self.btnDrivers setTitle:[NSString stringWithFormat:@"%d Drivers on Standby", (int)self.currentZone.admins.count] forState:UIControlStateNormal];
                    
                    [self fetchPostsForCurrentLocation];
                });
            }];
        }];
    }];
}


- (void)nextPage
{
    if (self.showNextPage==NO){
        [self performSelector:@selector(nextPage) withObject:nil afterDelay:kPageDuration];
        self.showNextPage = YES;
        return;
    }
    
    if (self.currentPage == self.currentZone.sections.count-1)
        self.currentPage = 0;
    else
        self.currentPage++;
    
    CGFloat x = self.bulletinBoardScroll.frame.size.width*self.currentPage;
    [self.bulletinBoardScroll setContentOffset:CGPointMake(x, self.bulletinBoardScroll.contentOffset.y) animated:YES];
    
    PCPost *post = self.currentZone.sections[self.currentPage];
    [self fadeReflectionImage:post.imageData];

    [self performSelector:@selector(nextPage) withObject:nil afterDelay:kPageDuration];
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
        CLLocation *zoneLocation = [[CLLocation alloc] initWithLatitude:self.currentZone.latitude longitude:self.currentZone.longitude];
        
        self.currentZone.venues = [NSMutableArray array];
        NSArray *list = results[@"venues"];
        for (int i=0; i<list.count; i++) {
            NSDictionary *venueInfo = list[i];
            PCVenue *venue = [PCVenue venueWithInfo:venueInfo];
            venue.fee = self.currentZone.baseFee;
            venue.distance = [venue calculateDistanceFromLocation:self.locationMgr.clLocation];
//            NSLog(@"%@: DIST == %.2f", venue.name, venue.distance);
            
            if ([self.currentZone.uniqueId isEqualToString:venue.orderZone]==NO){
                double distance = [venue calculateDistanceFromLocation:zoneLocation];
                
                if (distance >= 2.0f)
                    distance -= 2.0f;
                
                venue.fee += (int)lround(distance);
                if (venue.fee < self.currentZone.baseFee)
                    venue.fee = self.currentZone.baseFee;
                
                if (venue.fee > 15) // this is to prevent fees of $5,000 if user does not have location turned on
                    venue.fee = 0;
            }
            
            [self.currentZone.venues addObject:venue];
        }
        

        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
        [self.currentZone.venues sortUsingDescriptors:@[sort]];
        NSLog(@"%d VENUES ! ! !", (int)self.currentZone.venues.count);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutListsCollectionView];
        });
    }];
}


//- (void)fetchPostsForCurrentLocation
//{
//    [[PCWebServices sharedInstance] fetchPosts:@{@"zone":self.currentZone.uniqueId, @"limit":@"5", @"featured":@"yes"} completion:^(id result, NSError *error){
//        [self.loadingIndicator stopLoading];
//        if (error){
//            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
//            return;
//        }
//        
//        NSDictionary *results = (NSDictionary *)result;
//        NSLog(@"%@", [results description]);
//        
//        self.currentZone.posts = [NSMutableArray array];
//        NSArray *a = results[@"posts"];
//        for (NSDictionary *postInfo in a)
//            [self.currentZone.posts addObject:[PCPost postWithInfo:postInfo]];
//        
//        NSArray *colors = @[kLightBlue, kDarkGray, kGreen, kOrange];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            CGFloat dimen = self.bulletinBoardScroll.frame.size.width;
//            for (int i=0; i<self.currentZone.posts.count; i++) {
//                PCPost *post = self.currentZone.posts[i];
//                PCSectionView *sectionView = [[PCSectionView alloc] initWithFrame:CGRectMake(i*dimen, 0.0f, dimen, dimen)];
//                sectionView.banner.backgroundColor = colors[i % colors.count];
//                sectionView.tag = 1000+i;
//                sectionView.lblTitle.text = post.title;
//                [sectionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPost:)]];
//                [self.bulletinBoardScroll addSubview:sectionView];
//                
//                // a little hacky but helps reduce latency:
//                [post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
//                [post performSelector:@selector(fetchImage) withObject:nil afterDelay:i*0.5f];
//            }
//            
//            self.pageControl.numberOfPages = self.currentZone.posts.count;
//            self.bulletinBoardScroll.contentSize = CGSizeMake(self.currentZone.posts.count*dimen, 0);
//            [self performSelector:@selector(nextPage) withObject:nil afterDelay:kPageDuration];
////            [self fetchVenuesForCurrentLocation];
//
//        });
//        
//    }];
//
//}


- (void)fetchPostsForCurrentLocation
{
    [[PCWebServices sharedInstance] fetchSections:@{@"zone":self.currentZone.uniqueId} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        self.currentZone.sections = [NSMutableArray array];
        NSArray *list = results[@"sections"];
        for (int i=0; i<list.count; i++)
            [self.currentZone.sections addObject:[PCSection sectionWithInfo:list[i]]];
            
        
        NSArray *colors = @[kLightBlue, kDarkGray, kGreen, kOrange];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat dimen = self.bulletinBoardScroll.frame.size.width;
            for (int i=0; i<self.currentZone.sections.count; i++) {
                PCSection *section = self.currentZone.sections[i];
                PCSectionView *sectionView = [[PCSectionView alloc] initWithFrame:CGRectMake(i*dimen, 0.0f, dimen, dimen)];
                sectionView.banner.backgroundColor = colors[i % colors.count];
                sectionView.tag = 1000+i;
                sectionView.lblTitle.text = section.name;
//                [sectionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPost:)]];
                [self.bulletinBoardScroll addSubview:sectionView];
                
                // a little hacky but helps reduce latency:
                [section addObserver:self forKeyPath:@"imageData" options:0 context:nil];
                [section performSelector:@selector(fetchImage) withObject:nil afterDelay:i*0.5f];
            }
            
            self.pageControl.numberOfPages = self.currentZone.sections.count;
            self.bulletinBoardScroll.contentSize = CGSizeMake(self.currentZone.sections.count*dimen, 0);
            if (self.currentZone.sections.count > 1)
                [self performSelector:@selector(nextPage) withObject:nil afterDelay:kPageDuration];
            
            //            [self fetchVenuesForCurrentLocation];
            
        });
        

        
    }];
    
    
    /*
    [[PCWebServices sharedInstance] fetchPosts:@{@"zone":self.currentZone.uniqueId, @"limit":@"5", @"featured":@"yes"} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        self.currentZone.posts = [NSMutableArray array];
        NSArray *a = results[@"posts"];
        for (NSDictionary *postInfo in a)
            [self.currentZone.posts addObject:[PCPost postWithInfo:postInfo]];
        
        NSArray *colors = @[kLightBlue, kDarkGray, kGreen, kOrange];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat dimen = self.bulletinBoardScroll.frame.size.width;
            for (int i=0; i<self.currentZone.posts.count; i++) {
                PCPost *post = self.currentZone.posts[i];
                PCSectionView *sectionView = [[PCSectionView alloc] initWithFrame:CGRectMake(i*dimen, 0.0f, dimen, dimen)];
                sectionView.banner.backgroundColor = colors[i % colors.count];
                sectionView.tag = 1000+i;
                sectionView.lblTitle.text = post.title;
                [sectionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPost:)]];
                [self.bulletinBoardScroll addSubview:sectionView];
                
                // a little hacky but helps reduce latency:
                [post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
                [post performSelector:@selector(fetchImage) withObject:nil afterDelay:i*0.5f];
            }
            
            self.pageControl.numberOfPages = self.currentZone.posts.count;
            self.bulletinBoardScroll.contentSize = CGSizeMake(self.currentZone.posts.count*dimen, 0);
            [self performSelector:@selector(nextPage) withObject:nil afterDelay:kPageDuration];
            //            [self fetchVenuesForCurrentLocation];
            
        });
        
    }];
     
     */
    
    
    
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
                             self.venuesTable.delegate = nil;
                             self.venuesTable.dataSource = nil;
                             [self.venuesTable removeFromSuperview];
                             self.venuesTable = nil;
                             [self layoutListsCollectionView];
                         }];
        
        return;
    }
    
    CGRect frame = self.view.frame;
    
    CGFloat height = [PCCollectionViewFlowLayout cellHeight]+6.0f;
    
    CGFloat y = self.view.frame.size.height-height-24.0f;
    self.venuesTable = [[UICollectionView alloc] initWithFrame:CGRectMake(frame.size.width, y, frame.size.width, height) collectionViewLayout:[[PCCollectionViewFlowLayout alloc] init]];
    self.venuesTable.backgroundColor = [UIColor clearColor];
    
    [self.venuesTable registerClass:[PCVenueCell class] forCellWithReuseIdentifier:cellId];
    self.venuesTable.contentInset = UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f);
    self.venuesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.venuesTable.showsHorizontalScrollIndicator = NO;
    self.venuesTable.dataSource = self;
    self.venuesTable.delegate = self;
    [self.view addSubview:self.venuesTable];
    [self refreshVenuesCollectionView];
    
    [self.loadingIndicator stopLoading];
    
    [UIView animateWithDuration:1.25f
                          delay:0.75f // delay gives collection view time to 'set up' and therefore not intefere with animation
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.venuesTable.frame;
                         self.venuesTable.frame = CGRectMake(0.0f, y, frame.size.width, frame.size.height);
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


- (void)viewPost:(UIGestureRecognizer *)tap
{
    int tag = (int)tap.view.tag-1000;
    NSLog(@"viewPost: %d", tag);
    
    PCPost *post = self.currentZone.sections[tag];
    PCPostViewController *postVc = [[PCPostViewController alloc] init];
    postVc.post = post;
    [self.navigationController pushViewController:postVc animated:YES];
}

- (void)addNavigationTitleView
{
    // override because we actually don't want it in this view
}

- (void)fadeReflectionImage:(UIImage *)postImage
{
    PCSection *section = (PCSection *)self.currentZone.sections[self.currentPage];
    if (section.imageData==nil)
        return;
    
    self.reflection.image = [postImage reflectedImage:section.imageData withBounds:self.reflection.bounds withHeight:self.reflection.frame.size.height];
    if (self.reflection.alpha==0)
        self.reflection.alpha = 1.0f;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentZone.venues.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCVenueCell *cell = (PCVenueCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    PCVenue *venue = (PCVenue *)self.currentZone.venues[indexPath.row];
    cell.lblTitle.text = venue.name;
    cell.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [venue.city capitalizedString], [venue.state uppercaseString]];
    cell.tag = indexPath.row+1000;
    cell.lblDetails.text = [NSString stringWithFormat:@"%.1f miles", venue.distance];
    
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

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.bulletinBoardScroll])
        return;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if ([scrollView isEqual:self.bulletinBoardScroll])
        return;
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewWillBeginDecelerating:");
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.bulletinBoardScroll]==NO)
        return;
    
    [self checkPostImage:NO];
    self.showNextPage = NO; // this resets the timer
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.bulletinBoardScroll]==NO)
        return;
    
    [self checkPostImage:YES];
}

- (void)checkPostImage:(BOOL)alwaysChange
{
    UIScrollView *scrollView = self.bulletinBoardScroll;
    CGFloat x = scrollView.contentOffset.x;
    int page = (int)x/scrollView.frame.size.width;
    self.pageControl.currentPage = page;
    
    if (page==self.currentPage && alwaysChange==NO)
        return;
    
    
    self.currentPage = page;
    PCSection *section = self.currentZone.sections[page];
    if (section.imageData==nil){
        [section fetchImage];
        return;
    }
    
    [self fadeReflectionImage:section.imageData];
    
    PCSectionView *sectionView = (PCSectionView *)[self.bulletinBoardScroll viewWithTag:page+1000];
    if (sectionView.postImage.alpha != 0)
        return;
    
    sectionView.postImage.image = section.imageData;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
