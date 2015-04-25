//
//  PCMessage.m
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessage.h"
#import "PCDateFormatter.h"

@interface PCMessage ()
@property (strong, nonatomic) PCDateFormatter *dateFormatter;
@end

@implementation PCMessage
@synthesize uniqueId;
@synthesize post;
@synthesize profile;
@synthesize content;
@synthesize timestamp;
@synthesize recipient;
@synthesize formattedDate;
@synthesize isMine;


- (id)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [PCDateFormatter sharedDateFormatter];
        self.uniqueId = @"none";
        self.profile = nil;
        self.recipient = nil;
        self.content = @"none";
        self.post = @"none";
        self.isMine = NO;
    }
    
    return self;
}


- (void)populate:(NSDictionary *)messageInfo
{
    self.uniqueId = messageInfo[@"id"];
    self.profile = [PCProfile profileWithInfo:messageInfo[@"profile"]];
    self.recipient = [PCProfile profileWithInfo:messageInfo[@"recipient"]];
    self.content = messageInfo[@"content"];
    self.post = messageInfo[@"post"];
    self.timestamp = [self.dateFormatter dateFromString:messageInfo[@"timestamp"]];
    self.formattedDate = [self formatTimestamp];
}

+ (PCMessage *)messageWithInfo:(NSDictionary *)info
{
    PCMessage *msg = [[PCMessage alloc] init];
    [msg populate:info];
    return msg;
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
    NSLog(@"FORMATTED DATE: %@", dateString);
    
    NSArray *parts = [dateString componentsSeparatedByString:@" "]; // 2014-08-22
    parts = [parts[0] componentsSeparatedByString:@"-"];
    NSString *month = self.dateFormatter.monthsArray[[parts[1] intValue]-1];
    return [NSString stringWithFormat:@"%@ %@, %@", month, parts[2], parts[0]];
    
}




- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"post":self.post, @"content":self.content}];
    
    if (self.profile)
        params[@"profile"] = self.profile.uniqueId;

    if (self.recipient)
        params[@"recipient"] = self.recipient.uniqueId;

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


@end
