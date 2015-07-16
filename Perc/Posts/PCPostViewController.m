//
//  PCPostViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostViewController.h"
#import "PCConnectViewController.h"
#import "PCComment.h"

@interface PCPostViewController ()
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UITableView *theTableview;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblContent;
@property (strong, nonatomic) UITextField *commentField;
@property (strong, nonatomic) PCComment *nextComment;
@property (strong, nonatomic) UIImageView *fullImage;
@property (strong, nonatomic) UIScrollView *fullImageView;
@property (strong, nonatomic) UIView *optionsView;
@property (strong, nonatomic) UIButton *btnAccept;
@property (strong, nonatomic) UIButton *btnDecline;
@property (strong, nonatomic) UIWebView *venmoWebview;
@end

@implementation PCPostViewController
@synthesize post;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.nextComment = [[PCComment alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardAppearNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        
    }
    return self;
}

- (void)dealloc
{
    [self.theTableview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)loadView
{
    BOOL isEvent = [self.post.type isEqualToString:@"event"];
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBlurry.png"]];
    CGRect frame = view.frame;
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.width;
    if (self.post.imageData){
        double scale = width/self.post.imageData.size.width;
        height = scale*self.post.imageData.size.height;
    }
    
    self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    self.backgroundImage.image = self.post.imageData;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect bounds = self.backgroundImage.bounds;
    bounds.size.height *= 0.6f;
    gradient.frame = bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f] CGColor], (id)[[UIColor clearColor] CGColor]];
    [self.backgroundImage.layer insertSublayer:gradient atIndex:0];
    [view addSubview:self.backgroundImage];

    self.theTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theTableview.dataSource = self;
    self.theTableview.delegate = self;
    self.theTableview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.theTableview.backgroundColor = [UIColor clearColor];
    self.theTableview.showsVerticalScrollIndicator = NO;
    self.theTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.theTableview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    width = frame.size.width-40.0f;
    UIFont *baseFont = [UIFont fontWithName:kBaseFontName size:16.0f];
    CGRect contentRect = [self.post.content boundingRectWithSize:CGSizeMake(width, 800.0f)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:baseFont}
                                                         context:nil];
    
    CGFloat h = (contentRect.size.height < 98.0f) ? 508.0f : contentRect.size.height+382.0f;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 175.0f, frame.size.width, h)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgPost.png"]];
    
    
    CGFloat y = 175.0f;
    self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width-20.0f, 22.0f)];
    self.lblDate.textColor = kOrange;
    self.lblDate.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.lblDate.textAlignment = NSTextAlignmentRight;
    self.lblDate.text = self.post.formattedDate;
    [header addSubview:self.lblDate];
    
    
    UIFont *boldFont = [UIFont fontWithName:kBaseFontName size:22.0f];
    CGFloat w = frame.size.width-40.0f;
    CGRect titleRect = [self.post.title boundingRectWithSize:CGSizeMake(w, 160)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:boldFont}
                                                     context:nil];
    
    y = 220.0f;
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, w, titleRect.size.height)];
    self.lblTitle.textColor = [UIColor darkGrayColor];
    self.lblTitle.numberOfLines = 2;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblTitle.font = boldFont;
    self.lblTitle.text = self.post.title;
    [header addSubview:self.lblTitle];
    y += self.lblTitle.frame.size.height;
    
    if (isEvent){
        y += 2.0f;
        UILabel *lblFee = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, w, 16.0f)];
        lblFee.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        lblFee.text = (self.post.adjustedFee==0.0f) ? @"Free" : [NSString stringWithFormat:@"$%.2f", self.post.adjustedFee];
        lblFee.textColor = [UIColor lightGrayColor];
        [header addSubview:lblFee];
        y += lblFee.frame.size.height+24.0f;
    }
    else{
        y += 24.0f;
    }

    
    self.lblContent = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, width, contentRect.size.height)];
    self.lblContent.numberOfLines = 0;
    self.lblContent.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblContent.font = baseFont;
    self.lblContent.textColor = [UIColor darkGrayColor];
    self.lblContent.text = self.post.content;
    [header addSubview:self.lblContent];
    
    if (isEvent){
        BOOL isAttending = NO;
        for (NSDictionary *attendee in self.post.confirmed) {
            if ([attendee[@"phoneNumber"] isEqualToString:self.profile.phone]){
                isAttending = YES;
                break;
            }
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20.0f, h-64.0f, frame.size.width-40.0f, 44.0f);
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.cornerRadius = 0.5f*btn.frame.size.height;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 2.0f;
        btn.titleLabel.font = boldFont;
        
        if (isAttending){
            btn.layer.borderColor = [kGreen CGColor];
            [btn setTitleColor:kGreen forState:UIControlStateNormal];
            [btn setTitle:@"Attending" forState:UIControlStateNormal];
            UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconCheckmark.png"]];
            checkmark.center = CGPointMake(60.0f, 0.5f*btn.frame.size.height);
            [btn addSubview:checkmark];
        }
        else {
            btn.layer.borderColor = [[UIColor grayColor] CGColor];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn setTitle:@"RSVP" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(rsvpEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [header addSubview:btn];

    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, h-0.5f, frame.size.width, 0.5f)];
    line.backgroundColor = [UIColor lightGrayColor];
    [header addSubview:line];
    
    self.theTableview.tableHeaderView = header;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 44.0f)];
    footer.backgroundColor = [UIColor lightGrayColor];
    
    self.commentField = [[UITextField alloc] initWithFrame:CGRectMake(6.0f, 6.0f, frame.size.width-100.0f, footer.frame.size.height-12.0f)];
    self.commentField.delegate = self;
    self.commentField.backgroundColor = [UIColor whiteColor];
    self.commentField.alpha = 0.85f;
    self.commentField.layer.cornerRadius = 2.0f;
    self.commentField.layer.masksToBounds = YES;
    self.commentField.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.commentField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 6.0f, self.commentField.frame.size.height)];
    self.commentField.leftViewMode = UITextFieldViewModeAlways;
    self.commentField.textColor = [UIColor darkGrayColor];
    [footer addSubview:self.commentField];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSend.frame = CGRectMake(frame.size.width-106.0f, footer.frame.size.height-28.0f, 100.0f, 22.0f);
    [btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    btnSend.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    btnSend.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnSend addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:btnSend];
    self.theTableview.tableFooterView = footer;
    
    self.theTableview.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 20.0f, 0.0f);
    
    [view addSubview:self.theTableview];

    
    
    self.fullImageView = [[UIScrollView alloc] initWithFrame:view.frame];
    self.fullImageView.delegate = self;
    self.fullImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.fullImageView.backgroundColor = [UIColor blackColor];
    self.fullImageView.minimumZoomScale = 1.0f;
    self.fullImageView.maximumZoomScale = 3.0f;
    self.fullImageView.alpha = 0.0f;
    
    self.fullImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.width)];
    self.fullImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.fullImage.center = self.fullImageView.center;
    [self.fullImageView addSubview:self.fullImage];
    [view addSubview:self.fullImageView];

    
    self.optionsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.optionsView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.optionsView.backgroundColor = [UIColor blackColor];
    self.optionsView.alpha = 0.0f;
    
    y = 0.40f*frame.size.height;
    CGFloat x = 24.0f;
    h = 44.0f;

    self.btnAccept = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDecline = [UIButton buttonWithType:UIButtonTypeCustom];

    NSArray *buttons = @[self.btnAccept, self.btnDecline];
    NSArray *icons = @[@"iconInfo.png", @"iconLocation.png"];
    NSArray *titles = @[@"Accept", @"Decline"];
    for (int i=0; i<buttons.count; i++){
        UIButton *button = buttons[i];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        button.frame = CGRectMake(x, y, frame.size.width-2*x, h);
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:kBaseFontName size:18.0f];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.layer.cornerRadius = 3.0f;
        button.layer.masksToBounds = YES;
        [button setImage:[UIImage imageNamed:icons[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.optionsView addSubview:button];
        y += button.frame.size.height+12.0f;
    }


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
    
    [[PCWebServices sharedInstance] updatePost:self.post incrementView:YES completion:^(id result, NSError *error){
        if (error)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            [self.post populate:results[@"post"]];
            [self fetchComments];
        });
    }];
    
    if (self.post.imageData)
        return;
    
    [self.post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [self.post fetchImage];

}



- (void)fetchComments
{
    if (self.post.comments)
        return;
    
    
    [[PCWebServices sharedInstance] fetchComments:@{@"thread":self.post.uniqueId} completion:^(id result, NSError *error){
        if (error)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSArray *c = results[@"comments"];
            self.post.comments = [NSMutableArray array];
            for (NSDictionary *commentInfo in c)
                [self.post.comments addObject:[PCComment commentWithInfo:commentInfo]];
            
            [self.theTableview reloadData];
        });
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        [object removeObserver:self forKeyPath:@"imageData"];
        self.backgroundImage.image = self.post.imageData;
    }
    

    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.theTableview.contentOffset.y;
        CGRect frame = self.backgroundImage.frame;
        if (offset > 220.0f){
            if (frame.origin.y > 0.0f)
                frame.origin.y = 0.0f;
            return;
        }
        
        if (offset > 0){ // moving up - shift image up. 0 to 220.
            frame.origin.y = -0.4f*offset;
            if (frame.origin.y > 0.0f)
                frame.origin.y = 0.0f;
            
            self.backgroundImage.frame = frame;
            return;
        }
        
        
        double magnitude = -0.01f*offset+1.0f;
        self.backgroundImage.transform = CGAffineTransformMakeScale(magnitude, magnitude);
    }
    
}


- (void)back:(UIGestureRecognizer *)swipe
{
    if (self.fullImageView.alpha == 0){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 0.0f;
                         self.fullImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];

}

- (void)keyboardAppearNotification:(NSNotification *)note
{
    if (self.venmoWebview)
        return;
    
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self shiftUp:keyboardFrame.size.height];
}

- (void)keyboardHideNotification:(NSNotification *)note
{
    if (self.venmoWebview)
        return;
    

//    NSLog(@"keyboardHideNotification: %@", [note.userInfo description]);
    [self shiftBack:0.0f];
}

- (void)submitComment:(UIButton *)btn
{
    if (self.commentField.text.length==0){
        [self showAlertWithTitle:@"Missing Comment" message:@"Please enter a comment first."];
        return;
    }
    
    self.nextComment.text = self.commentField.text;
    self.nextComment.profile = self.profile.uniqueId;
    self.nextComment.thread = self.post.uniqueId;
    [self.commentField resignFirstResponder];
    
    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] submitComment:self.nextComment completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        self.nextComment = [[PCComment alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.commentField.text = @"";
            
            if (self.post.comments==nil)
                self.post.comments = [NSMutableArray array];
            
            [self.post.comments addObject:[PCComment commentWithInfo:results[@"comment"]]];
            [self.theTableview reloadData];
        });
        
    }];
    
}

- (void)viewFullImage
{
    self.fullImage.image = self.post.imageData;
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 1.0f;
                         self.fullImageView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)rsvpEvent:(UIButton *)btn
{
    NSLog(@"rsvpEvent: ");
    [self showOptionsView:btn];
}

- (void)toggleOptionsView:(id)sender
{
    if (self.optionsView.alpha == 0.0f){
        [self showOptionsView:nil];
        return;
    }
    
    [self hideOptionsView:nil];
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


- (void)showOptionsView:(UIButton *)btn
{
    [self.view bringSubviewToFront:self.optionsView];
    [UIView animateWithDuration:0.35f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.optionsView.alpha = 0.85f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)updatePostWithReply:(BOOL)acceptDecline
{
    [[PCWebServices sharedInstance] replyInvitation:self.post profile:self.profile reply:acceptDecline completion:^(id result, NSError *error){
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        [self.post populate:results[@"post"]];

        if (acceptDecline)
            [self showAlertWithTitle:@"Thanks!" message:@"You have confirmed your invitation."];

        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)buttonAction:(UIButton *)btn
{
    if ([btn isEqual:self.btnAccept]){
        
        if (self.post.adjustedFee==0){
            [self.post.confirmed addObject:[self.profile contactInfoDict]];
            [self updatePostWithReply:YES];
            return;
        }
        
        NSString *msg = [NSString stringWithFormat:@"This event costs $%.2f to attend. Do you want to continue?", post.adjustedFee];
        UIAlertView *alert = [self showAlertWithTitle:@"Fee" message:msg buttons:@"NO"];
        alert.delegate = self;
        alert.tag = 1000;
        return;
    }
    
    if ([btn isEqual:self.btnDecline]){
        [self hideOptionsView:nil];
        
        NSString *phone = self.profile.phone;
        NSDictionary *invitee = nil;
        for (NSDictionary *invited in self.post.invited) {
            if ([invited[@"phoneNumber"] isEqualToString:phone]){
                invitee = invited;
                break;
            }
        }
        
        if (invitee==nil){
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        [self.post.invited removeObject:invitee];
        [self.profile.invited removeObject:self.post];
        
        [self.loadingIndicator startLoading];
        [self updatePostWithReply:NO];
    }
}


- (void)sendVenmoPayment:(NSString *)accessToken toRecipient:(NSString *)rec
{
    [[PCWebServices sharedInstance] submitVenmoPayment:accessToken
                                                amount:4.0f
                                             recipient:@"bkarpinos@gmail.com"
                                                  note:[NSString stringWithFormat:@"PAYMENT: %@", self.post.title]
                                            completion:^(id result, NSError *error){
                                                if (error) {
                                                    NSLog(@"ERROR: %@", [error localizedDescription]);
                                                    [self showAlertWithTitle:@"Error" message:@"Payment could not be completed."];
                                                    [self hideOptionsView:nil];
                                                    return;
                                                }
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    NSLog(@"%@", [result description]);
                                                    [self.post.confirmed addObject:[self.profile contactInfoDict]];
                                                    [self updatePostWithReply:YES];
                                                });
                                            }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1000){
        if (buttonIndex != 0){ // decline
            [self hideOptionsView:nil];
            return;
        }
        
        // show venmo login:
        // https://api.venmo.com/v1/oauth/authorize?client_id=2765&scope=make_payments%20access_profile
        
        NSString *authUrl = @"https://api.venmo.com/v1/oauth/authorize?client_id=2765&scope=make_payments%20access_profile";
        CGRect frame = self.view.frame;
        self.venmoWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height)];
        self.venmoWebview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.venmoWebview.delegate = self;
        [self.venmoWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authUrl]]];
        [self.view addSubview:self.venmoWebview];
        
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.venmoWebview.frame = CGRectMake(0.0f, 0.0f, self.venmoWebview.frame.size.width, self.venmoWebview.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        return;
    }
    
    [self showLoginView:YES]; // not logged in - go to log in / register view controller
}





#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.commentField.isFirstResponder)
        [self.commentField resignFirstResponder];
    
    if ([scrollView isEqual:self.fullImageView]) // ingore this guy
        return;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -80.0f)
        [self viewFullImage];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.fullImageView]==NO)
        return nil;
    
    return self.fullImage;
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return 3;
    
    return self.post.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        static NSString *cellId = @"cellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = kLightGray;
        }
        
        // Reply Cell
        if (indexPath.row==0){
            cell.textLabel.textColor = kOrange;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"iconEnvelope.png"];
            cell.textLabel.text = @"DIRECT MESSAGE";
            return cell;

        }
        
        cell.textLabel.textColor = kLightBlue;
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row==1){ // views cell:
            cell.imageView.image = [UIImage imageNamed:@"iconView.png"];
            cell.textLabel.text = [NSString stringWithFormat:@"%d Views", self.post.numViews];
            return cell;
        }
        
        // comments cell:
        cell.imageView.image = [UIImage imageNamed:@"iconComment.png"];
        cell.textLabel.text = [NSString stringWithFormat:@"%d Comments", self.post.numComments];
        return cell;
    }
    
    static NSString *commentCellId = @"commentCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:commentCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
        cell.detailTextLabel.textColor = kLightBlue;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:line];
    }
    
    PCComment *comment = (PCComment *)self.post.comments[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n", comment.text];
    cell.detailTextLabel.text = comment.formattedDate;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
        return;
    
    if (indexPath.row != 0)
        return;
    
    if (self.profile.isPopulated==NO){
        UIAlertView *alert = [self showAlertWithTitle:@"Log In" message:@"Please log in or register to send a direct message."];
        alert.delegate = self;
        return;
    }
    
    PCConnectViewController *connectVc = [[PCConnectViewController alloc] init];
    connectVc.post = self.post;
    [self.navigationController pushViewController:connectVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
        return 44.0f;
    
    PCComment *comment = (PCComment *)self.post.comments[indexPath.row];
    CGRect bounds = [comment.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 300.0f)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:14.0f]}
                                               context:nil];

    return bounds.size.height+54.0f;
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    NSLog(@"webView shouldStartLoadWithRequest: %@", urlString);
    
    if ([urlString hasPrefix:@"http://www.getpercs.com"]){
        NSArray *parts = [urlString componentsSeparatedByString:@"="];
        NSString *accessToken = [parts lastObject];
        
        [UIView animateWithDuration:0.35f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = webView.frame;
                             frame.origin.y = self.view.frame.size.height;
                             webView.frame = frame;
                         }
                         completion:^(BOOL finished){
                             self.venmoWebview.delegate = nil;
                             [self.venmoWebview removeFromSuperview];
                             self.venmoWebview = nil;
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self sendVenmoPayment:accessToken toRecipient:@"bkarpinos@gmail.com"];
                             });
                         }];
        
        return NO;
    }
    
    return YES;
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
