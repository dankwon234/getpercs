//
//  PCMessagesViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/22/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessagesViewController.h"
#import "PCMessage.h"
#import "PCMessageCell.h"
#import "PCMessageViewController.h"


@interface PCMessagesViewController ()
@property (strong, nonatomic) UITableView *messagesTable;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation PCMessagesViewController

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
    
    self.messagesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.messagesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
    self.messagesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self
                            action:@selector(fetchProfileMessages)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.messagesTable addSubview:self.refreshControl];

    [view addSubview:self.messagesTable];

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
    
    if (self.profile.messages)
        return;
    
    [self fetchProfileMessages:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.messagesTable deselectRowAtIndexPath:[self.messagesTable indexPathForSelectedRow] animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        PCProfile *profile = (PCProfile *)object;
        
        [profile removeObserver:self forKeyPath:@"imageData"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagesTable reloadData];
        });
        return;
    }
}


- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetchProfileMessages
{
    [self fetchProfileMessages:NO];
}

- (void)fetchProfileMessages:(BOOL)showLoading
{
    if (showLoading)
        [self.loadingIndicator startLoading];
    
    self.profile.messages = [NSMutableArray array];
    [[PCWebServices sharedInstance] fetchMessages:@{@"profile":self.profile.uniqueId} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        [self.refreshControl endRefreshing];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        NSArray *m = results[@"messages"];
        for (int i=0; i<m.count; i++){
            PCMessage *msg = [PCMessage messageWithInfo:m[i]];
            msg.isMine = [msg.profile.uniqueId isEqual:self.profile.uniqueId];
            [self.profile.messages addObject:msg];
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagesTable reloadData];
            
            if (self.profile.messages.count==0)
                [self showAlertWithTitle:@"No Messages" message:@"You have no direct messages yet."];

        });
        
    }];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profile.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PCMessageCell *cell = (PCMessageCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil)
        cell = [[PCMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    
    PCMessage *message = (PCMessage *)self.profile.messages[indexPath.row];
    cell.lblDate.text = message.formattedDate;
    cell.lblMessage.text = message.content;
    
    if (message.isMine){
        cell.configuration = MessageCellConfigurationTo;
        cell.lblName.text = [NSString stringWithFormat:@"%@ %@", [message.recipient.firstName capitalizedString], [message.recipient.lastName capitalizedString]];
    }
    else {
        cell.configuration = MessageCellConfigurationFrom;
        cell.lblName.text = [NSString stringWithFormat:@"%@ %@", [message.profile.firstName capitalizedString], [message.profile.lastName capitalizedString]];
        
    }
    
    if ([message.profile.image isEqualToString:@"none"])
        return cell;
    
    if (message.profile.imageData){
        cell.icon.image = message.profile.imageData;
        return cell;
    }
    
    [message.profile addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [message.profile fetchImage];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCMessageViewController *messageVc = [[PCMessageViewController alloc] init];
    messageVc.message = self.profile.messages[indexPath.row];
    [self.navigationController pushViewController:messageVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PCMessageCell standardCellHeight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
