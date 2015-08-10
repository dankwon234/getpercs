//
//  PCSectionView.m
//  Perc
//
//  Created by Dan Kwon on 8/9/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCSectionView.h"
#import "Config.h"

@implementation PCSectionView
@synthesize postImage;
@synthesize lblTitle;
@synthesize banner;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat x = 0.0f;
        self.postImage = [[UIImageView alloc] initWithFrame:CGRectMake(x, x, frame.size.width-2*x, frame.size.width-2*x)];
        self.postImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.postImage.userInteractionEnabled = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.postImage.bounds;
        bounds.size.height *= 0.6f;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.95f] CGColor], (id)[[UIColor clearColor] CGColor]];
        [self.postImage.layer insertSublayer:gradient atIndex:0];
        self.postImage.alpha = 0;
        [self.postImage addObserver:self forKeyPath:@"image" options:0 context:0];
        [self addSubview:self.postImage];
        
        CGFloat y = frame.size.height-64.0f;
        self.banner = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, 0.8f*frame.size.width, 36.0f)];
        self.banner.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.banner.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.banner.layer.shadowOpacity = 0.5f;
        self.banner.layer.shadowRadius = 2.0f;
        self.banner.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.banner.bounds].CGPath;
        [self addSubview:self.banner];
        y += 6.0f;
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, y, 0.6f*frame.size.width, 22.0f)];
        self.lblTitle.numberOfLines = 1;
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        self.lblTitle.shadowColor = [UIColor darkGrayColor];
        self.lblTitle.shadowOffset = CGSizeMake(1, 1);
        [self addSubview:self.lblTitle];
        
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.postImage removeObserver:self forKeyPath:@"image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]){
        
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.postImage.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
    }
    
    
}


@end
