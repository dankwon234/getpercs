//
//  PCVenueCell.m
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCVenueCell.h"
#import "Config.h"


@implementation PCVenueCell
@synthesize icon;
@synthesize base;
@synthesize lblTitle;
@synthesize lblLocation;
@synthesize lblDetails;


#define kAnimationDuration 0.24f


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 2.0f;
        self.contentView.layer.masksToBounds = YES;
        
        self.base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.base.layer.cornerRadius = 2.0f;
        self.base.backgroundColor = kLightGray;
        self.base.alpha = 0.95f;
        self.base.layer.masksToBounds = YES;
        
        CGFloat dimen = frame.size.width;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
        self.icon.image = [UIImage imageNamed:@"icon.png"];
        self.icon.backgroundColor = [UIColor whiteColor];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.icon.bounds;
        bounds.size.height *= 0.5f;
        bounds.origin.y += 0.5f*self.icon.bounds.size.height;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f] CGColor]];
        [self.icon.layer insertSublayer:gradient atIndex:0];
        
        [self.base addSubview:self.icon];
        
        UIColor *darkGray = [UIColor darkGrayColor];
        UIColor *clear = [UIColor clearColor];
        
        CGFloat y = dimen-20.0f;
        CGFloat x = 4.0f;
        CGFloat width = frame.size.width-2*x;
        
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 18.0f)];
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.numberOfLines = 1;
        self.lblTitle.backgroundColor = clear;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.base addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height+4.0f;
        
        self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 14.0f)];
        self.lblLocation.textColor = darkGray;
        self.lblLocation.backgroundColor = clear;
        self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        [self.base addSubview:self.lblLocation];
        y += self.lblLocation.frame.size.height;

        
        
        self.lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 14.0f)];
        self.lblDetails.textColor = kOrange;
        self.lblDetails.backgroundColor = clear;
        self.lblDetails.font = [UIFont fontWithName:kBaseFontName size:10.0f];
        [self.base addSubview:self.lblDetails];
        y += self.lblDetails.frame.size.height+16.0f;
        

        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 28.0f)];
        static CGFloat rgb = 230.0f;
        bottom.backgroundColor = [UIColor colorWithRed:rgb/255.0f green:rgb/255.0f blue:rgb/255.0f alpha:1.0f];
        [self.base addSubview:bottom];
        
        
        [self.contentView addSubview:self.base];
        
        
        
    }
    return self;
}






@end
