//
//  PCVenueViewController.h
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCViewController.h"
#import "PCVenue.h"

@interface PCVenueViewController : PCViewController <UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) PCVenue *venue;
@property (strong, nonatomic) PCOrder *order;
@end
