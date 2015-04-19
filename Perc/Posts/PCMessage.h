//
//  PCMessage.h
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <Foundation/Foundation.h>

@interface PCMessage : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *profile; // id num of profile who wrote the message
@property (copy, nonatomic) NSString *recipient; // id of profile sent to
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *post; // id of post message refers to
@property (strong, nonatomic) NSDate *timestamp;
- (void)populate:(NSDictionary *)messageInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
@end
