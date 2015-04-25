//
//  PCPostsViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostsViewController.h"
#import "PCCreatePostViewController.h"
#import "PCPostViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCMessagesViewController.h"
#import "PCMessagesViewController.h"
#import "PCPostCell.h"


@interface PCPostsViewController ()
@property (strong, nonatomic) UICollectionView *postsTable;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UIButton *btnNearby;
@property (strong, nonatomic) UIButton *btnYourPosts;
@property (strong, nonatomic) UIButton *btnMessages;
@property (strong, nonatomic) UIButton *btnDots;
@property (strong, nonatomic) UIView *optionsView;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f

@implementation PCPostsViewController
@synthesize mode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.mode = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postAdded:)
                                                     name:kPostCreatedNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postUpdated:)
                                                     name:kPostUpdatedNotification
                                                   object:nil];


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
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBurger.png"]];
    CGRect frame = view.frame;
    
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
    self.lblTitle.text = @"Nearby";
    [view addSubview:self.lblTitle];
    y += self.lblTitle.frame.size.height+6.0f;
    
    self.btnDots = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *dots = [UIImage imageNamed:@"dots.png"];
    self.btnDots.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnDots.frame = CGRectMake(x, y, dots.size.width, dots.size.height);
    self.btnDots.center = CGPointMake(0.5f*frame.size.width, self.btnDots.center.y);
    [self.btnDots setImage:dots forState:UIControlStateNormal];
    self.btnDots.backgroundColor = [UIColor clearColor];
    [self.btnDots addTarget:self action:@selector(showOptionsView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnDots];

    
    self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 120.0f, frame.size.width-40.0f, 22.0f)];
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
    self.btnNearby = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnNearby.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnNearby.frame = CGRectMake(x, y, frame.size.width-2*x, h);
    self.btnNearby.backgroundColor = [UIColor clearColor];
    self.btnNearby.layer.cornerRadius = 0.5f*h;
    self.btnNearby.layer.masksToBounds = YES;
    self.btnNearby.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnNearby.layer.borderWidth = 1.0f;
    self.btnNearby.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.btnNearby setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnNearby setTitle:@"Nearby" forState:UIControlStateNormal];
    [self.btnNearby addTarget:self action:@selector(viewNearbyPosts:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsView addSubview:self.btnNearby];
    y += self.btnNearby.frame.size.height+20.0f;

    self.btnYourPosts = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnYourPosts.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnYourPosts.frame = CGRectMake(x, y, frame.size.width-2*x, h);
    self.btnYourPosts.backgroundColor = [UIColor clearColor];
    self.btnYourPosts.layer.cornerRadius = 0.5f*h;
    self.btnYourPosts.layer.masksToBounds = YES;
    self.btnYourPosts.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnYourPosts.layer.borderWidth = 1.0f;
    self.btnYourPosts.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.btnYourPosts setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnYourPosts setTitle:@"Your Posts" forState:UIControlStateNormal];
    [self.btnYourPosts addTarget:self action:@selector(viewProfilePosts:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsView addSubview:self.btnYourPosts];
    y += self.btnYourPosts.frame.size.height+20.0f;
    
    
    self.btnMessages = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnMessages.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnMessages.frame = CGRectMake(x, y, frame.size.width-2*x, h);
    self.btnMessages.backgroundColor = [UIColor clearColor];
    self.btnMessages.layer.cornerRadius = 0.5f*h;
    self.btnMessages.layer.masksToBounds = YES;
    self.btnMessages.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnMessages.layer.borderWidth = 1.0f;
    self.btnMessages.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.btnMessages setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnMessages setTitle:@"Direct Messages" forState:UIControlStateNormal];
    [self.btnMessages addTarget:self action:@selector(viewMessages:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsView addSubview:self.btnMessages];
    y += self.btnMessages.frame.size.height+20.0f;
    
    
    
    [self.optionsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOptionsView:)]];
    [view addSubview:self.optionsView];

    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(createPost:)];
    
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

    if (self.currentZone.posts){
        [self layoutListsCollectionView];
        return;
    }
    
    [self.loadingIndicator startLoading];
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
            
            [self layoutListsCollectionView];
        });
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        PCPost *post = (PCPost *)object;
        [post removeObserver:self forKeyPath:@"imageData"];
        
        //this is smoother than a conventional reload. it doesn't stutter the UI:
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *dataArray = (self.mode==0) ? self.currentZone.posts : self.profile.posts;
            int index = (int)[dataArray indexOfObject:post];
            PCPostCell *cell = (PCPostCell *)[self.postsTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = post.imageData;
        });
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.postsTable.contentOffset.y;
        if (offset < -kTopInset){
            self.icon.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        self.icon.alpha = 1.0f-(distance/100.0f);
        self.btnDots.alpha = self.icon.alpha;
        self.lblTitle.alpha = self.icon.alpha;
        
    }
    
}


- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)viewNearbyPosts:(UIButton *)btn
{
    [self hideOptionsView:nil];
    if (self.mode==0)
        return;
    
    self.lblTitle.text = @"Nearby";
    self.mode = 0;
    [self layoutListsCollectionView];
}

- (void)viewProfilePosts:(UIButton *)btn
{
    [self hideOptionsView:nil];
    if (self.mode==1)
        return;
    
    self.mode = 1;
    self.lblTitle.text = @"Your Posts";
    if (self.profile.posts){
        [self layoutListsCollectionView];
        return;
    }
    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] fetchPosts:@{@"":self.profile.uniqueId} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profile.posts = [NSMutableArray array];
            NSDictionary *results = (NSDictionary *)result;
            NSArray *a = results[@"posts"];
            for (int i=0; i<a.count; i++)
                [self.profile.posts addObject:[PCPost postWithInfo:a[i]]];
            
            [self layoutListsCollectionView];
        });
        
    }];
    
}




- (void)showOptionsView:(UIButton *)btn
{
    [UIView animateWithDuration:0.35f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.optionsView.alpha = 0.85f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


- (void)viewMessages:(UIButton *)btn
{
    PCMessagesViewController *messagesVc = [[PCMessagesViewController alloc] init];
    [self.navigationController pushViewController:messagesVc animated:YES];
}

- (void)createPost:(id)sender
{
    NSLog(@"createPost: ");
    PCCreatePostViewController *createPostVc = [[PCCreatePostViewController alloc] init];
    [self.navigationController pushViewController:createPostVc animated:YES];
}


- (void)layoutListsCollectionView
{
    if (self.postsTable){
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
    
    self.postsTable = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height-20.0f) collectionViewLayout:[[PCCollectionViewFlowLayout alloc] init]];
    self.postsTable.backgroundColor = [UIColor clearColor];
    
    [self.postsTable registerClass:[PCPostCell class] forCellWithReuseIdentifier:cellId];
    self.postsTable.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, 24.0f, 0);
    self.postsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.postsTable.dataSource = self;
    self.postsTable.delegate = self;
    self.postsTable.showsVerticalScrollIndicator = NO;
    [self.postsTable addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [self.view addSubview:self.postsTable];
    [self.view bringSubviewToFront:self.btnDots];
    [self.view bringSubviewToFront:self.optionsView];
    
    [self refreshVenuesCollectionView];
    
    
    [UIView animateWithDuration:1.20f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.postsTable.frame;
                         self.postsTable.frame = CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)refreshVenuesCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.postsTable.collectionViewLayout invalidateLayout];
        [self.postsTable reloadData];
        
        NSArray *dataArray = (self.mode==0) ? self.currentZone.posts : self.profile.posts;
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<dataArray.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.postsTable reloadItemsAtIndexPaths:indexPaths];
    });
}

- (void)postAdded:(NSNotification *)notfication
{
    NSDictionary *userInfo = notfication.userInfo;
    PCPost *p = userInfo[@"post"];
    if (p==nil)
        return;
    
    self.mode = 0;
    [self.currentZone.posts insertObject:p atIndex:0];
    [self layoutListsCollectionView];
}

- (void)postUpdated:(NSNotification *)note
{
    [self layoutListsCollectionView];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    NSLog(@"collectionView numberOfItemsInSection: %d", self.posts.count);
    return (self.mode==0) ? self.currentZone.posts.count : self.profile.posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCPostCell *cell = (PCPostCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
//    PCPost *post = (PCPost *)self.currentZone.posts[indexPath.row];
    PCPost *post = (self.mode==0) ? (PCPost *)self.currentZone.posts[indexPath.row] : (PCPost *)self.profile.posts[indexPath.row];
    cell.tag = indexPath.row+1000;
    cell.lblTitle.text = post.title;
    cell.lblNumViews.text = [NSString stringWithFormat:@"%d Views", post.numViews];
    cell.lblNumComments.text = [NSString stringWithFormat:@"%d Comments", post.numComments];
    
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
    return CGSizeMake([PCPostCell cellWidth], [PCPostCell cellHeight]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCPost *post = (self.mode==0) ? (PCPost *)self.currentZone.posts[indexPath.row] : (PCPost *)self.profile.posts[indexPath.row];
    NSLog(@"View Post: %@", post.title);
    
    if (self.mode==0){
        PCPostViewController *postVc = [[PCPostViewController alloc] init];
        postVc.post = post;
        [self.navigationController pushViewController:postVc animated:YES];
        return;
    }
    
    PCCreatePostViewController *editPostVc = [[PCCreatePostViewController alloc] init];
    editPostVc.post = post;
    [self.navigationController pushViewController:editPostVc animated:YES];
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
