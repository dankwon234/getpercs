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
        
        CGFloat x = 0.0f;
        self.postImage = [[UIImageView alloc] initWithFrame:CGRectMake(x, x, frame.size.width-2*x, frame.size.width-2*x)];
        self.postImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.postImage.userInteractionEnabled = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.postImage.bounds;
        bounds.size.height *= 0.6f;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80f] CGColor], (id)[[UIColor clearColor] CGColor]];
        [self.postImage.layer insertSublayer:gradient atIndex:0];
        self.postImage.alpha = 0;
        [self.postImage addObserver:self forKeyPath:@"image" options:0 context:0];
        [self addSubview:self.postImage];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 42.0f, 0.6f*frame.size.width, 22.0f)];
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.text = @"Post Title";
        self.lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self addSubview:self.lblTitle];
    }
    
    return self;
}

- (void)dealloc
{
    [self.postImage removeObserver:self forKeyPath:@"image"];
    [self.lblTitle removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]){
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.postImage.alpha = 1.0f;
                         }];

    }
    
    if ([keyPath isEqualToString:@"text"]){
        CGRect frame = self.lblTitle.frame;
        CGRect bounds = [self.lblTitle.text boundingRectWithSize:CGSizeMake(frame.size.width, 250.0f)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                         context:nil];
        
        frame.size.height = bounds.size.height;
        self.lblTitle.frame = frame;
        return;
    }
    
}


@end
