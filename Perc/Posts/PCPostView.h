//
//  PCPostView.h
//  Perc
//
//  Created by Dan Kwon on 7/3/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCPostView : UIView


@property (strong, nonatomic) UIImageView *postImage;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblComments;
@property (strong, nonatomic) UILabel *lblViews;
@property (strong, nonatomic) UILabel *lblDate;
@end
