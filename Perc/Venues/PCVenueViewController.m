//
//  PCVenueViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenueViewController.h"
#import "PCPostViewController.h"
#import "UIImage+PQImageEffects.h"

@interface PCVenueViewController ()
@property (strong, nonatomic) UITableView *postsTable;
@property (strong, nonatomic) NSMutableArray *venuePosts;
@end

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


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor blackColor];
    CGRect frame = view.frame;
    
    UIImage *venueImage = self.venue.iconData;
    double scale = frame.size.width/venueImage.size.width;
    CGFloat height = scale*venueImage.size.height;
    UIImageView *blurryBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, height)];
    
    CGFloat width = 0.3f*venueImage.size.width;
    CGFloat h = 0.3f*venueImage.size.height;

    UIImage *blurryImage = [UIImage crop:venueImage rect:CGRectMake(0.5f*(frame.size.width-width), 0.5f*(frame.size.height-h), width, h)];
    blurryBackground.image = [blurryImage applyBlurOnImage:0.90f];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect bounds = blurryBackground.bounds;
    gradient.frame = bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.90f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35f] CGColor]];
    [blurryBackground.layer insertSublayer:gradient atIndex:0];

    
    [view addSubview:blurryBackground];
    
    
    static CGFloat dimen = 120.0f;
    UIImageView *venueIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
    venueIcon.image = venueImage;
    venueIcon.center = CGPointMake(0.25f*frame.size.width, 100.0f);
    venueIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    venueIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
    venueIcon.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    venueIcon.layer.shadowOpacity = 0.5f;
    venueIcon.layer.shadowRadius = 2.0f;
    venueIcon.layer.shadowPath = [UIBezierPath bezierPathWithRect:venueIcon.bounds].CGPath;
    [view addSubview:venueIcon];
    
    
    CGFloat y = venueIcon.frame.origin.y+venueIcon.frame.size.height+64.0f;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 0.5f)];
    double rgb = 0.35f;
    line.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0f];
    [view addSubview:line];
    y += line.frame.size.height;
    
    self.postsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, frame.size.height-y-20.0f) style:UITableViewStylePlain];
    self.postsTable.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    rgb = 0.10f;
    self.postsTable.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0f];
    self.postsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.postsTable.showsVerticalScrollIndicator = NO;
    self.postsTable.dataSource = self;
    self.postsTable.delegate = self;
    [view addSubview:self.postsTable];
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(exit:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
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
            [self.postsTable reloadData];
        });
        
    }];
}


- (void)exit:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNavigationTitleView
{
    // override because we actually don't want it in this view
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venuePosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = tableView.backgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        static double rgb = 0.35f;
        cell.textLabel.textColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0f];
    }
    
    PCPost *post = (PCPost *)self.venuePosts[indexPath.row];
    
    cell.textLabel.text = post.title;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCPostViewController *postVc = [[PCPostViewController alloc] init];
    postVc.post = (PCPost *)self.venuePosts[indexPath.row];
    [self.navigationController pushViewController:postVc animated:YES];
}


@end
