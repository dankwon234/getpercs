//
//  PCComment.h
//  Perc
//
//  Created by Dan Kwon on 4/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <Foundation/Foundation.h>

@interface PCComment : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *profile;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *thread;
@property (copy, nonatomic) NSString *formattedDate;
@property (strong, nonatomic) NSDate *timestamp;
+ (PCComment *)commentWithInfo:(NSDictionary *)commentInfo;
- (void)populate:(NSDictionary *)commentInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
@end
