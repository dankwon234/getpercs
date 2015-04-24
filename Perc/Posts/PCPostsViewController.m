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
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UIButton *btnPosts;
@property (strong, nonatomic) UIButton *btnMessages;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f

@implementation PCPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postAdded:)
                                                     name:kPostCreatedNotification
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
    CGFloat w = 0.5F*(frame.size.width-3*x);
    
    self.btnPosts = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPosts.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnPosts.frame = CGRectMake(x, y, w, h);
    self.btnPosts.backgroundColor = [UIColor clearColor];
    self.btnPosts.layer.cornerRadius = 0.5f*h;
    self.btnPosts.layer.masksToBounds = YES;
    self.btnPosts.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnPosts.layer.borderWidth = 1.0f;
    self.btnPosts.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.btnPosts setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnPosts setTitle:@"Your Posts" forState:UIControlStateNormal];
//    [self.btnPosts addTarget:self action:@selector(viewOrderHistory:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnPosts];
    x += w+20.0f;
    
    self.btnMessages = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnMessages.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnMessages.frame = CGRectMake(x, y, w, h);
    self.btnMessages.backgroundColor = [UIColor clearColor];
    self.btnMessages.layer.cornerRadius = 0.5f*h;
    self.btnMessages.layer.masksToBounds = YES;
    self.btnMessages.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnMessages.layer.borderWidth = 1.0f;
    self.btnMessages.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.btnMessages setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnMessages setTitle:@"Messages" forState:UIControlStateNormal];
    [self.btnMessages addTarget:self action:@selector(viewMessages:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnMessages];
    y += self.btnMessages.frame.size.height+20.0f;


    self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 120.0f, frame.size.width-40.0f, 22.0f)];
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
            int index = (int)[self.currentZone.posts indexOfObject:post];
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
        self.btnMessages.alpha = self.icon.alpha;
        self.btnPosts.alpha = self.icon.alpha;
    }
    
}


- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.view bringSubviewToFront:self.btnMessages];
    [self.view bringSubviewToFront:self.btnPosts];
    
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
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.currentZone.posts.count; i++)
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
    
    [self.currentZone.posts insertObject:p atIndex:0];
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
    return self.currentZone.posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCPostCell *cell = (PCPostCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    PCPost *post = (PCPost *)self.currentZone.posts[indexPath.row];
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
    PCPost *post = (PCPost *)self.currentZone.posts[indexPath.row];
    NSLog(@"View Post: %@", post.title);
    
    PCPostViewController *postVc = [[PCPostViewController alloc] init];
    postVc.post = post;
    [self.navigationController pushViewController:postVc animated:YES];

    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
