//
//  PCConnectViewController.h
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"
#import "PCPost.h"

@interface PCConnectViewController : PCViewController <UIScrollViewDelegate, UITextViewDelegate>


@property (strong, nonatomic) PCPost *post;
@end
