//
//  PCVenueViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenueViewController.h"
#import "PCPostViewController.h"
#import "UIImage+PQImageEffects.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCPostCell.h"
#import "PCOrderFoodViewController.h"

@interface PCVenueViewController ()
@property (strong, nonatomic) NSMutableArray *venuePosts;
@property (strong, nonatomic) UICollectionView *postsTable;
@property (strong, nonatomic) NSArray *fadeViews;
@property (strong, nonatomic) UIButton *btnOrder;
@end

static NSString *cellId = @"cellId";

@implementation PCVenueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.venuePosts = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [self.postsTable removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor blackColor];
    CGRect frame = view.frame;
    
    UIImage *venueImage = self.venue.iconData;
    double scale = frame.size.width/venueImage.size.width;
    CGFloat height = scale*venueImage.size.height;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, height)];
    background.image = self.venue.iconData;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect bounds = background.bounds;
    gradient.frame = bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f] CGColor]];
    [background.layer insertSublayer:gradient atIndex:0];
    [view addSubview:background];

    
    
    CGFloat y = background.frame.size.height;
    UIImageView *reflection = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, y, background.frame.size.width, background.frame.size.height)];
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = reflection.bounds;
    gradient2.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.59f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f] CGColor]];
    [reflection.layer insertSublayer:gradient2 atIndex:0];
    
    reflection.image = [self.venue.iconData reflectedImage:[self.venue.iconData applyBlurOnImage:0.15f]
                                                withBounds:reflection.bounds
                                                withHeight:reflection.frame.size.height];
    
    [view addSubview:reflection];
    
    
    
    
    CGFloat dimen = [PCCollectionViewFlowLayout verticalCellWidth];
    y = 36.0f;
    UIImageView *venueIcon = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, y, dimen, dimen)];
    venueIcon.image = venueImage;
    venueIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    venueIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
    venueIcon.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    venueIcon.layer.shadowOpacity = 0.5f;
    venueIcon.layer.shadowRadius = 2.0f;
    venueIcon.layer.shadowPath = [UIBezierPath bezierPathWithRect:venueIcon.bounds].CGPath;
    [view addSubview:venueIcon];
    y += 4.0f;
    
    CGFloat x = venueIcon.frame.origin.x+dimen+14.0f;
    CGFloat width = frame.size.width-x;
    UIFont *bold = [UIFont fontWithName:kBaseBoldFont size:18.0f];
    
    bounds = [self.venue.name boundingRectWithSize:CGSizeMake(width, 100.0f)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:bold}
                                           context:nil];

    
    UILabel *lblVenueName = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, bounds.size.height)];
    lblVenueName.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    lblVenueName.numberOfLines = 0;
    lblVenueName.lineBreakMode = NSLineBreakByWordWrapping;
    lblVenueName.textColor = [UIColor whiteColor];
    lblVenueName.text = self.venue.name;
    lblVenueName.font = bold;
    [view addSubview:lblVenueName];
    y += lblVenueName.frame.size.height+8.0f;
    
    UILabel *lblVenueAddress = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
    lblVenueAddress.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblVenueAddress.textColor = [UIColor whiteColor];
    lblVenueAddress.text = [self.venue.address capitalizedString];
    lblVenueAddress.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    [view addSubview:lblVenueAddress];
    y += lblVenueAddress.frame.size.height;

    
    UILabel *lblVenueTown = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
    lblVenueTown.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblVenueTown.textColor = lblVenueAddress.textColor;
    lblVenueTown.text = [NSString stringWithFormat:@"%@, %@", [self.venue.city capitalizedString], [self.venue.state uppercaseString]];
    lblVenueTown.font = lblVenueAddress.font;
    [view addSubview:lblVenueTown];
    y += lblVenueTown.frame.size.height;

//    UILabel *lblVenuePhone = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
//    lblVenuePhone.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    lblVenuePhone.textColor = lblVenueAddress.textColor;
//    lblVenuePhone.text = @"203-722-7160";
//    lblVenuePhone.font = lblVenueAddress.font;
//    [view addSubview:lblVenuePhone];
//    y += lblVenuePhone.frame.size.height;
    
    
    if ([self.venue.category isEqualToString:@"food"]){
        y = venueIcon.frame.size.height+venueIcon.frame.origin.y-36.0f;
        self.btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOrder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.btnOrder.frame = CGRectMake(x, y, [PCCollectionViewFlowLayout verticalCellWidth], 36.0f);
        self.btnOrder.backgroundColor = [UIColor clearColor];
        self.btnOrder.layer.borderWidth = 2.0f;
        self.btnOrder.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.btnOrder.layer.cornerRadius = 0.5f*self.btnOrder.frame.size.height;
        [self.btnOrder setTitle:@"Order" forState:UIControlStateNormal];
        [self.btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnOrder.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.btnOrder addTarget:self action:@selector(orderFood:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.btnOrder];
        self.fadeViews = @[venueIcon, lblVenueName, lblVenueTown, lblVenueAddress, self.btnOrder];
    }
    else{
        self.fadeViews = @[venueIcon, lblVenueName, lblVenueTown, lblVenueAddress];
    }
    
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(exit:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    [self.loadingIndicator startLoading];
    
    if (self.currentZone.uniqueId==nil)
        return;
    
    
    [[PCWebServices sharedInstance] fetchPosts:@{@"zone":self.currentZone.uniqueId} completion:^(id result, NSError *error){
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        NSArray *posts = results[@"posts"];
        for (int i=0; i<posts.count; i++) {
            PCPost *post = [PCPost postWithInfo:posts[i]];
            [self.venuePosts addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self layoutListsCollectionView];
        });
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.postsTable.contentOffset.y;
        CGFloat topInset = self.postsTable.contentInset.top;
        if (offset < -topInset){
            for (UIView *view in self.fadeViews) {
                view.alpha = 1.0f;
            }
            
            return;
        }
        
        static double max = 120.0f;
        double distance = offset+topInset;
        
        if (distance == max)
            return;
        
        double alpha = 1.0f-(distance/max);
        for (UIView *view in self.fadeViews)
            view.alpha = alpha;
    }
    
    
    if ([keyPath isEqualToString:@"imageData"]){
        PCPost *post = (PCPost *)object;
        [post removeObserver:self forKeyPath:@"imageData"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = (int)[self.venuePosts indexOfObject:post];
            PCPostCell *cell = (PCPostCell *)[self.postsTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = post.imageData;
        });
    }
    
}



- (void)exit:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)layoutListsCollectionView
{
    if (self.postsTable){
        [self.loadingIndicator startLoading];
        [UIView animateWithDuration:0.40f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = self.postsTable.frame;
                             self.postsTable.frame = CGRectMake(frame.origin.x, self.view.frame.size.height, frame.size.width, frame.size.height);
                             
                         }
                         completion:^(BOOL finished){
                             [self.postsTable removeObserver:self forKeyPath:@"contentOffset"];
                             self.postsTable.delegate = nil;
                             self.postsTable.dataSource = nil;
                             [self.postsTable removeFromSuperview];
                             self.postsTable = nil;
                             [self layoutListsCollectionView];
                         }];
        
        return;
    }
    
    CGRect frame = self.view.frame;
    
    CGFloat height = [PCCollectionViewFlowLayout cellHeight]+6.0f;
    
    self.postsTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, height) collectionViewLayout:[[PCCollectionViewFlowLayout alloc] initVerticalFlowLayout]];
    self.postsTable.dataSource = self;
    self.postsTable.delegate = self;
    self.postsTable.backgroundColor = [UIColor clearColor];
    [self.postsTable registerClass:[PCPostCell class] forCellWithReuseIdentifier:cellId];
    self.postsTable.contentInset = UIEdgeInsetsMake([PCCollectionViewFlowLayout verticalCellWidth]+96.0f, 16.0f, 24.0f, 16.0f);
    self.postsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.postsTable.showsHorizontalScrollIndicator = NO;
    [self.postsTable addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [self.view addSubview:self.postsTable];
    [self refreshVenuesCollectionView];
    
    
    [UIView animateWithDuration:1.25f
                          delay:0.75f // delay gives collection view time to 'set up' and therefore not intefere with animation
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.loadingIndicator stopLoading];
                         self.postsTable.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.view bringSubviewToFront:self.btnOrder];
                     }];
}

- (void)refreshVenuesCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.postsTable.collectionViewLayout invalidateLayout];
        [self.postsTable reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.currentZone.venues.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.postsTable reloadItemsAtIndexPaths:indexPaths];
    });
}


- (void)orderFood:(UIButton *)btn
{
    NSLog(@"orderFood: ");
    PCOrderFoodViewController *orderFoodVc = [[PCOrderFoodViewController alloc] init];
    orderFoodVc.venue = self.venue;
    [self.navigationController pushViewController:orderFoodVc animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.venuePosts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCPostCell *cell = (PCPostCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    PCPost *post = (PCPost *)self.venuePosts[indexPath.row];
    cell.lblTitle.text = post.title;
    cell.lblDate.text = post.formattedDate;
    cell.lblNumComments.text = [NSString stringWithFormat:@"%d", post.numComments];
    cell.lblNumViews.text = [NSString stringWithFormat:@"%d", post.numViews];
    cell.tag = indexPath.row+1000;
    
    
    if ([post.image isEqualToString:@"none"]){
        cell.icon.image = [UIImage imageNamed:@"logo.png"];
        return cell;
    }

    if (post.imageData){
        cell.icon.image = post.imageData;
        return cell;
    }

    cell.icon.image = [UIImage imageNamed:@"icon.png"];
    [post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [post fetchImage];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([PCCollectionViewFlowLayout verticalCellWidth], [PCCollectionViewFlowLayout cellHeight]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCPostViewController *postVc = [[PCPostViewController alloc] init];
    postVc.post = self.venuePosts[indexPath.row];
    [self.navigationController pushViewController:postVc animated:YES];
}



#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
    NSArray *subviews = self.view.subviews;
    if ([subviews indexOfObject:scrollView]==subviews.count-1)
        return;
    
    [self.view bringSubviewToFront:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.view bringSubviewToFront:self.btnOrder];

    
}





@end
