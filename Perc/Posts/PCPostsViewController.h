//
//  PCPostsViewController.h
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"

@interface PCPostsViewController : PCViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) int mode;
@end
