//
//  PCVenueCell.h
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <UIKit/UIKit.h>

@interface PCVenueCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UIView *base;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UILabel *lblDetails; // fee, distance, status, etc
@property (strong, nonatomic) UIButton *btnOrder;
@end
