//
//  PCCollectionViewFlowLayout.h
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellPadding 0.0f

@interface PCCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) BOOL isHorizontal;
+ (CGFloat)cellPadding;
+ (CGFloat)verticalCellWidth;
+ (CGFloat)cellWidth;
+ (CGFloat)cellHeight;
- (id)initVerticalFlowLayout;
@end
