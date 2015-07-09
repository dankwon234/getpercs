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
#import "PCPostViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCOrderViewController.h"
#import "PCVenue.h"
#import "PCOrder.h"
#import "PCVenueCell.h"
#import "PCPostView.h"
#import "UIImage+PQImageEffects.h"
#import "PCOrderFoodViewController.h"


@interface PCZoneViewController ()
@property (strong, nonatomic) UIScrollView *bulletinBoardScroll;
@property (strong, nonatomic) UIImageView *reflection;
@property (strong, nonatomic) UIView *locationView;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UICollectionView *venuesTable;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic) int currentPage;
@end

#define kPadding 12.0f
#define kPageDuration 15
static NSString *cellId = @"cellId";

@implementation PCZoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.currentPage = 0;
        
    }
    
    return self;
    
}




- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background3.png"]];
    CGRect frame = view.frame;
    
    CGFloat width = frame.size.width;
    
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
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.50f] CGColor], (id)[[UIColor clearColor] CGColor]];
    [self.reflection.layer insertSublayer:gradient atIndex:0];

    [view addSubview:self.reflection];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, y+4.0f, width, 20.0)];
    self.pageControl.numberOfPages = 0;
    [view addSubview:self.pageControl];

    

//    CGFloat h = 24.0f;
//    self.locationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-h-20.0f, width, h)];
//    self.locationView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    self.locationView.backgroundColor = [UIColor blackColor];
//    self.locationView.alpha = 0.75f;
//    [view addSubview:self.locationView];
//
//    
//    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, width, 22.0f)];
//    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    self.lblLocation.textAlignment = NSTextAlignmentCenter;
//    self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:16.0f];
//    self.lblLocation.textColor = [UIColor whiteColor];
//    [view addSubview:self.lblLocation];

    
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
        PCPost *post = (PCPost *)object;
        [post removeObserver:self forKeyPath:@"imageData"];
        
        int index = (int)[self.currentZone.posts indexOfObject:post];
        if (self.currentPage != index) // this post is not up, ignore
            return;

        dispatch_async(dispatch_get_main_queue(), ^{
            PCPostView *postView = (PCPostView *)[self.bulletinBoardScroll viewWithTag:index+1000];
            if (postView==nil) // huh?
                return;
            
            postView.postImage.image = post.imageData;
            
            if (index==0)
                [self fadeReflectionImage:post.imageData];
        });
    }

}



- (void)viewDidLoad
{
    [super viewDidLoad];
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
                    
                    [self fetchPostsForCurrentLocation];
                    
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

- (void)nextPage
{
    if (self.currentPage == self.currentZone.posts.count-1)
        self.currentPage = 0;
    else
        self.currentPage++;
    
//    NSLog(@"NEXT PAGE: %d", self.currentPage);
    CGFloat x = self.bulletinBoardScroll.frame.size.width*self.currentPage;
    [self.bulletinBoardScroll setContentOffset:CGPointMake(x, self.bulletinBoardScroll.contentOffset.y) animated:YES];
    
    PCPost *post = self.currentZone.posts[self.currentPage];
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
            
            if ([self.currentZone.uniqueId isEqualToString:venue.orderZone]==NO){
                double distance = [venue calculateDistanceFromLocation:zoneLocation];
                if (distance >= 2.0f)
                    distance -= 2.0f;
                
                venue.fee += (int)lround(distance);
            }
            
            [self.currentZone.venues addObject:venue];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutListsCollectionView];
        });
    }];
}


- (void)fetchPostsForCurrentLocation
{
    [[PCWebServices sharedInstance] fetchPosts:@{@"zone":self.currentZone.uniqueId, @"limit":@"12"} completion:^(id result, NSError *error){
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

        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat dimen = self.bulletinBoardScroll.frame.size.width;
            for (int i=0; i<self.currentZone.posts.count; i++) {
                PCPost *post = self.currentZone.posts[i];
                PCPostView *postView = [[PCPostView alloc] initWithFrame:CGRectMake(i*dimen, -64.0f, dimen, dimen)];
                postView.tag = 1000+i;
                postView.lblTitle.text = post.title;
                postView.lblDate.text = post.formattedDate;
                [postView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPost:)]];
                [self.bulletinBoardScroll addSubview:postView];
                
                // a little hacky but helps reduce latency:
                [post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
                [post performSelector:@selector(fetchImage) withObject:nil afterDelay:i*0.5f];
            }
            
            self.pageControl.numberOfPages = self.currentZone.posts.count;
            self.bulletinBoardScroll.contentSize = CGSizeMake(self.currentZone.posts.count*dimen, 0);
            [self performSelector:@selector(nextPage) withObject:nil afterDelay:kPageDuration];
            [self fetchVenuesForCurrentLocation];

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
    
    PCPost *post = self.currentZone.posts[tag];
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
    PCPost *post = (PCPost *)self.currentZone.posts[self.currentPage];
    if (post.imageData==nil)
        return;
    
    self.reflection.image = [postImage reflectedImage:post.imageData withBounds:self.reflection.bounds withHeight:self.reflection.frame.size.height];
    if (self.reflection.alpha==0)
        self.reflection.alpha = 1.0f;
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
    PCPost *post = self.currentZone.posts[page];
    if (post.imageData==nil){
        [post fetchImage];
        return;
    }
    
    [self fadeReflectionImage:post.imageData];
    
    PCPostView *postView = (PCPostView *)[self.bulletinBoardScroll viewWithTag:page+1000];
    if (postView.postImage.alpha != 0)
        return;
    
    postView.postImage.image = post.imageData;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
