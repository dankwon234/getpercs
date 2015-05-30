//
//  PCContactCell.m
//  Perc
//
//  Created by Dan Kwon on 5/29/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCContactCell.h"

@implementation PCContactCell
@synthesize lblName;
@synthesize imgCheckmark;


#define kCellHeight 54.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        UIImage *checkmark = [UIImage imageNamed:@"iconCheckmark.png"];
        self.imgCheckmark = [[UIImageView alloc] initWithImage:checkmark];
        self.imgCheckmark.frame = CGRectMake(12.0f, 12.0f, checkmark.size.width, checkmark.size.height);
        [self.contentView addSubview:self.imgCheckmark];
        
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(checkmark.size.width+24.0f, 12.0f, frame.size.width-24.0f, 24.0f)];
        [self.contentView addSubview:self.lblName];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kCellHeight-1.0f, frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:line];
    }
    
    return self;
    
}

+ (CGFloat)standardCellHeight
{
    return kCellHeight;
    
}

@end
