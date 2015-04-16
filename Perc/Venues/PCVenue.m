//
//  PCVenue.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenue.h"
#import "PCWebServices.h"

@interface PCVenue ()
@property (nonatomic) BOOL isFetching;
@end

@implementation PCVenue
@synthesize icon;
@synthesize iconData;
@synthesize name;
@synthesize city;
@synthesize state;
@synthesize address;
@synthesize fee;
@synthesize latitude;
@synthesize longitude;
@synthesize distance;
@synthesize uniqueId;
@synthesize orderZone;


- (id)init
{
    self = [super init];
    if (self) {
        self.isFetching = NO;
        self.distance = 0.0f;
    }
    
    return self;
}

+ (PCVenue *)venueWithInfo:(NSDictionary *)info
{
    PCVenue *venue = [[PCVenue alloc] init];
    [venue populate:info];
    return venue;
}

- (void)populate:(NSDictionary *)venueInfo
{
    self.uniqueId = venueInfo[@"id"];
    self.name = venueInfo[@"name"];
    self.address = venueInfo[@"address"];
    self.icon = venueInfo[@"image"];
    self.city = venueInfo[@"town"];
    self.state = venueInfo[@"state"];
    self.orderZone = venueInfo[@"zone"];
    self.latitude = [venueInfo[@"latitude"] doubleValue];
    self.longitude = [venueInfo[@"longitude"] doubleValue];

}


- (void)fetchImage
{
    if (self.isFetching)
        return;
    
    if ([self.icon isEqualToString:@"none"]) // no image, ignore
        return;
    
    self.isFetching = YES;
    [[PCWebServices sharedInstance] fetchImage:self.icon completionBlock:^(id result, NSError *error){
        self.isFetching = NO;
        if (error)
            return;
        
        UIImage *img = (UIImage *)result;
        self.iconData = img;
    }];
}


- (double)calculateDistanceFromLocation:(CLLocation *)location
{
    double dist = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude]]; // distance in meters
    double d = dist/1609.0f;
//    self.distance = d;
    return d;
}




@end
