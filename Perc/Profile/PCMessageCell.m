//
//  PCMessageCell.m
//  Perc
//
//  Created by Dan Kwon on 4/22/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessageCell.h"
#import "Config.h"

#define kCellHeight 88.0f

@implementation PCMessageCell
@synthesize icon;
@synthesize lblName;
@synthesize lblDate;
@synthesize lblMessage;
@synthesize lblSource;
@synthesize configuration = _configuration;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        CGFloat dimen = kCellHeight-24.0f;
        CGFloat x = 12.0f;
        CGFloat y = 12.0f;
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, dimen, dimen)];
        self.icon.image = [UIImage imageNamed:@"icon.png"];
        self.icon.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.icon.layer.borderWidth = 0.5f;
        self.icon.layer.cornerRadius = 0.5f*dimen;
        self.icon.layer.masksToBounds = YES;
        [self.contentView addSubview:self.icon];
        
        x += dimen+12.0f;
        self.lblSource = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 50.0f, 18.0f)];
        self.lblSource.textColor = [UIColor blackColor];
        self.lblSource.font = [UIFont boldSystemFontOfSize:14.0f];
        self.lblSource.text = @"FROM:";
        [self.contentView addSubview:self.lblSource];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(x+self.lblSource.frame.size.width, y, frame.size.width-x, 18.0f)];
        self.lblName.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.contentView addSubview:self.lblName];
        y += self.lblName.frame.size.height;
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.lblName.frame.size.width, 14.0f)];
        self.lblDate.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        self.lblDate.textColor = kOrange;
        [self.contentView addSubview:self.lblDate];
        y += self.lblDate.frame.size.height+16.0f;
        
        self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.lblName.frame.size.width, 14.0f)];
        self.lblMessage.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        self.lblMessage.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.lblMessage];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kCellHeight-1.0f, frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:line];
    }
    
    return self;
}

+ (CGFloat)standardCellHeight
{
    return kCellHeight;
}

- (void)setConfiguration:(MessageCellConfiguration)configuration
{
//    NSLog(@"CONFIGURATION = %@", (configuration==MessageCellConfigurationFrom) ? @"From" : @"To");
    NSString *text = nil;
    CGFloat width = 0.0f;
    if (configuration==MessageCellConfigurationFrom){
        text = @"FROM: ";
        width = 50.0f;
    }
    
    if (configuration==MessageCellConfigurationTo){
        text = @"TO: ";
        width = 26.0f;
    }
    
    self.lblSource.text = text;
    CGRect frame = self.lblSource.frame;
    frame.size.width = width;
    self.lblSource.frame = frame;
    
    CGFloat x = frame.origin.x+frame.size.width;
    frame = self.lblName.frame;
    frame.origin.x = x;
    self.lblName.frame = frame;
}



- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
