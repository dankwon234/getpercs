//
//  PCZone.h
//  Perc
//
//  Created by Dan Kwon on 3/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCZone : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray *towns;
@property (strong, nonatomic) NSMutableArray *venues; // restaurants in the zone
@property (strong, nonatomic) NSMutableArray *admins;
@property (strong, nonatomic) NSMutableArray *sections;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int baseFee;
@property (nonatomic) BOOL isPopulated;
+ (PCZone *)sharedZone;
- (void)populate:(NSDictionary *)zoneInfo;
@end
