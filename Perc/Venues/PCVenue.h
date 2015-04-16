//
//  PCVenue.h
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface PCVenue : NSObject

@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *orderZone;
@property (copy, nonatomic) NSString *state;
@property (strong, nonatomic) UIImage *iconData;
@property (nonatomic) int fee; // in cents
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double distance;
+ (PCVenue *)venueWithInfo:(NSDictionary *)info;
- (void)fetchImage;
- (void)populate:(NSDictionary *)venueInfo;
- (double)calculateDistanceFromLocation:(CLLocation *)location;
@end
