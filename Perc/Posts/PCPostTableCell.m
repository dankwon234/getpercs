//
//  PCPostTableCell.m
//  Perc
//
//  Created by Dan Kwon on 7/13/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostTableCell.h"
#import "Config.h"

@implementation PCPostTableCell
@synthesize postIcon;
@synthesize lblTitle;
@synthesize lblDetails;

#define kCellHeight 84.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        static CGFloat padding = 12.0f;
        CGFloat dimen = kCellHeight-2*padding;
        self.postIcon = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, dimen, dimen)];
        self.postIcon.backgroundColor = [UIColor redColor];
        self.postIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.postIcon.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.postIcon.layer.shadowOpacity = 0.85f;
        self.postIcon.layer.shadowRadius = 1.0f;
        self.postIcon.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.postIcon.bounds].CGPath;
        [self.contentView addSubview:self.postIcon];
        
        CGFloat x = 2*padding+dimen;
        CGFloat y = padding;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, frame.size.width-2*x, 18.0f)];
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.contentView addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.lblTitle.frame.size.width, 14.0f)];
        self.lblDate.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        self.lblDate.textColor = kOrange;
        [self.contentView addSubview:self.lblDate];
        y += self.lblDate.frame.size.height+16.0f;
        
        
        self.lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.lblTitle.frame.size.width, 14.0f)];
        self.lblDetails.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        self.lblDetails.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.lblDetails];
    }
    
    return self;
}


+ (CGFloat)standardCellHeight
{
    return kCellHeight;
}

@end
