//
//  PCVenueViewController.h
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"
#import "PCVenue.h"

@interface PCVenueViewController : PCViewController

@property (strong, nonatomic) PCVenue *venue;
@property (nonatomic) int mode;
@end
