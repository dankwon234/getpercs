//
//  PCDateFormatter.h
//  Perc
//
//  Created by Dan Kwon on 3/23/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCDateFormatter : NSDateFormatter

@property (strong, nonatomic) NSArray *monthsArray;
+ (PCDateFormatter *)sharedDateFormatter;
@end
