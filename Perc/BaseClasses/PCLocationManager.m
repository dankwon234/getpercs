//
//  PCLocationManager.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCLocationManager.h"
#import "Config.h"

@implementation PCLocationManager
@synthesize locationManager;
@synthesize now;
@synthesize geoCoder;
@synthesize completion;
@synthesize currentLocation;
@synthesize addressString;
@synthesize cities;
@synthesize clLocation;


- (id)init
{
    self = [super init];
    if (self){
        self.currentLocation = CLLocationCoordinate2DMake(40.7639869f, -73.9794185f); // default location is nyc
        self.cities = [NSMutableArray array];
    }
    return self;
}


+ (PCLocationManager *)sharedLocationManager
{
    static PCLocationManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PCLocationManager alloc] init];
        
    });
    
    return shared;
}

- (void)findLocation:(PCLocationManagerCompletionBlock)callback
{
    NSLog(@"findLocation:");
    if (callback != NULL)
        self.completion = callback;
    
    if (self.locationManager==nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) // required in iOS 8 and up
        [self.locationManager requestWhenInUseAuthorization];
    
    
    self.now = [[NSDate date] timeIntervalSinceNow];
    [self.locationManager startUpdatingLocation];
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"manager didUpdateLocations:");
    static double minAccuracy = 3000.0f;
    CLLocation *bestLocation = nil;
    for (CLLocation *loc in locations) {
        if (([loc.timestamp timeIntervalSince1970]-self.now) < 0) // cached location, ignore
            continue;
        
        
        NSLog(@"LOCATION: %@, %.4f, %4f, ACCURACY: %.2f,%.2f", [loc.timestamp description], loc.coordinate.latitude, loc.coordinate.longitude, loc.horizontalAccuracy, loc.verticalAccuracy);
        
        if (loc.horizontalAccuracy <= minAccuracy && loc.horizontalAccuracy <= minAccuracy){
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
            bestLocation = loc;
            break;
        }
    }
    
    if (bestLocation==nil) // couldn't find location to desired accuracy
        return;
    
    self.currentLocation = bestLocation.coordinate;
    self.clLocation = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    [self reverseGeocode:self.locationManager.location.coordinate completion:^{
        if (self.completion == NULL)
            return;
        
        self.completion(nil);
        self.completion = NULL;
    }];
    
}

- (void)reverseGeocode:(CLLocationCoordinate2D)location completion:(void (^)(void))callback
{
    NSLog(@"reverseGeocode:");
    if (self.geoCoder==nil)
        self.geoCoder = [[CLGeocoder alloc] init];
    
    CLLocation *loc = [[CLLocation alloc] initWithCoordinate:location
                                                    altitude:0
                                          horizontalAccuracy:0
                                            verticalAccuracy:0
                                                      course:0
                                                       speed:0
                                                   timestamp:[NSDate date]];
    
    [self.geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) { // Getting Human readable Address from Lat long...
        
        if (placemarks.count > 0){
            self.cities = [NSMutableArray array];
            for (CLPlacemark *placeMark in placemarks) {
                NSDictionary *locationInfo = placeMark.addressDictionary;
                NSString *cityState = @"";
                
                NSLog(@"%@", [locationInfo description]);
                self.addressString = locationInfo[@"Street"];
                NSString *city = locationInfo[@"City"];
                NSString *state = locationInfo[@"State"];
                
                BOOL validLocation = NO;
                if (city!=nil && state!=nil){
                    cityState = [cityState stringByAppendingString:[city lowercaseString]];
                    cityState = [cityState stringByAppendingString:[NSString stringWithFormat:@", %@", [state lowercaseString]]];
                    validLocation = YES;
                }
                
                if (!validLocation)
                    continue;
                
                [self.cities addObject:cityState];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLocationUpdatedNotification object:nil]];
            });
        }
        
        if (callback != nil)
            callback();
        
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    if (self.completion==NULL)
        return;
    
    self.completion(error);
    self.completion = NULL;
}






@end
