//
//  PCConnectViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCConnectViewController.h"
#import "PCMessage.h"
#import "UIImage+PQImageEffects.h"

@interface PCConnectViewController ()
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UIImageView *postIcon;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UITextView *replyForm;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) PCMessage *message;
@end

static NSString *placeholder = @"Reply";

@implementation PCConnectViewController
@synthesize post;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.message = [[PCMessage alloc] init];
        
    }
    return self;
}



- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
    
}

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
        UIImage *croped = [UIImage crop:postImage rect:CGRectMake(0.0f, 0.0f, 0.75f*postImage.size.width, 0.75f*postImage.size.height)];
        self.backgroundImage.image = [croped applyBlurOnImage:0.80f];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.backgroundImage.bounds;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.70f] CGColor], (id)[[UIColor clearColor] CGColor]];
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
        
        bounds = [self.post.title boundingRectWithSize:CGSizeMake(width, 40.0f)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:14.0f]}
                                               context:nil];
        
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, bounds.size.height)];
        self.lblTitle.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.lblTitle.numberOfLines = 2;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        self.lblTitle.text = self.post.title;
        [view addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height+20.0f;
    }
    

    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, kNavBarHeight, frame.size.width, frame.size.height)];
    self.theScrollview.delegate = self;
    self.theScrollview.showsVerticalScrollIndicator = NO;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    CGFloat h = frame.size.height-y-140.0f;
    UIView *replyBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    replyBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    replyBackground.backgroundColor = [UIColor whiteColor];
    replyBackground.alpha = 0.8f;
    
    x = 12.0f;
    self.replyForm = [[UITextView alloc] initWithFrame:CGRectMake(x, 10.0f, frame.size.width-2*x, h)];
    self.replyForm.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.replyForm.delegate = self;
    self.replyForm.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.replyForm.backgroundColor = [UIColor clearColor];
    self.replyForm.text = placeholder;
    self.replyForm.textColor = [UIColor lightGrayColor];
    [replyBackground addSubview:self.replyForm];
    [self.theScrollview addSubview:replyBackground];
    y += replyBackground.frame.size.height;

    UIView *bgReply = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgReply.backgroundColor = [UIColor grayColor];
    
    h = 44.0f;
    x = 20.0f;
    
    UIButton *btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReply.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnReply.frame = CGRectMake(x, 0.5f*(bgReply.frame.size.height-h), frame.size.width-2*x, h);
    btnReply.backgroundColor = [UIColor clearColor];
    btnReply.layer.cornerRadius = 0.5f*h;
    btnReply.layer.masksToBounds = YES;
    btnReply.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnReply.layer.borderWidth = 1.0f;
    [btnReply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReply setTitle:@"SEND REPLY" forState:UIControlStateNormal];
    [btnReply addTarget:self action:@selector(submitReply:) forControlEvents:UIControlEventTouchUpInside];
    [bgReply addSubview:btnReply];
    [self.theScrollview addSubview:bgReply];
    y += bgReply.frame.size.height+h;

    
    
    [view addSubview:self.theScrollview];
    self.theScrollview.contentSize = CGSizeMake(0, y);

    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:swipeDown];



    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        UIScrollView *scrollview = self.theScrollview;
        CGFloat offset = scrollview.contentOffset.y;
        if (offset < 0){
            self.postIcon.alpha = 1.0f;
            return;
        }
        
        self.postIcon.alpha = 1.0f-(offset/100.0f);
        self.lblTitle.alpha = self.postIcon.alpha;
        
    }
}



- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissKeyboard:(id)sender
{
    if (self.replyForm.isFirstResponder)
        [self.replyForm resignFirstResponder];
    
}




- (void)submitReply:(UIButton *)btn
{
    if (self.replyForm.text.length==0){
        [self showAlertWithTitle:@"Missing Reply" message:@"Please enter a valid reply before submitting your message."];
        return;
    }
    
    // populate message details:
    self.message.content = self.replyForm.text;
    self.message.profile = self.profile;
    self.message.post = self.post.uniqueId;
    self.message.recipient = self.post.profile;
    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] sendMessage:self.message completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            
            [self showAlertWithTitle:@"Message Sent!" message:@"Your message has been sent."];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    [self dismissKeyboard:nil];
}

- (void)resetDelegate
{
    self.theScrollview.delegate = self;
}



#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholder]){
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor];
    }
    
    self.theScrollview.delegate = nil;
//    [self.theScrollview setContentOffset:CGPointMake(0, 80.0f) animated:YES];
    [self.theScrollview setContentOffset:CGPointMake(0, 144.0f) animated:YES];
    [self performSelector:@selector(resetDelegate) withObject:nil afterDelay:0.6f];
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length==0){
        textView.text = placeholder;
        textView.textColor = [UIColor lightGrayColor];
    }
    
    [self.theScrollview setContentOffset:CGPointMake(0, 0.0f) animated:YES];
    return YES;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
