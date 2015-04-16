//
//  PCLoadingIndicator.h
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PCLoadingIndicator : UIView

@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UIView *darkScreen;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
- (void)stopLoading;
- (void)startLoading;
@end
