//
//  PCPost.h
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PCPost : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *profile;
@property (copy, nonatomic) NSString *formattedDate;
@property (strong, nonatomic) NSMutableArray *zones;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) UIImage  *imageData;
@property (nonatomic) int numComments;
@property (nonatomic) int numViews;
+ (PCPost *)postWithInfo:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;
- (void)fetchImage;
@end
