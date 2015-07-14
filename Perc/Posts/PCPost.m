//
//  PCPost.m
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPost.h"
#import "PCDateFormatter.h"
#import "PCWebServices.h"
#import "PCSession.h"

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
@synthesize zones;
@synthesize imageData;
@synthesize timestamp;
@synthesize formattedDate;
@synthesize numComments;
@synthesize numViews;
@synthesize comments;
@synthesize isVisible;
@synthesize tags;
@synthesize fee;
@synthesize invited;
@synthesize confirmed;
@synthesize type;
@synthesize adjustedFee;


- (id)init
{
    self = [super init];
    if (self){
        self.dateFormatter = [PCDateFormatter sharedDateFormatter];
        self.isFetching = NO;
        self.uniqueId = @"none";
        self.profile = nil;
        self.image = @"none";
        self.title = @"none";
        self.content = @"none";
        self.type = @"general";
        self.zones = [NSMutableArray array];
        self.tags = [NSMutableArray array];
        self.invited = [NSMutableArray array];
        self.confirmed = [NSMutableArray array];
        self.comments = nil;
        self.numViews = 0;
        self.numComments = 0;
        self.fee = 0;
        self.adjustedFee = 0.0f;
        self.isVisible = YES;
        self.isPublic = YES;
        
    }
    return self;
}


+ (PCPost *)postWithInfo:(NSDictionary *)info
{
    PCPost *post = [[PCPost alloc] init];
    [post populate:info];
    if ([post.uniqueId isEqualToString:@"none"]==NO){
        PCSession *session = [PCSession sharedSession];
        session.posts[post.uniqueId] = post;
    }
    
    return post;
}

- (void)populate:(NSDictionary *)info
{
    self.uniqueId = info[@"id"];
    self.profile = [PCProfile profileWithInfo:info[@"profile"]];
    self.image = info[@"image"];
    self.title = info[@"title"];
    self.content = info[@"content"];
    self.type = info[@"type"];
    self.invited = [NSMutableArray arrayWithArray:info[@"invited"]];
    self.confirmed = [NSMutableArray arrayWithArray:info[@"confirmed"]];
    self.tags = [NSMutableArray arrayWithArray:info[@"tags"]];
    self.isVisible = [info[@"isVisible"] isEqualToString:@"yes"];
    self.isPublic = [info[@"isPublic"] isEqualToString:@"yes"];
    self.numComments = [info[@"numComments"] intValue];
    self.numViews = [info[@"numViews"] intValue];
    self.fee = [info[@"fee"] intValue];
    self.adjustedFee = [info[@"adjustedFee"] doubleValue];
    self.timestamp = [self.dateFormatter dateFromString:info[@"timestamp"]];
    self.formattedDate = [self formatTimestamp];
    
    NSArray *z = info[@"zones"];
    for (int i=0; i<z.count; i++)
        [self.zones addObject:z[i]];
    
}

- (NSString *)formatTimestamp
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
    return [NSString stringWithFormat:@"%@ %@, %@", month, parts[2], parts[0]];
    
//    self.formattedDate = dateString;
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"image":self.image, @"title":self.title, @"content":self.content, @"zones":self.zones, @"fee":[NSString stringWithFormat:@"%d", self.fee], @"invited":self.invited, @"confirmed":self.confirmed}];
    
    params[@"isVisible"] = (self.isVisible) ? @"yes" : @"no";
    params[@"isPublic"] = (self.isPublic) ? @"yes" : @"no";

    if (self.profile)
        params[@"profile"] = self.profile.uniqueId;

    if (self.tags)
        params[@"tags"] = self.tags;

    if (self.type)
        params[@"type"] = self.type;

    


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
    if (self.isFetching)
        return;
    
    if ([self.image isEqualToString:@"none"]) // no image, ignore
        return;
    
    self.isFetching = YES;
    [[PCWebServices sharedInstance] fetchImage:self.image parameters:@{@"crop":@"1024"} completionBlock:^(id result, NSError *error){
        self.isFetching = NO;
        if (error)
            return;
        
        UIImage *img = (UIImage *)result;
        self.imageData = img;
    }];
}


@end
