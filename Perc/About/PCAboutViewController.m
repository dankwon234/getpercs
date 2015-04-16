//
//  PCAboutViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/24/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCAboutViewController.h"

@interface PCAboutViewController ()
@property (strong, nonatomic) UIImageView *bgDinner;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UIPageControl *thePageControl;
@end

@implementation PCAboutViewController

- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
}


- (void)loadView
{
    UIView *view = [self baseView];
    CGRect frame = view.frame;
    
    self.bgDinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgEatingBlue.png"]];
    self.bgDinner.center = CGPointMake(0.5f*frame.size.width, 0.5f*frame.size.height+30.0f);
    [view addSubview:self.bgDinner];
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    self.theScrollview.delegate = self;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.theScrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.theScrollview.backgroundColor = [UIColor clearColor];
    self.theScrollview.pagingEnabled = YES;
    self.theScrollview.showsHorizontalScrollIndicator = NO;
    
    
    NSArray *headers = @[@"Welcome", @"Easy to Order", @"Easy to Pay"];
    NSArray *text = @[@"Perc is the easiest way to have food delivered from your favorite restaurants right to you! Just pick the restaurant, type in your order, then wait for the food to show up.  It's that easy!", @"Perc saves orders so you can re-order at any time. We all have our favorite food we like to order from certain places and with Perc, there's no need to explain it at the drive through over and over. Just punch it up from your order history and order it again!", @"Payment with Perc is also easy as pie (sorry). Just enter your credit card once and use it for ordering as much as you want. Of course, you can still pay the old fashioned way, with cash."];
    
    CGFloat y = 0.45f*frame.size.height;
    CGFloat w = frame.size.width-40.0f;
    UIColor *white = [UIColor whiteColor];
    UIFont *textFont = [UIFont fontWithName:kBaseFontName size:16.0f];
    
    for (int i=0; i<3; i++) {
        UIView *page = [[UIView alloc] initWithFrame:CGRectMake(i*width, 0.0f, width, height)];
        page.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        page.backgroundColor = [UIColor clearColor];
        
        UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, w, 22.0f)];
        lblHeader.textAlignment = NSTextAlignmentCenter;
        lblHeader.textColor = white;
        lblHeader.font = [UIFont boldSystemFontOfSize:18.0f];
        lblHeader.text = headers[i];
        [page addSubview:lblHeader];
        
        NSString *t = text[i];
        CGRect rect = [t boundingRectWithSize:CGSizeMake(w-40.0f, 150.0f)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:textFont}
                                      context:nil];
        
        UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, y+28.0f, w-40.0f, rect.size.height)];
        lblText.textAlignment = NSTextAlignmentCenter;
        lblText.textColor = white;
        lblText.numberOfLines = 0;
        lblText.lineBreakMode = NSLineBreakByWordWrapping;
        lblText.font = textFont;
        lblText.text = t;
        [page addSubview:lblText];
        
        
        [self.theScrollview addSubview:page];
    }
    

    self.theScrollview.contentSize = CGSizeMake(3*width, 0);
    [view addSubview:self.theScrollview];
    
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-white.png"]];
    logo.center = CGPointMake(0.5f*frame.size.width, 0.15f*frame.size.height);
    [view addSubview:logo];

    y = logo.frame.origin.y+logo.frame.size.height+24.0f;
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    icon.frame = CGRectMake(0, y, icon.frame.size.width, icon.frame.size.height);
    icon.center = CGPointMake(0.5f*frame.size.width, icon.center.y);
    icon.layer.borderWidth = 1.0f;
    icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    icon.layer.cornerRadius = 0.5f*icon.frame.size.height;
    icon.layer.masksToBounds = YES;
    [view addSubview:icon];

    self.thePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0.8f*frame.size.height, frame.size.width, 20.0)];
    self.thePageControl.numberOfPages = 3;
    [view addSubview:self.thePageControl];
    
    

    CGFloat h = 44.0f;
    UIButton *btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOrder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnOrder.frame = CGRectMake(20.0f, frame.size.height-h-20.0f, frame.size.width-40.0f, h);
    btnOrder.backgroundColor = [UIColor clearColor];
    btnOrder.layer.cornerRadius = 0.5f*h;
    btnOrder.layer.masksToBounds = YES;
    btnOrder.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnOrder.layer.borderWidth = 1.0f;
    [btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOrder setTitle:@"BACK" forState:UIControlStateNormal];
    [btnOrder addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnOrder];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]==NO)
        return;
    
    
    CGFloat x = self.theScrollview.contentOffset.x;
    if (x <= 0)
        return;
    
    if (x >= 2*self.view.frame.size.width)
        return;
    
//    NSLog(@"%2f", x); // 0, 375, 750
    
    CGFloat center = 0.5f*self.theScrollview.frame.size.width;
    center -= x/3.0f;
    self.bgDinner.center = CGPointMake(center, self.bgDinner.center.y);
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating: ");
    double page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.thePageControl.currentPage = (int)page;
}



@end
