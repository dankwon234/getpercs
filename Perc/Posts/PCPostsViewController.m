//
//  PCPostsViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostsViewController.h"
#import "PCCreatePostViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCPostCell.h"


@interface PCPostsViewController ()
@property (strong, nonatomic) UICollectionView *postsTable;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f

@implementation PCPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self addNavigationTitleView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postAdded:)
                                                     name:kPostCreatedNotification
                                                   object:nil];
        
    }
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBurger.png"]];
//    CGRect frame = view.frame;
    


    
    
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
}


- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
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
//                             [self.postsTable removeObserver:self forKeyPath:@"contentOffset"];
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
//    [self.postsTable addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    [self.view addSubview:self.postsTable];
    
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
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
