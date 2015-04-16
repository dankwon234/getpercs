//
//  PCPost.m
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPost.h"
#import "PCDateFormatter.h"
#import "PCWebServices.h"

@interface PCPost ()
@property (strong, nonatomic) PCDateFormatter *dateFormatter;
@property (nonatomic) BOOL isFetching;
@end


@implementation PCPost
@synthesize uniqueId;
@synthesize title;
@synthesize content;
@synthesize image;
@synthesize profile;
@synthesize zone;
@synthesize imageData;
@synthesize timestamp;
@synthesize formattedDate;


- (id)init
{
    self = [super init];
    if (self){
        self.isFetching = NO;
        
    }
    return self;
}


+ (PCPost *)postWithInfo:(NSDictionary *)info
{
    PCPost *post = [[PCPost alloc] init];
    [post populate:info];
    return post;
}

- (void)populate:(NSDictionary *)info
{
    self.uniqueId = info[@"id"];
    self.profile = info[@"profile"];
    self.image = info[@"image"];
    self.title = info[@"title"];
    self.content = info[@"content"];
    self.zone = info[@"zone"];
    self.timestamp = [self.dateFormatter dateFromString:info[@"timestamp"]];
}

- (void)formatTimestamp
{
//    NSTimeInterval sinceNow = -1*[self.timestamp timeIntervalSinceNow];
//    if (sinceNow < kOneDay){
//        double mins = sinceNow/60.0f;
//        if (mins < 60){
//            self.formattedDate = (mins < 2) ? [NSString stringWithFormat:@"%d minute ago", (int)mins] : [NSString stringWithFormat:@"%d minutes ago", (int)mins];
//            return;
//        }
//
//        double hours = mins/60.0f;
//        self.formattedDate = [NSString stringWithFormat:@"%d hours ago", (int)hours];
//        return;
//    }
    
    NSString *dateString = [self.timestamp description];
    //    NSLog(@"FORMATTED DATE: %@", dateString);
    
    NSArray *parts = [dateString componentsSeparatedByString:@" "]; // 2014-08-22
    parts = [parts[0] componentsSeparatedByString:@"-"];
    NSString *month = self.dateFormatter.monthsArray[[parts[1] intValue]-1];
    dateString = [NSString stringWithFormat:@"%@ %@, %@", month, parts[2], parts[0]];
    
    self.formattedDate = dateString;
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"profile":self.profile, @"image":self.image, @"title":self.title, @"content":self.content, @"zone":self.zone}];
    
    
    return params;
}

- (NSString *)jsonRepresentation
{
    NSDictionary *info = [self parametersDictionary];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        return nil;
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)fetchImage
{
    
}


@end
