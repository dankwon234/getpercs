//
//  PCPost.h
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PCProfile.h"

@interface PCPost : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *formattedDate;
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) PCProfile *profile;
@property (strong, nonatomic) NSMutableArray *zones;
@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSMutableArray *invited;
@property (strong, nonatomic) NSMutableArray *confirmed;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) UIImage  *imageData;
@property (nonatomic) int numComments;
@property (nonatomic) int numViews;
@property (nonatomic) int fee;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isPublic;
+ (PCPost *)postWithInfo:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;
- (void)fetchImage;
@end
