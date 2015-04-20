//
//  PCComment.m
//  Perc
//
//  Created by Dan Kwon on 4/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCComment.h"

@implementation PCComment
@synthesize uniqueId;
@synthesize profile;
@synthesize text;
@synthesize thread;
@synthesize timestamp;

- (id)init
{
    self = [super init];
    if (self) {
        self.uniqueId = @"none";
        self.profile = @"none";
        self.text = @"none";
        self.thread = @"none";
    }
    
    return self;
}



- (void)populate:(NSDictionary *)commentInfo
{
    self.uniqueId = commentInfo[@"id"];
    self.profile = commentInfo[@"profile"];
    self.text = commentInfo[@"text"];
    self.thread = commentInfo[@"thread"];
    
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
