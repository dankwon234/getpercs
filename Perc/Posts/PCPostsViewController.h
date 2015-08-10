//
//  PCPostsViewController.h
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"

@interface PCPostsViewController : PCViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) int mode; // 0=standard, 1=invited, 2=read only
@property (nonatomic) BOOL readOnly;
@end
