//
//  PCPostCell.h
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCPostCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UIView *base;
@property (strong, nonatomic) UILabel *lblTitle;
+ (CGFloat)cellWidth;
+ (CGFloat)cellHeight;
@end
