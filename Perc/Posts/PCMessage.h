//
//  PCMessage.h
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <Foundation/Foundation.h>
#import "PCProfile.h"

@interface PCMessage : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *formattedDate;
@property (copy, nonatomic) NSString *post; // id of post message refers to
@property (strong, nonatomic) PCProfile *profile; // id num of profile who wrote the message
@property (strong, nonatomic) PCProfile *recipient; // id of profile sent to
@property (strong, nonatomic) NSDate *timestamp;
+ (PCMessage *)messageWithInfo:(NSDictionary *)info;
- (void)populate:(NSDictionary *)messageInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
@end
