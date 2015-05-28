//
//  PCInviteViewController.h
//  Perc
//
//  Created by Dan Kwon on 5/28/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"
#import "PCPost.h"

@interface PCInviteViewController : PCViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PCPost *post;
@end
