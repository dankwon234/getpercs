//
//  PCPostsViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostsViewController.h"
#import "PCCreatePostViewController.h"
#import "PCPostViewController.h"
#import "PCPostCell.h"
#import "PCPostTableCell.h"


@interface PCPostsViewController ()
@property (strong, nonatomic) UITableView *postsTable;
@end

static NSString *cellId = @"cellId";
#define kTopInset 220.0f

@implementation PCPostsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
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



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    

    self.postsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.postsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.postsTable.dataSource = self;
    self.postsTable.delegate = self;
    self.postsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [view addSubview:self.postsTable];

    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, kNavBarHeight)];
    topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [view addSubview:topBar];
    
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropShadow.png"]];
    dropShadow.frame = CGRectMake(0.0f, kNavBarHeight, dropShadow.frame.size.width, dropShadow.frame.size.height);
    [view addSubview:dropShadow];

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    

    self.view = view;
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

    
    if (self.profile.posts!=nil)
        return;
    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] fetchPosts:@{@"profile":self.profile.uniqueId} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profile.posts = [NSMutableArray array];
            NSArray *a = results[@"posts"];
            for (NSDictionary *postInfo in a)
                [self.profile.posts addObject:[PCPost postWithInfo:postInfo]];
            
            [self.postsTable reloadData];
            
//            if (self.profile.posts.count==0)
//                [self showAlertWithTitle:@"No Posts" message:@"This area has no posts. To add one, tap the icon in the upper right corner."];
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
//            NSArray *dataArray = (self.mode==0) ? self.currentZone.posts : self.profile.posts;
            int index = (int)[self.profile.posts indexOfObject:post];
            PCPostTableCell *cell = (PCPostTableCell *)[self.postsTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.postIcon.image = post.imageData;
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
    if (self.profile.isPopulated==NO){
        UIAlertView *alert = [self showAlertWithTitle:@"Log In" message:@"Please log in or register to create a post."];
        alert.delegate = self;
        return;
    }
    
    PCCreatePostViewController *createPostVc = [[PCCreatePostViewController alloc] init];
    [self.navigationController pushViewController:createPostVc animated:YES];
}

- (void)postAdded:(NSNotification *)notfication
{
    NSDictionary *userInfo = notfication.userInfo;
    PCPost *p = userInfo[@"post"];
    if (p==nil)
        return;

    if (self.profile.posts == nil)
        self.profile.posts = [NSMutableArray array];

    [self.profile.posts insertObject:p atIndex:0];
    [self.postsTable reloadData];
}

- (void)postUpdated:(NSNotification *)note
{
//    [self layoutListsCollectionView];
    [self.postsTable reloadData];

}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex == %ld", (long)buttonIndex);
    [self showLoginView:YES]; // not logged in - go to log in / register view controller
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PCPostTableCell *cell = (PCPostTableCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[PCPostTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    PCPost *post = (PCPost *)self.profile.posts[indexPath.row];
    cell.tag = indexPath.row+1000;
    cell.lblTitle.text = post.title;
    cell.lblDate.text = post.formattedDate;
    
    if (post.imageData){
        cell.postIcon.image = post.imageData;
        return cell;
    }

    cell.postIcon.image = [UIImage imageNamed:@"icon.png"];
    if ([post.image isEqualToString:@"none"])
        return cell;
    
    
    [post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [post fetchImage];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCreatePostViewController *editPostVc = [[PCCreatePostViewController alloc] init];
    editPostVc.post = (PCPost *)self.profile.posts[indexPath.row];
    [self.navigationController pushViewController:editPostVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PCPostTableCell standardCellHeight];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
