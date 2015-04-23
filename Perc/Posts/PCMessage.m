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
        self.profile = nil;
        self.recipient = nil;
        self.content = @"none";
        self.post = @"none";
    }
    
    return self;
}


- (void)populate:(NSDictionary *)messageInfo
{
    self.uniqueId = messageInfo[@"id"];
    self.profile = [PCProfile profileWithInfo:messageInfo[@"proifle"]];
    self.recipient = [PCProfile profileWithInfo:messageInfo[@"recipient"]];
    self.content = messageInfo[@"content"];
    self.post = messageInfo[@"post"];
}

+ (PCMessage *)messageWithInfo:(NSDictionary *)info
{
    PCMessage *msg = [[PCMessage alloc] init];
    [msg populate:info];
    return msg;
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
