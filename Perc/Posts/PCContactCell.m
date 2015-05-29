//
//  PCContactCell.m
//  Perc
//
//  Created by Dan Kwon on 5/29/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCContactCell.h"

@implementation PCContactCell
@synthesize lblName;

#define kCellHeight 54.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 12.0f, frame.size.width-24.0f, 24.0f)];
        [self.contentView addSubview:self.lblName];
        
        
    }
    
    return self;
    
}

+ (CGFloat)standardCellHeight
{
    return kCellHeight;
    
}

@end
