//
//  PCPostView.m
//  Perc
//
//  Created by Dan Kwon on 7/3/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCPostView.h"
#import "UIImage+PQImageEffects.h"


@implementation PCPostView
@synthesize postImage;
@synthesize lblTitle;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat x = 74.0f;
        self.postImage = [[UIImageView alloc] initWithFrame:CGRectMake(x, x, frame.size.width-2*x, frame.size.width-2*x)];
        self.postImage.userInteractionEnabled = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.postImage.bounds;
        bounds.size.height *= 0.5f;
        bounds.origin.y = bounds.size.height;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f] CGColor]];
        
        [self.postImage.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.postImage];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.85f*frame.size.height, frame.size.width, 16.0f)];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.text = @"Post Title";
        [self addSubview:self.lblTitle];
        

    }
    
    return self;
}



@end
