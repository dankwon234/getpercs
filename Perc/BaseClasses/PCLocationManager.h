//
//  PCLocationManager.h
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^PCLocationManagerCompletionBlock)(NSError *error);

@interface PCLocationManager : NSObject <CLLocationManagerDelegate>


@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *clLocation;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) PCLocationManagerCompletionBlock completion;
@property (strong, nonatomic) NSMutableArray *cities;
@property (copy, nonatomic) NSString *addressString;
@property (nonatomic) NSTimeInterval now;
+ (PCLocationManager *)sharedLocationManager;
- (void)findLocation:(PCLocationManagerCompletionBlock)callback;
- (void)reverseGeocode:(CLLocationCoordinate2D)location completion:(void (^)(void))callback;
@end
