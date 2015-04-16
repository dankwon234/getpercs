//
//  PCOrderViewController.h
//  Perc
//
//  Created by Dan Kwon on 3/23/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCViewController.h"
#import "PCOrder.h"

@interface PCOrderViewController : PCViewController <UIScrollViewDelegate>

@property (strong, nonatomic) PCOrder *order;
@end
