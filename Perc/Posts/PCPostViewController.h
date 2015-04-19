//
//  PCPostViewController.h
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"
#import "PCPost.h"

@interface PCPostViewController : PCViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PCPost *post;
@end
