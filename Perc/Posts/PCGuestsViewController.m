//
//  PCGuestsViewController.m
//  Perc
//
//  Created by Dan Kwon on 7/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCGuestsViewController.h"
#import "PCContactCell.h"

@interface PCGuestsViewController ()
@property (strong, nonatomic) UITableView *guestsTable;
@end

@implementation PCGuestsViewController
@synthesize post;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    CGRect frame = view.frame;
    
    self.guestsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.guestsTable.dataSource = self;
    self.guestsTable.delegate = self;
    self.guestsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.guestsTable.showsVerticalScrollIndicator = NO;
    self.guestsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.guestsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 96.0f)];
    [view addSubview:self.guestsTable];
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, kNavBarHeight)];
    topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundBlue.png"]];
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
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.post.confirmed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PCContactCell *cell = (PCContactCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[PCContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.imgCheckmark.image = nil;
    }
    
    NSDictionary *contactInfo = self.post.confirmed[indexPath.row];
    cell.lblName.text = contactInfo[@"fullName"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PCContactCell standardCellHeight];
    
}






@end
