//
//  PCMessage.m
//  Perc
//
//  Created by Dan Kwon on 4/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessage.h"

@implementation PCMessage
@synthesize uniqueId;
@synthesize post;
@synthesize profile;
@synthesize content;
@synthesize timestamp;
@synthesize recipient;


- (id)init
{
    self = [super init];
    if (self) {
        self.uniqueId = @"none";
        self.profile = @"none";
        self.recipient = @"none";
        self.content = @"none";
        self.post = @"none";
    }
    
    return self;
}


- (void)populate:(NSDictionary *)messageInfo
{
    self.uniqueId = messageInfo[@"id"];
    self.profile = messageInfo[@"profile"];
    self.recipient = messageInfo[@"recipient"];
    self.content = messageInfo[@"content"];
    self.post = messageInfo[@"post"];
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"profile":self.profile, @"recipient":self.recipient, @"post":self.post, @"content":self.content}];
    
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
