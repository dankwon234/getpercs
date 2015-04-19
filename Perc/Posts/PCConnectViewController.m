//
//  PCConnectViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCConnectViewController.h"
#import "UIImage+PQImageEffects.h"

@interface PCConnectViewController ()
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UIImageView *postIcon;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UITextView *replyForm;
@end

@implementation PCConnectViewController
@synthesize post;


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    CGFloat y = 0.0f;
    CGFloat x = 20.0f;
    
    if (self.post.imageData){
        UIImage *postImage = self.post.imageData;
        
        
        CGFloat width = frame.size.height;
        double scale = width/postImage.size.width;
        CGFloat height = scale*postImage.size.height;
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, y, width, height)];
        self.backgroundImage.image = [postImage applyBlurOnImage:0.50f];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.backgroundImage.bounds;
        bounds.size.height *= 0.6f;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f] CGColor], (id)[[UIColor clearColor] CGColor]];
        [self.backgroundImage.layer insertSublayer:gradient atIndex:0];
        
        [view addSubview:self.backgroundImage];
        
        
        static CGFloat dimen = 88.0f;
        self.postIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
        self.postIcon.image = postImage;
        self.postIcon.center = CGPointMake(0.5f*frame.size.width, 88.0f);
        self.postIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.postIcon.layer.cornerRadius = 0.5f*self.postIcon.frame.size.height;
        self.postIcon.layer.masksToBounds = YES;
        self.postIcon.layer.borderWidth = 1.0f;
        self.postIcon.layer.borderColor = [[UIColor whiteColor] CGColor];
        [view addSubview:self.postIcon];
        
        
        y = self.postIcon.frame.origin.y+self.postIcon.frame.size.height+12.0f;
        width = frame.size.width-2*x;
        UILabel *lblReply = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 20.0f)];
        lblReply.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        lblReply.textColor = [UIColor whiteColor];
        lblReply.textAlignment = NSTextAlignmentCenter;
        lblReply.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        lblReply.text = @"Reply";
        [view addSubview:lblReply];
        y += lblReply.frame.size.height+20.0f;
    }
    

    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.delegate = self;
    self.theScrollview.showsVerticalScrollIndicator = NO;
//    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    
    UIView *replyBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 240.0f)];
    replyBackground.backgroundColor = [UIColor whiteColor];
    replyBackground.alpha = 0.8f;
    
    self.replyForm = [[UITextView alloc] initWithFrame:CGRectMake(x, 10.0f, frame.size.width-2*x, 220.0f)];
//    self.replyForm.delegate = self;
    self.replyForm.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.replyForm.backgroundColor = [UIColor clearColor];
//    self.orderForm.text = (self.order.order.length > 1) ? self.order.order : placeholder;
//    if (self.order.order.length > 4){ // set 4 as minimum bc 'none' is 4 characters
//        self.orderForm.text = self.order.order;
//        self.orderForm.textColor = [UIColor grayColor];
//    }
//    else {
//        self.orderForm.text = placeholder;
//        self.orderForm.textColor = [UIColor lightGrayColor];
//    }
    
    [replyBackground addSubview:self.replyForm];
    [self.theScrollview addSubview:replyBackground];
    y += replyBackground.frame.size.height;

    
    
    [view addSubview:self.theScrollview];
//    self.theScrollview.contentSize = CGSizeMake(0, y);
    self.theScrollview.contentSize = CGSizeMake(0, 800);

    
    
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
