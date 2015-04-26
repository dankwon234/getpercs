//
//  PCMessageViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/25/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessageViewController.h"

@interface PCMessageViewController ()
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblMessage;
@end

@implementation PCMessageViewController
@synthesize message;


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = kLightGray;
    CGRect frame = view.frame;
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    
    
    CGFloat h = 44.0f;
    CGFloat y = 0.0;
    
    UILabel *lblSource = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblSource.backgroundColor = [UIColor whiteColor];
    lblSource.text = [NSString stringWithFormat:@"  FROM: %@ %@", [self.message.profile.firstName capitalizedString], [self.message.profile.lastName capitalizedString]];
    lblSource.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.theScrollview addSubview:lblSource];
    y += h+1.0f;

    
    UILabel *lblRecipient = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblRecipient.backgroundColor = [UIColor whiteColor];
    lblRecipient.text = [NSString stringWithFormat:@"  TO: %@ %@", [self.message.recipient.firstName capitalizedString], [self.message.recipient.lastName capitalizedString]];
    lblRecipient.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.theScrollview addSubview:lblRecipient];
    y += h+12.0f;
    
    CGFloat x = 20.0f;
    self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, y, frame.size.width, 18.0f)];
    self.lblDate.textColor = kOrange;
    self.lblDate.font = [UIFont boldSystemFontOfSize:12.0f];
    self.lblDate.text = self.message.formattedDate;
    [self.theScrollview addSubview:self.lblDate];
    y += self.lblDate.frame.size.height+12.0f;
    
    CGFloat width = frame.size.width-2*x;
    UIFont *font = [UIFont fontWithName:kBaseFontName size:16.0f];
    CGRect bounds = [self.message.content boundingRectWithSize:CGSizeMake(width, 1000.0f)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : font}
                                                       context:nil];
    
    self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, bounds.size.height)];
    self.lblMessage.numberOfLines = 0;
    self.lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblMessage.font = font;
    self.lblMessage.textColor = kLightBlue;
    self.lblMessage.text = self.message.content;
    [self.theScrollview addSubview:self.lblMessage];
    y += self.lblMessage.frame.size.height+44.0f;

    
    self.theScrollview.contentSize = CGSizeMake(0, y);
    [view addSubview:self.theScrollview];
    
    
    UIView *bgReply = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-84.0f, frame.size.width, 64.0f)];
    bgReply.backgroundColor = [UIColor grayColor];
    bgReply.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReply.frame = CGRectMake(12.0f, 12.0f, frame.size.width-24.0f, h);
    btnReply.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnReply.layer.borderWidth = 1.0f;
    btnReply.layer.cornerRadius = 0.5f*h;
    btnReply.layer.masksToBounds = YES;
    [btnReply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReply setTitle:@"Reply" forState:UIControlStateNormal];
    btnReply.titleLabel.font = [UIFont fontWithName:kBaseFontName size:18.0f];
    [btnReply addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
    [bgReply addSubview:btnReply];
    
    [view addSubview:bgReply];
    
    
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

- (void)reply
{
//    NSLog(@"reply");
    if ([MFMailComposeViewController canSendMail]==NO){
        [self showAlertWithTitle:@"Cannot Send Mail" message:@"This device cannot send mail."];
        return;
    }

    NSArray *recipient = (self.message.isMine) ? @[self.message.recipient.email] : @[self.message.profile.email];
    
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    mailVC.delegate = self;
    mailVC.mailComposeDelegate = self;
    [mailVC setToRecipients:recipient];
    
    [self presentViewController:mailVC animated:YES completion:^{
        
        
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
