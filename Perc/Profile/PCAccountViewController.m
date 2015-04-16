//
//  PCAccountViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCAccountViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCOrderViewController.h"
#import "PCVenueCell.h"

@interface PCAccountViewController ()
@property (strong, nonatomic) UICollectionView *ordersTable;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblDescription;
@property (strong, nonatomic) UILabel *lblName;
@property (strong, nonatomic) UILabel *lblOrderHistory;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f


@implementation PCAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    return self;
}

- (void)dealloc
{
    [self.ordersTable removeObserver:self forKeyPath:@"contentOffset"];
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBurger.png"]];
    CGRect frame = view.frame;
    
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    self.icon.center = CGPointMake(0.5f*frame.size.width, 88.0f);
    self.icon.layer.cornerRadius = 0.5f*self.icon.frame.size.height;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.borderWidth = 1.0f;
    self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    [view addSubview:self.icon];
    CGFloat y = self.icon.frame.origin.y+self.icon.frame.size.height+16.0f;
    
    self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, frame.size.width-40.0f, 22.0f)];
    self.lblName.textAlignment = NSTextAlignmentCenter;
    self.lblName.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblName.text = [NSString stringWithFormat:@"%@ %@", [self.profile.firstName uppercaseString], [self.profile.lastName uppercaseString]];
    [view addSubview:self.lblName];
    y += self.lblName.frame.size.height;
    
    self.lblOrderHistory = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, frame.size.width-40.0f, 22.0f)];
    self.lblOrderHistory.textAlignment = NSTextAlignmentCenter;
    self.lblOrderHistory.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblOrderHistory.textColor = [UIColor whiteColor];
    self.lblOrderHistory.text = @"Order History";
    [view addSubview:self.lblOrderHistory];
    y += self.lblOrderHistory.frame.size.height+36.0f;

    
    self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, frame.size.width-40.0f, 150.0f)];
    self.lblDescription.numberOfLines = 0;
    self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblDescription.textAlignment = NSTextAlignmentCenter;
    self.lblDescription.textColor = [UIColor whiteColor];
    self.lblDescription.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblDescription.backgroundColor = [UIColor clearColor];
    self.lblDescription.text = @"This page shows your order history on Perc. Once an order is confirmed and delivered, the full price and delivery fee can be reviewed in this section as well.";
    self.lblDescription.alpha = 0.0f;
    [view addSubview:self.lblDescription];
    y += self.lblDescription.frame.size.height+16.0f;

    
    
    

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    UIBarButtonItem *btnLogout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(logout:)];
    self.navigationItem.rightBarButtonItem = btnLogout;
    
    
    if (self.profile.orderHistory){
        if (self.profile.orderHistory.count==0)
            self.lblDescription.alpha = 1.0f;
        else
            [self layoutCollectionView];
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
                                     self.lblDescription.alpha = 1.0f;
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
            [self layoutCollectionView];
        });
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.ordersTable.collectionViewLayout invalidateLayout];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        PCOrder *order = (PCOrder *)object;
        [order removeObserver:self forKeyPath:@"imageData"];
        
        //this is smoother than a conventional reload. it doesn't stutter the UI:
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = (int)[self.profile.orderHistory indexOfObject:order];
            PCVenueCell *cell = (PCVenueCell *)[self.ordersTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = order.imageData;
        });
    }
    
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.ordersTable.contentOffset.y;
        if (offset < -kTopInset){
            self.icon.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        self.icon.alpha = 1.0f-(distance/100.0f);
        self.lblName.alpha = self.icon.alpha;
        self.lblOrderHistory.alpha = self.icon.alpha;
    }
}

- (void)logout:(id)sender
{
    [self.profile clear];
    [self back:nil];
}


- (void)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)layoutCollectionView
{
    if (self.ordersTable){
        [UIView animateWithDuration:0.40f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = self.ordersTable.frame;
                             self.ordersTable.frame = CGRectMake(frame.origin.x, self.view.frame.size.height, frame.size.width, frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             [self.ordersTable removeObserver:self forKeyPath:@"contentOffset"];
                             self.ordersTable.delegate = nil;
                             self.ordersTable.dataSource = nil;
                             [self.ordersTable removeFromSuperview];
                             self.ordersTable = nil;
                             [self layoutCollectionView];
                         }];
        
        return;
    }
    
    CGRect frame = self.view.frame;
    
    self.ordersTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-20.0f) collectionViewLayout:[[PCCollectionViewFlowLayout alloc] init]];
    self.ordersTable.backgroundColor = [UIColor clearColor];
    
    [self.ordersTable registerClass:[PCVenueCell class] forCellWithReuseIdentifier:cellId];
    self.ordersTable.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, 24.0f, 0);
    self.ordersTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.ordersTable.dataSource = self;
    self.ordersTable.delegate = self;
    self.ordersTable.showsVerticalScrollIndicator = NO;
    [self.ordersTable addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [self.view addSubview:self.ordersTable];
    
    [self refreshCollectionView];
    
    
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.ordersTable.frame;
                         self.ordersTable.frame = CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)refreshCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ordersTable.collectionViewLayout invalidateLayout];
        [self.ordersTable reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.profile.orderHistory.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.ordersTable reloadItemsAtIndexPaths:indexPaths];
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
    return self.profile.orderHistory.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCVenueCell *cell = (PCVenueCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    [cell.btnOrder addTarget:self action:@selector(viewOrder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnOrder setTitle:@"VIEW ORDER" forState:UIControlStateNormal];
    
    PCOrder *order = (PCOrder *)self.profile.orderHistory[indexPath.row];
    cell.lblTitle.text = order.venue.name;
    cell.lblLocation.text = order.formattedDate;
    cell.tag = indexPath.row+1000;
    cell.btnOrder.tag = cell.tag;
    cell.lblDetails.text = order.address;
    
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
    PCOrder *order = (PCOrder *)self.profile.orderHistory[indexPath.row];
    [self segueToOrder:order];
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
