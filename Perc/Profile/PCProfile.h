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
@property (copy, nonatomic) NSString *deviceToken;
@property (copy, nonatomic) NSString *lastZone;
@property (strong, nonatomic) NSMutableArray *orderHistory;
@property (strong, nonatomic) UIImage *imageData;
@property (nonatomic) BOOL isPopulated;
@property (nonatomic) BOOL hasCreditCard;
+ (PCProfile *)sharedProfile;
- (void)populate:(NSDictionary *)profileInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)updateProfile;
- (void)fetchImage;
- (void)clear;
@end
