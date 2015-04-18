//
//  PCPostCell.m
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostCell.h"
#import "Config.h"

@interface PCPostCell()
@property (strong, nonatomic) UIView *line;
@property (strong, nonatomic) UIView *bottomView;
@end

@implementation PCPostCell
@synthesize icon;
@synthesize base;
@synthesize lblTitle;
@synthesize lblNumViews;
@synthesize lblNumComments;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 2.0f;
        self.contentView.layer.masksToBounds = YES;
        
        self.base = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.base.layer.cornerRadius = 2.0f;
        self.base.backgroundColor = [UIColor whiteColor];
        self.base.alpha = 0.95f;
        self.base.layer.masksToBounds = YES;
        
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 110.0f, frame.size.width, frame.size.height-110.0f)];
        self.bottomView.backgroundColor = kLightGray;
        [self.base addSubview:self.bottomView];

        
        CGFloat dimen = frame.size.height;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(-20.0f, 0.0f, dimen, dimen)];
        self.icon.image = [UIImage imageNamed:@"icon.png"];
        self.icon.backgroundColor = [UIColor whiteColor];
        [self.base addSubview:self.icon];
        
        UIColor *darkGray = [UIColor darkGrayColor];
        UIColor *clear = [UIColor clearColor];
        
        CGFloat y = 8.0f;
        CGFloat x = self.icon.frame.origin.x+dimen+12.0f;
        CGFloat width = frame.size.width-x-12.0f;
        
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 18.0f)];
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblTitle.textColor = darkGray;
        self.lblTitle.numberOfLines = 2;
        self.lblTitle.backgroundColor = clear;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.font = [UIFont boldSystemFontOfSize:18.0f];
        [self.base addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, 0.5f)];
        self.line.backgroundColor = [UIColor lightGrayColor];
        [self.base addSubview:self.line];
        y += self.line.frame.size.height+2.0f;
        
        UIColor *gray = [UIColor grayColor];
        self.lblNumComments = [[UILabel alloc] initWithFrame:CGRectMake(x, 8.0f, 68.0f, 18.0f)];
        self.lblNumComments.textAlignment = NSTextAlignmentRight;
        self.lblNumComments.text = @"8 Comments";
        self.lblNumComments.textColor = gray;
        self.lblNumComments.font = [UIFont systemFontOfSize:8.0f];
        UIImageView *iconComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconComment.png"]];
        [self.lblNumComments addSubview:iconComment];
        [self.bottomView addSubview:self.lblNumComments];

        self.lblNumViews = [[UILabel alloc] initWithFrame:CGRectMake(self.bottomView.frame.size.width-65.0f, 8.0f, 50.0f, 18.0f)];
        self.lblNumViews.text = @"8 Views";
        self.lblNumViews.textAlignment = NSTextAlignmentRight;
        self.lblNumViews.textColor = gray;
        self.lblNumViews.font = self.lblNumComments.font;
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconView.png"]];
        [self.lblNumViews addSubview:iconView];
        [self.bottomView addSubview:self.lblNumViews];

        
        
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
    self.lblTitle.frame = frame;
    CGFloat y = frame.origin.y+frame.size.height+6.0f;
    
    frame = self.line.frame;
    frame.origin.y = y;
    self.line.frame = frame;
    

    
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
