//
//  PCPostViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostViewController.h"

@interface PCPostViewController ()
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UILabel *lblTitle;
@end

@implementation PCPostViewController
@synthesize post;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        
        
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
    
    if (self.post.imageData){
        CGFloat width = frame.size.width;
        double scale = width/self.post.imageData.size.width;
        CGFloat height = scale*self.post.imageData.size.height;
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
        self.backgroundImage.image = self.post.imageData;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.backgroundImage.bounds;
        bounds.size.height *= 0.6f;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f] CGColor], (id)[[UIColor clearColor] CGColor]];
        [self.backgroundImage.layer insertSublayer:gradient atIndex:0];

        [view addSubview:self.backgroundImage];
    }
    
    UIFont *boldFont = [UIFont fontWithName:kBaseFontName size:22.0f];
    CGFloat w = frame.size.width-40.0f;
    CGRect boundingRect = [self.post.title boundingRectWithSize:CGSizeMake(w, 60)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:boldFont}
                                                        context:nil];
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, w, boundingRect.size.height)];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.numberOfLines = 2;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.font = boldFont;
    self.lblTitle.text = self.post.title;
    [view addSubview:self.lblTitle];
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f)];
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.theScrollview.contentSize = CGSizeMake(0, 1000);
    [view addSubview:self.theScrollview];
    
    
    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 1000.0f)];
    base.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgPost.png"]];
    [self.theScrollview addSubview:base];
    
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
        if (error){
            
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]==NO)
        return;
    
    
    
    
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
