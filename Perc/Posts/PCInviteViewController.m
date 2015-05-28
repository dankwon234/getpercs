//
//  PCInviteViewController.m
//  Perc
//
//  Created by Dan Kwon on 5/28/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCInviteViewController.h"

@interface PCInviteViewController ()
@property (strong, nonatomic) UITableView *contactsTable;
@end

@implementation PCInviteViewController
@synthesize post;


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor greenColor];
    CGRect frame = view.frame;
    
    self.contactsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f) style:UITableViewStylePlain];
    self.contactsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.contactsTable.showsVerticalScrollIndicator = NO;
    self.contactsTable.dataSource = self;
    self.contactsTable.delegate = self;
    self.contactsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 96.0f)];
    [view addSubview:self.contactsTable];
    
    
    
    CGFloat y = frame.size.height-116.f;
    CGFloat h = 44.0f;
    CGFloat x = 16.0f;
    CGFloat width = frame.size.width-2*x;

    UIView *bgCreate = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgCreate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bgCreate.backgroundColor = [UIColor grayColor];
    
    UIButton *btnCreate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCreate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnCreate.frame = CGRectMake(x, 0.5f*(bgCreate.frame.size.height-h), width, h);
    btnCreate.backgroundColor = [UIColor clearColor];
    btnCreate.layer.cornerRadius = 0.5f*h;
    btnCreate.layer.masksToBounds = YES;
    btnCreate.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnCreate.layer.borderWidth = 1.0f;
    [btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    NSString *btnTitle = (self.isEditMode) ? @"UPDATE POST" : @"CREATE POST";
    [btnCreate setTitle:@"CREATE POST" forState:UIControlStateNormal];
//    [btnCreate addTarget:self action:@selector(createPost:) forControlEvents:UIControlEventTouchUpInside];
    [bgCreate addSubview:btnCreate];
    [view addSubview:bgCreate];
    
    
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

- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    return cell;
}


@end
