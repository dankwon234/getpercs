//
//  PCZone.m
//  Perc
//
//  Created by Dan Kwon on 3/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCZone.h"

@implementation PCZone
@synthesize uniqueId;
@synthesize name;
@synthesize towns;
@synthesize state;
@synthesize status;
@synthesize message;
@synthesize latitude;
@synthesize longitude;
@synthesize baseFee;
@synthesize venues;
@synthesize posts;
@synthesize isPopulated;

- (id)init
{
    self = [super init];
    if (self){
        self.venues = nil;
        self.posts = nil;
        self.isPopulated = NO;
        
    }
    return self;
}

+ (PCZone *)sharedZone
{
    static PCZone *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PCZone alloc] init];
        
    });
    
    return shared;
}

- (void)populate:(NSDictionary *)zoneInfo
{
    NSLog(@"POPULATE ZONE: %@", [zoneInfo description]);
    self.uniqueId = zoneInfo[@"id"];
    self.name = zoneInfo[@"name"];
    self.towns = zoneInfo[@"towns"];
    self.state = zoneInfo[@"state"];
    self.status = zoneInfo[@"status"];
    self.message = zoneInfo[@"message"];
    self.latitude = [zoneInfo[@"latitude"] doubleValue];
    self.longitude = [zoneInfo[@"longitude"] doubleValue];
    self.baseFee = [zoneInfo[@"baseFee"] intValue];
    self.isPopulated = YES;

}

@end
