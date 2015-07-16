//
//  PCGuestsViewController.h
//  Perc
//
//  Created by Dan Kwon on 7/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"
#import "PCPost.h"

@interface PCGuestsViewController : PCViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PCPost *post;
@end
