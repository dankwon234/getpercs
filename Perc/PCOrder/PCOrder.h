//
//  PCOrder.h
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PCVenue.h"

@interface PCOrder : NSObject

@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *profile;
@property (copy, nonatomic) NSString *order;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *orderZone;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *formattedDate;
@property (copy, nonatomic) NSString *paymentType; // cash or credit
@property (strong, nonatomic) PCVenue *venue;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) UIImage *imageData;
@property (nonatomic) double price;
@property (nonatomic) double deliveryFee;
@property (nonatomic) double minDeliveryFee;
+ (PCOrder *)orderWithInfo:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;
- (void)fetchImage;
@end
