//
//  PCSection.h
//  Perc
//
//  Created by Dan Kwon on 8/9/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PCSection : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *zone;
@property (copy, nonatomic) NSString *image;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSMutableArray *moderators;
@property (strong, nonatomic) UIImage  *imageData;
- (void)populate:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)fetchImage;
@end
