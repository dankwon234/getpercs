//
//  PCBackgroundView.m
//  Perc
//
//  Created by Dan Kwon on 4/21/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCBackgroundView.h"
#import "Config.h"

@implementation PCBackgroundView
@synthesize lblTitle;
@synthesize imageView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        
        self.imageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.imageView.backgroundColor = [UIColor redColor];
        [self addSubview:self.imageView];
        
        UIView *screen = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        screen.backgroundColor = [UIColor whiteColor];
        screen.alpha = 0.65f;
        [self addSubview:screen];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 22.0f)];
        self.lblTitle.center = CGPointMake(lblTitle.center.x, 0.5f*frame.size.height);
        self.lblTitle.textColor = [UIColor darkGrayColor];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:20.0f];
        [self addSubview:self.lblTitle];

    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
