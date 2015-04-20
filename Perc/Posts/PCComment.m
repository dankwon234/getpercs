//
//  PCComment.m
//  Perc
//
//  Created by Dan Kwon on 4/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCComment.h"
#import "PCDateFormatter.h"

@interface PCComment ()
@property (strong, nonatomic) PCDateFormatter *dateFormatter;
@end


@implementation PCComment
@synthesize uniqueId;
@synthesize profile;
@synthesize text;
@synthesize thread;
@synthesize timestamp;
@synthesize formattedDate;

- (id)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [PCDateFormatter sharedDateFormatter];
        self.uniqueId = @"none";
        self.profile = @"none";
        self.text = @"none";
        self.thread = @"none";
        self.formattedDate = @"none";
    }
    
    return self;
}

+ (PCComment *)commentWithInfo:(NSDictionary *)commentInfo
{
    PCComment *comment = [[PCComment alloc] init];
    [comment populate:commentInfo];
    return comment;
}

- (void)populate:(NSDictionary *)commentInfo
{
    self.uniqueId = commentInfo[@"id"];
    self.profile = commentInfo[@"profile"];
    self.text = commentInfo[@"text"];
    self.thread = commentInfo[@"thread"];
    self.timestamp = [self.dateFormatter dateFromString:commentInfo[@"timestamp"]];
    self.formattedDate = [self formatTimestamp];
    
}

- (NSString *)formatTimestamp
{
    NSString *dateString = [self.timestamp description];
    NSLog(@"FORMATTED DATE: %@", dateString);
    
    NSArray *parts = [dateString componentsSeparatedByString:@" "]; // 2014-08-22
    parts = [parts[0] componentsSeparatedByString:@"-"];
    NSString *month = self.dateFormatter.monthsArray[[parts[1] intValue]-1];
    return [NSString stringWithFormat:@"%@ %@, %@", month, parts[2], parts[0]];
}



- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"profile":self.profile, @"text":self.text, @"thread":self.thread}];
    
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
