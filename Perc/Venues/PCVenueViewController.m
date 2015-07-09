//
//  PCVenueViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenueViewController.h"
#import "PCPostViewController.h"
#import "UIImage+PQImageEffects.h"

@interface PCVenueViewController ()
@property (strong, nonatomic) NSMutableArray *venuePosts;
@end

@implementation PCVenueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.venuePosts = [NSMutableArray array];

    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor blackColor];
    CGRect frame = view.frame;
    
    UIImage *venueImage = self.venue.iconData;
    double scale = frame.size.width/venueImage.size.width;
    CGFloat height = scale*venueImage.size.height;
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, height)];
    background.image = self.venue.iconData;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect bounds = background.bounds;
    gradient.frame = bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f] CGColor]];
    [background.layer insertSublayer:gradient atIndex:0];
    [view addSubview:background];

    
    
    CGFloat y = background.frame.size.height;
    UIImageView *reflection = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, y, background.frame.size.width, background.frame.size.height)];
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = reflection.bounds;
    gradient2.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.59f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f] CGColor]];
    [reflection.layer insertSublayer:gradient2 atIndex:0];
    
    reflection.image = [self.venue.iconData reflectedImage:[self.venue.iconData applyBlurOnImage:0.15f]
                                                withBounds:reflection.bounds
                                                withHeight:reflection.frame.size.height];
    
    [view addSubview:reflection];
    
    
    
    
    static CGFloat dimen = 140.0f;
    y = 36.0f;
    UIImageView *venueIcon = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, y, dimen, dimen)];
    venueIcon.image = venueImage;
    venueIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    venueIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
    venueIcon.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    venueIcon.layer.shadowOpacity = 0.5f;
    venueIcon.layer.shadowRadius = 2.0f;
    venueIcon.layer.shadowPath = [UIBezierPath bezierPathWithRect:venueIcon.bounds].CGPath;
    [view addSubview:venueIcon];
    y += 4.0f;
    
    CGFloat x = venueIcon.frame.origin.x+dimen+12.0f;
    CGFloat width = frame.size.width-x;
    UIFont *bold = [UIFont boldSystemFontOfSize:18.0f];
    
    bounds = [self.venue.name boundingRectWithSize:CGSizeMake(width, 100.0f)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:bold}
                                           context:nil];

    
    UILabel *lblVenueName = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, bounds.size.height)];
    lblVenueName.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    lblVenueName.numberOfLines = 0;
    lblVenueName.lineBreakMode = NSLineBreakByWordWrapping;
    lblVenueName.textColor = [UIColor whiteColor];
    lblVenueName.text = self.venue.name;
    lblVenueName.font = bold;
    [view addSubview:lblVenueName];
    y += lblVenueName.frame.size.height+8.0f;
    
    UILabel *lblVenueAddress = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
    lblVenueAddress.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblVenueAddress.textColor = [UIColor whiteColor];
    lblVenueAddress.text = [self.venue.address capitalizedString];
    lblVenueAddress.font = [UIFont systemFontOfSize:14.0f];
    [view addSubview:lblVenueAddress];
    y += lblVenueAddress.frame.size.height;

    
    UILabel *lblVenueTown = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
    lblVenueTown.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblVenueTown.textColor = lblVenueAddress.textColor;
    lblVenueTown.text = [NSString stringWithFormat:@"%@, %@", [self.venue.city capitalizedString], [self.venue.state uppercaseString]];
    lblVenueTown.font = lblVenueAddress.font;
    [view addSubview:lblVenueTown];
    y += lblVenueTown.frame.size.height;

//    UILabel *lblVenuePhone = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
//    lblVenuePhone.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    lblVenuePhone.textColor = lblVenueAddress.textColor;
//    lblVenuePhone.text = @"203-722-7160";
//    lblVenuePhone.font = lblVenueAddress.font;
//    [view addSubview:lblVenuePhone];
//    y += lblVenuePhone.frame.size.height;
    
    
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(exit:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    [[PCWebServices sharedInstance] fetchPosts:@{@"zone":self.currentZone.uniqueId} completion:^(id result, NSError *error){
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        NSArray *posts = results[@"posts"];
        for (int i=0; i<posts.count; i++) {
            PCPost *post = [PCPost postWithInfo:posts[i]];
            [self.venuePosts addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    }];
}


- (void)exit:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNavigationTitleView
{
    // override because we actually don't want it in this view
}






@end
