//
//  PCGuestsViewController.m
//  Perc
//
//  Created by Dan Kwon on 7/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

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
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    
    self.guestsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.guestsTable.dataSource = self;
    self.guestsTable.delegate = self;
    self.guestsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.guestsTable.showsVerticalScrollIndicator = NO;
    self.guestsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.guestsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 96.0f)];
    self.guestsTable.contentInset = UIEdgeInsetsMake(180.0f, 0, 0, 0);
    self.guestsTable.backgroundColor = [UIColor clearColor];
    [view addSubview:self.guestsTable];
    
    
    
//    CGFloat y = frame.size.height-96.f;
//    CGFloat h = 44.0f;
//    CGFloat x = 16.0f;
//    CGFloat width = frame.size.width-2*x;
//    
//    UIView *bgCreate = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
//    bgCreate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    bgCreate.backgroundColor = [UIColor grayColor];
//    
//    UIButton *btnCreate = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnCreate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    btnCreate.frame = CGRectMake(x, 0.5f*(bgCreate.frame.size.height-h), width, h);
//    btnCreate.backgroundColor = [UIColor clearColor];
//    btnCreate.layer.cornerRadius = 0.5f*h;
//    btnCreate.layer.masksToBounds = YES;
//    btnCreate.layer.borderColor = [[UIColor whiteColor] CGColor];
//    btnCreate.layer.borderWidth = 1.0f;
//    [btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    //    NSString *btnTitle = (self.isEditMode) ? @"UPDATE POST" : @"CREATE POST";
//    [btnCreate setTitle:@"CREATE POST" forState:UIControlStateNormal];
//    [btnCreate addTarget:self action:@selector(createPost:) forControlEvents:UIControlEventTouchUpInside];
//    [bgCreate addSubview:btnCreate];
//    [view addSubview:bgCreate];
    
    
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
    }
    
    NSDictionary *contactInfo = self.post.confirmed[indexPath.row];
    cell.lblName.text = contactInfo[@"fullName"];
    cell.imgCheckmark.image = nil;
    return cell;
}






@end
