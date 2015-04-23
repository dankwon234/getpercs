//
//  PCMessageCell.h
//  Perc
//
//  Created by Dan Kwon on 4/22/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <UIKit/UIKit.h>

@interface PCMessageCell : UITableViewCell


@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblName;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblMessage;
+ (CGFloat)standardCellHeight;
@end
