//
//  PCMessagesViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/22/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessagesViewController.h"
#import "PCMessage.h"
#import "PCMessageCell.h"


@interface PCMessagesViewController ()
@property (strong, nonatomic) UITableView *messagesTable;
@end

@implementation PCMessagesViewController


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = kLightGray;
    CGRect frame = view.frame;
    
    self.messagesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f) style:UITableViewStylePlain];
    self.messagesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.messagesTable.dataSource = self;
    self.messagesTable.delegate = self;
    self.messagesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [view addSubview:self.messagesTable];

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
    
    self.profile.messages = [NSMutableArray array];
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] fetchMessages:@{@"profile":self.profile.uniqueId} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            NSArray *m = results[@"messages"];
            for (int i=0; i<m.count; i++){
                PCMessage *msg = [PCMessage messageWithInfo:m[i]];
                msg.isMine = [msg.profile.uniqueId isEqual:self.profile.uniqueId];
                [self.profile.messages addObject:msg];
            }
            
            [self.messagesTable reloadData];
        });
        
    }];
}


- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
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
    cell.configuration = (message.isMine) ? MessageCellConfigurationTo : MessageCellConfigurationFrom;
    cell.lblName.text = [NSString stringWithFormat:@"%@ %@", [message.profile.firstName capitalizedString], [message.profile.lastName capitalizedString]];
    cell.lblDate.text = message.formattedDate;
    cell.lblMessage.text = message.content;
    
    
    return cell;
    
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
