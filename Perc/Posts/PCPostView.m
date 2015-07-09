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
@synthesize lblComments;
@synthesize lblViews;
@synthesize lblDate;



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
        
        CGFloat y = 42.0f;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, y, 0.6f*frame.size.width, 22.0f)];
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.textAlignment = NSTextAlignmentLeft;
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.text = @"Post Title";
        self.lblTitle.font = [UIFont boldSystemFontOfSize:20.0f];
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self addSubview:self.lblTitle];
        
        UIImageView *iconChat = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconChat.png"]];
        iconChat.center = CGPointMake(frame.size.width-34.0f, self.lblTitle.center.y+22.0f);
        [self addSubview:iconChat];
        
        self.lblComments = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-92.0f, iconChat.frame.origin.y-2.0f, 40.0f, 18.0f)];
        self.lblComments.textAlignment = NSTextAlignmentRight;
        self.lblComments.textColor = [UIColor whiteColor];
        self.lblComments.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
        self.lblComments.text = @"5";
        [self addSubview:self.lblComments];
        
        
        UIImageView *iconViews = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconEye.png"]];
        iconViews.center = CGPointMake(frame.size.width-34.0f, self.lblTitle.center.y+iconChat.frame.size.height+26.0f);
        [self addSubview:iconViews];

        self.lblViews = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-92.0f, iconViews.frame.origin.y-2.0f, 40.0f, 18.0f)];
        self.lblViews.textAlignment = NSTextAlignmentRight;
        self.lblViews.textColor = [UIColor whiteColor];
        self.lblViews.font = self.lblComments.font;
        self.lblViews.text = @"20";
        [self addSubview:self.lblViews];
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, y, frame.size.width, 16.0f)];
        self.lblDate.textColor = [UIColor whiteColor];
        self.lblDate.font = [UIFont fontWithName:@"Arial" size:14.0f];
        [self addSubview:self.lblDate];

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
        
        CGFloat y = self.lblTitle.frame.origin.y+frame.size.height+2.0f;
        frame = self.lblDate.frame;
        frame.origin.y = y;
        self.lblDate.frame = frame;
        
        return;
    }
    
}


@end
