//
//  PCPostTableCell.h
//  Perc
//
//  Created by Dan Kwon on 7/13/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <UIKit/UIKit.h>

@interface PCPostTableCell : UITableViewCell


@property (strong, nonatomic) UIImageView *postIcon;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblDetails;
+ (CGFloat)standardCellHeight;
@end
