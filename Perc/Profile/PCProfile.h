//
//  PCProfile.h
//  Perc
//
//  Created by Dan Kwon on 3/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PCProfile : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *promoCode;
@property (copy, nonatomic) NSString *referral; // promo code of person who referred profile
@property (copy, nonatomic) NSString *deviceToken;
@property (copy, nonatomic) NSString *lastZone;
@property (copy, nonatomic) NSString *bio;
@property (strong, nonatomic) NSMutableArray *orderHistory;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSMutableArray *invited; // posts that the user has been invited to
@property (strong, nonatomic) UIImage *imageData;
@property (nonatomic) BOOL isPopulated;
@property (nonatomic) BOOL isPublic;
@property (nonatomic) BOOL hasCreditCard;
@property (nonatomic) int points;
+ (PCProfile *)sharedProfile;
+ (PCProfile *)profileWithInfo:(NSDictionary *)info;
- (NSDictionary *)contactInfoDict;
- (void)populate:(NSDictionary *)profileInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)updateProfile;
- (void)fetchImage;
- (void)clear;
- (void)logout;
@end
