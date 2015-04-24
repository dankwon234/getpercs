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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 0.5f*frame.size.height;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.masksToBounds = YES;
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 22.0f)];
        self.lblTitle.center = CGPointMake(lblTitle.center.x, 0.5f*frame.size.height);
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:16.0f];
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
