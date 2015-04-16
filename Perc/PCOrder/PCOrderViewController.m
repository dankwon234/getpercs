//
//  PCOrderViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/23/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCOrderViewController.h"
#import "PCVenueViewController.h"

@interface PCOrderViewController()
@property (strong, nonatomic) UIImageView *venueIcon;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UIScrollView *theScrollview;
@end

@implementation PCOrderViewController
@synthesize order;


- (void)loadView
{
    UIView *view = [self baseView];
    CGRect frame = view.frame;
    
    UIImage *imgBackground = [UIImage imageNamed:@"bgDinner@2x.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:imgBackground];
    background.frame = CGRectMake(0.0f, 0.0f, imgBackground.size.width, imgBackground.size.height);
    background.center = CGPointMake(0.5f*frame.size.width, 0.5f*frame.size.height);
    background.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [view addSubview:background];

    static CGFloat dimen = 88.0f;
    self.venueIcon = [[UIImageView alloc] initWithImage:self.order.imageData];
    self.venueIcon.frame = CGRectMake(0.0f, 0.0f, dimen, dimen);
    self.venueIcon.center = CGPointMake(0.5f*frame.size.width, 0.5f*dimen+20.0f);
    self.venueIcon.layer.cornerRadius = 0.5f*dimen;
    self.venueIcon.layer.masksToBounds = YES;
    self.venueIcon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.venueIcon.layer.borderWidth = 1.0f;
    [view addSubview:self.venueIcon];


    CGFloat y = self.venueIcon.frame.origin.y+self.venueIcon.frame.size.height+12.0f;
    CGFloat x = 20.0f;
    CGFloat width = frame.size.width-2*x;
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 20.0f)];
    self.lblLocation.textColor = [UIColor whiteColor];
    self.lblLocation.textAlignment = NSTextAlignmentCenter;
    self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.lblLocation.text = [NSString stringWithFormat:@"%@, %@", [self.order.venue.city capitalizedString], [self.order.venue.state uppercaseString]];
    [view addSubview:self.lblLocation];
    y += self.lblLocation.frame.size.height+36.0f;

    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.delegate = self;
    self.theScrollview.showsVerticalScrollIndicator = NO;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];

    CGFloat h = 44.0f;
    UILabel *lblOrder = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblOrder.backgroundColor = [UIColor grayColor];
    lblOrder.textAlignment = NSTextAlignmentCenter;
    lblOrder.textColor = [UIColor whiteColor];
    lblOrder.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblOrder.text = @"ORDER";
    [self.theScrollview addSubview:lblOrder];
    y += lblOrder.frame.size.height;

    CGRect boudingRect = [self.order.order boundingRectWithSize:CGSizeMake(frame.size.width-40.0f, 250.0f)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:16.0f]}
                                                        context:NULL];
    
    CGFloat height = (boudingRect.size.height > h) ? boudingRect.size.height : h;
    
    UIView *orderBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, height+20.0f)];
    orderBackground.backgroundColor = [UIColor whiteColor];
    orderBackground.alpha = 0.8f;
    
    UILabel *lblOrderContent = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, frame.size.width-40.0f, boudingRect.size.height)];
    lblOrderContent.textColor = [UIColor grayColor];
    lblOrderContent.numberOfLines = 0;
    lblOrderContent.lineBreakMode = NSLineBreakByWordWrapping;
    lblOrderContent.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [orderBackground addSubview:lblOrderContent];
    lblOrderContent.text = self.order.order;
    [self.theScrollview addSubview:orderBackground];
    y += orderBackground.frame.size.height;
    
    UILabel *lblDeliveredTo = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblDeliveredTo.backgroundColor = [UIColor grayColor];
    lblDeliveredTo.textAlignment = NSTextAlignmentCenter;
    lblDeliveredTo.textColor = [UIColor whiteColor];
    lblDeliveredTo.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblDeliveredTo.text = @"DELIVERED TO";
    [self.theScrollview addSubview:lblDeliveredTo];
    y += lblDeliveredTo.frame.size.height;

    NSArray *addressParts = [self.order.address componentsSeparatedByString:@", "];
    
    // Using UIButton here instead of UILabel bc UIButton has left edge inset property natively
    UIButton *btnAddress = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddress.frame = CGRectMake(0.0f, y, frame.size.width, h);
    btnAddress.backgroundColor = [UIColor whiteColor];
    btnAddress.alpha = 0.8f;
    [btnAddress setTitle:[addressParts[0] uppercaseString] forState:UIControlStateNormal];
    [btnAddress setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnAddress.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnAddress.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [self.theScrollview addSubview:btnAddress];
    y += btnAddress.frame.size.height+1.0f;

    NSString *townState = [NSString stringWithFormat:@"%@, %@", addressParts[addressParts.count-2], addressParts[addressParts.count-1]];
    UIButton *btnTown = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTown.frame = CGRectMake(0.0f, y, frame.size.width, h);
    btnTown.backgroundColor = [UIColor whiteColor];
    btnTown.alpha = 0.8f;
    [btnTown setTitle:[townState uppercaseString] forState:UIControlStateNormal];
    [btnTown setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnTown.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnTown.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnTown.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [self.theScrollview addSubview:btnTown];
    y += btnAddress.frame.size.height;

    
    UILabel *lblFee = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblFee.backgroundColor = [UIColor grayColor];
    lblFee.textAlignment = NSTextAlignmentCenter;
    lblFee.textColor = [UIColor whiteColor];
    lblFee.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblFee.text = @"PRICE";
    [self.theScrollview addSubview:lblFee];
    y += lblFee.frame.size.height;


    UIButton *btnFoodPrice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFoodPrice.frame = CGRectMake(0.0f, y, frame.size.width, h);
    btnFoodPrice.backgroundColor = [UIColor whiteColor];
    btnFoodPrice.alpha = 0.8f;
    NSString *price = (self.order.price==0.0f) ? @"Order: Pending" : [NSString stringWithFormat:@"Order: %.2f", self.order.price];
    [btnFoodPrice setTitle:price forState:UIControlStateNormal];
    [btnFoodPrice setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnFoodPrice.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnFoodPrice.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnFoodPrice.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [self.theScrollview addSubview:btnFoodPrice];
    y += btnFoodPrice.frame.size.height+1.0f;

    
    UIButton *btnDeliveryFee = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeliveryFee.frame = CGRectMake(0.0f, y, frame.size.width, h);
    btnDeliveryFee.backgroundColor = [UIColor whiteColor];
    btnDeliveryFee.alpha = 0.8f;
    NSString *fee = (self.order.price==0.0f) ? @"Delivery Fee: Pending" : [NSString stringWithFormat:@"Delivery Fee: %.2f", self.order.deliveryFee];
    [btnDeliveryFee setTitle:fee forState:UIControlStateNormal];
    [btnDeliveryFee setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnDeliveryFee.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnDeliveryFee.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnDeliveryFee.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [self.theScrollview addSubview:btnDeliveryFee];
    y += btnDeliveryFee.frame.size.height;

    
    UIView *bgOrder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgOrder.backgroundColor = [UIColor grayColor];
    
    UIButton *btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOrder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnOrder.frame = CGRectMake(x, 0.5f*(bgOrder.frame.size.height-h), width, h);
    btnOrder.backgroundColor = [UIColor clearColor];
    btnOrder.layer.cornerRadius = 0.5f*h;
    btnOrder.layer.masksToBounds = YES;
    btnOrder.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnOrder.layer.borderWidth = 1.0f;
    [btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOrder setTitle:@"ORDER AGAIN" forState:UIControlStateNormal];
    [btnOrder addTarget:self action:@selector(orderAgain:) forControlEvents:UIControlEventTouchUpInside];
    [bgOrder addSubview:btnOrder];
    [self.theScrollview addSubview:bgOrder];
    y += bgOrder.frame.size.height;

    
    
    self.theScrollview.contentSize = CGSizeMake(0, y+44.0f);
    [view addSubview:self.theScrollview];
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(exit:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}

- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        UIScrollView *scrollview = self.theScrollview;
        CGFloat offset = scrollview.contentOffset.y;
        if (offset < 0){
            self.venueIcon.alpha = 1.0f;
            return;
        }
        
        self.venueIcon.alpha = 1.0f-(offset/100.0f);
        self.lblLocation.alpha = self.venueIcon.alpha;
    }
}



- (void)exit:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)orderAgain:(UIButton *)btn
{
    PCVenueViewController *venueVc = [[PCVenueViewController alloc] init];
    venueVc.venue = self.order.venue;
    PCOrder *repeatOrder = [[PCOrder alloc] init];
    repeatOrder.order = self.order.order;
    venueVc.order = repeatOrder;
    [self.navigationController pushViewController:venueVc animated:YES];

    
}

@end
