//
//  PCOrder.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCOrder.h"
#import "PCDateFormatter.h"
#import "PCWebServices.h"

@interface PCOrder ()
@property (strong, nonatomic) PCDateFormatter *dateFormatter;
@property (nonatomic) BOOL isFetching;
@end



#define kOneDay 24*60*60 // one day in seconds

@implementation PCOrder
@synthesize venue;
@synthesize order;
@synthesize profile;
@synthesize address;
@synthesize uniqueId;
@synthesize orderZone;
@synthesize paymentType;
@synthesize image;
@synthesize timestamp;
@synthesize formattedDate;
@synthesize imageData;
@synthesize price;
@synthesize deliveryFee;
@synthesize minDeliveryFee;

- (id)init
{
    self = [super init];
    if (self){
        self.dateFormatter = [PCDateFormatter sharedDateFormatter];
        self.uniqueId = @"none";
        self.order = @"none";
        self.profile = @"none";
        self.address = @"none";
        self.orderZone = @"none";
        self.paymentType = @"cash";
        self.image = @"none";
        self.venue = nil;
        self.imageData = nil;
        self.isFetching = NO;
        self.price = 0.0f;
        self.deliveryFee = 0.0f;
        self.minDeliveryFee = 0.0f;
    }
    return self;
}

+ (PCOrder *)orderWithInfo:(NSDictionary *)info
{
    PCOrder *order = [[PCOrder alloc] init];
    [order populate:info];
    return order;
}


- (void)populate:(NSDictionary *)info
{
    self.uniqueId = info[@"id"];
    self.venue = [PCVenue venueWithInfo:info[@"venue"]];
    self.order = info[@"orderContent"];
    self.profile = info[@"profile"];
    self.address = info[@"address"];
    self.orderZone = info[@"zone"];
    self.paymentType = info[@"paymentType"];
    self.image = info[@"image"];
    self.timestamp = [self.dateFormatter dateFromString:info[@"timestamp"]];
    self.price = [info[@"price"] doubleValue];
    self.deliveryFee = [info[@"deliveryFee"] doubleValue];
    [self formatTimestamp];
    
}

- (void)fetchImage
{
    if (self.isFetching)
        return;
    
    if ([self.image isEqualToString:@"none"]) // no image, ignore
        return;
    
    self.isFetching = YES;
    [[PCWebServices sharedInstance] fetchImage:self.image parameters:@{@"crop":@"640"} completionBlock:^(id result, NSError *error){
        self.isFetching = NO;
        if (error)
            return;
        
        UIImage *img = (UIImage *)result;
        self.imageData = img;
        if (!self.venue.iconData)
            self.venue.iconData = img;
    }];
}


- (void)formatTimestamp
{
//    NSTimeInterval sinceNow = -1*[self.timestamp timeIntervalSinceNow];
//    if (sinceNow < kOneDay){
//        double mins = sinceNow/60.0f;
//        if (mins < 60){
//            self.formattedDate = (mins < 2) ? [NSString stringWithFormat:@"%d minute ago", (int)mins] : [NSString stringWithFormat:@"%d minutes ago", (int)mins];
//            return;
//        }
//        
//        double hours = mins/60.0f;
//        self.formattedDate = [NSString stringWithFormat:@"%d hours ago", (int)hours];
//        return;
//    }
    
    NSString *dateString = [self.timestamp description];
//    NSLog(@"FORMATTED DATE: %@", dateString);
    
    NSArray *parts = [dateString componentsSeparatedByString:@" "]; // 2014-08-22
    parts = [parts[0] componentsSeparatedByString:@"-"];
    NSString *month = self.dateFormatter.monthsArray[[parts[1] intValue]-1];
    dateString = [NSString stringWithFormat:@"%@ %@, %@", month, parts[2], parts[0]];
    
    self.formattedDate = dateString;
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"orderContent":self.order, @"profile":self.profile, @"address":self.address, @"venue":self.venue.uniqueId, @"paymentType":self.paymentType, @"image":self.image, @"minDeliveryFee":[NSString stringWithFormat:@"%.2f", self.minDeliveryFee]}];
    
    if (self.orderZone)
        params[@"zone"] = self.orderZone;
    
    return params;
}


- (NSString *)jsonRepresentation
{
    NSDictionary *info = [self parametersDictionary];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        return nil;
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



@end
