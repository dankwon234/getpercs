//
//  PCVenuesViewController.h
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCViewController.h"


@interface PCVenuesViewController : PCViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic) int mode; //0=regular, 1=order history
@end
