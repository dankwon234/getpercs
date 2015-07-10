//
//  PCPostCell.m
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostCell.h"
#import "Config.h"

@interface PCPostCell()

@end

@implementation PCPostCell
@synthesize icon;
@synthesize base;
@synthesize lblTitle;
@synthesize lblDate;
@synthesize lblNumViews;
@synthesize lblNumComments;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.base.layer.cornerRadius = 1.0f;
        double rgb = 0.20f;
        self.base.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0f];
        self.base.alpha = 0.95f;
        self.base.layer.masksToBounds = YES;
        
        CGFloat padding = 12.0f;
        CGFloat dimen = frame.size.width-24.0f;
        CGFloat y = padding;
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(padding, y, dimen, dimen)];
        self.icon.image = [UIImage imageNamed:@"icon.png"];
        self.icon.backgroundColor = [UIColor whiteColor];
        
        self.icon.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.icon.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.icon.layer.shadowOpacity = 0.5f;
        self.icon.layer.shadowRadius = 2.0f;
        self.icon.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.icon.bounds].CGPath;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.icon.bounds;
        bounds.size.height *= 0.5f;
        bounds.origin.y = bounds.size.height;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85f] CGColor]];
        [self.icon.layer insertSublayer:gradient atIndex:0];

        [self.base addSubview:self.icon];
        y += self.icon.frame.size.height+4.0f;
        
        CGFloat width = frame.size.width-padding-2*padding;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding+2.0f, y, width, 14.0f)];
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblTitle.textColor = [UIColor whiteColor];
        self.lblTitle.numberOfLines = 2;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.font = [UIFont boldSystemFontOfSize:12.0f];
        [self.base addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height+2.0f;

        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(padding+2.0f, y, width, 12.0f)];
        self.lblDate.textColor = self.lblTitle.textColor;
        self.lblDate.font = [UIFont systemFontOfSize:12.0f];
        [self.base addSubview:self.lblDate];
        y += self.lblDate.frame.size.height;
        
        UIImage *chatBubble = [UIImage imageNamed:@"iconChat.png"];
        y = frame.size.height-chatBubble.size.height-6.0f;
        CGFloat x = frame.size.width-chatBubble.size.width-padding;
        
        UIImageView *iconComment = [[UIImageView alloc] initWithImage:chatBubble];
        iconComment.frame = CGRectMake(x, y, chatBubble.size.width, chatBubble.size.height);
        [self.base addSubview:iconComment];
        x -= 24.0f;

        self.lblNumComments = [[UILabel alloc] initWithFrame:CGRectMake(x, y-2.0f, 20.0f, 18.0f)];
        self.lblNumComments.textAlignment = NSTextAlignmentRight;
        self.lblNumComments.textColor = [UIColor whiteColor];
        self.lblNumComments.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
        [self.base addSubview:self.lblNumComments];
        x -= self.lblNumComments.frame.size.width+12.0f;
        
        UIImage *iconEye = [UIImage imageNamed:@"iconEye.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:iconEye];
        iconView.frame = CGRectMake(x, y, iconEye.size.width, iconEye.size.height);
        [self.base addSubview:iconView];
        x -= iconView.frame.size.width+6.0f;
        
        
        self.lblNumViews = [[UILabel alloc] initWithFrame:CGRectMake(x, y-2.0f, 24.0f, 18.0f)];
        self.lblNumViews.textAlignment = NSTextAlignmentRight;
        self.lblNumViews.textColor = [UIColor whiteColor];
        self.lblNumViews.font = self.lblNumComments.font;

        
        [self.base addSubview:self.lblNumViews];


        
        
        [self.contentView addSubview:self.base];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.lblTitle removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    
    CGRect frame = self.lblTitle.frame;
    CGRect boudingRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake(self.lblTitle.frame.size.width, 44.0f)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                          context:NULL];
    frame.size.height = boudingRect.size.height;
    frame.origin.y = self.icon.frame.origin.y+self.icon.frame.size.height-boudingRect.size.height-2.0f;
    self.lblTitle.frame = frame;
    CGFloat y = self.lblTitle.frame.origin.y+self.lblTitle.frame.size.height+6.0f;
    
    frame = self.lblDate.frame;
    frame.origin.y = y;
    self.lblDate.frame = frame;
    
}


+ (CGFloat)cellWidth
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return (frame.size.width > 320.0f) ? 320.0f : 280.0f;
}

+ (CGFloat)cellHeight
{
    static CGFloat h = 140.0f;
    return h;
}




@end
