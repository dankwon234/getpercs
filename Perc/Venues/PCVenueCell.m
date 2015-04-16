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
@synthesize btnOrder;

#define kAnimationDuration 0.24f


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
        
        CGFloat dimen = frame.size.height-24.0f;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
        self.icon.center = CGPointMake(0.5f*frame.size.height, 0.5f*frame.size.height);
        self.icon.layer.cornerRadius = 0.5f*dimen;
        self.icon.layer.masksToBounds = YES;
        self.icon.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.icon.layer.borderWidth = 1.0f;
        self.icon.image = [UIImage imageNamed:@"icon.png"];
        self.icon.backgroundColor = [UIColor whiteColor];
        [self.base addSubview:self.icon];
        
        UIColor *darkGray = [UIColor darkGrayColor];
        UIColor *clear = [UIColor clearColor];
        
        CGFloat y = 12.0f;
        CGFloat x = self.icon.frame.origin.x+dimen+12.0f;
        CGFloat width = frame.size.width-x-12.0f;
        
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 18.0f)];
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        self.lblTitle.textAlignment = NSTextAlignmentRight;
        self.lblTitle.textColor = darkGray;
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.backgroundColor = clear;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.base addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
        self.lblLocation.textAlignment = NSTextAlignmentRight;
        self.lblLocation.textColor = darkGray;
        self.lblLocation.backgroundColor = clear;
        self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        [self.base addSubview:self.lblLocation];
        y += self.lblLocation.frame.size.height+4.0f;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self.base addSubview:line];
        y += line.frame.size.height+2.0f;
        
        
        self.lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
        self.lblDetails.textAlignment = NSTextAlignmentRight;
        self.lblDetails.textColor = kOrange;
        self.lblDetails.backgroundColor = clear;
        self.lblDetails.font = [UIFont fontWithName:kBaseFontName size:10.0f];
        [self.base addSubview:self.lblDetails];
        y += self.lblDetails.frame.size.height+4.0f;
        
        
        self.btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOrder.frame = CGRectMake(x, y, width, 28.0f);
        self.btnOrder.backgroundColor = [UIColor clearColor];
        self.btnOrder.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.btnOrder setTitleColor:kOrange forState:UIControlStateNormal];
        [self.btnOrder setTitle:@"ORDER" forState:UIControlStateNormal];
        self.btnOrder.layer.cornerRadius = 0.5f*self.btnOrder.frame.size.height;
        self.btnOrder.layer.masksToBounds = YES;
        self.btnOrder.layer.borderWidth = 1.0f;
        self.btnOrder.layer.borderColor = [kOrange CGColor];
        [self.base addSubview:self.btnOrder];
        
        
        [self.contentView addSubview:self.base];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideCell:)
                                                     name:kHideCellNotification
                                                   object:nil];
        
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
    CGRect boudingRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake(self.lblTitle.frame.size.width, 250.0f)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                          context:NULL];
    frame.size.height = boudingRect.size.height;
    self.lblTitle.frame = frame;
    
    CGFloat y = frame.origin.y+frame.size.height;
    
    frame = self.lblLocation.frame;
    frame.origin.y = y;
    self.lblLocation.frame = frame;
}



- (void)hideCell:(NSNotification *)note
{
    //    NSLog(@"HIDE CELL: %@", [note.userInfo description]);
    PCVenueCell *sourceCell = (PCVenueCell *)note.userInfo[@"source"];
    if ([sourceCell isEqual:self])
        return;
    
    self.contentView.alpha = 0.0f;
}




@end
