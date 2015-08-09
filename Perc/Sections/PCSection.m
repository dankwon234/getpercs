//
//  PCSection.m
//  Perc
//
//  Created by Dan Kwon on 8/9/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCSection.h"
#import "PCWebServices.h"

@interface PCSection ()
@property (nonatomic) BOOL isFetching;
@end

@implementation PCSection
@synthesize uniqueId;
@synthesize name;
@synthesize posts;
@synthesize moderators;
@synthesize image;
@synthesize imageData;
@synthesize zone;

- (id)init
{
    self = [super init];
    if (self){
        self.image = @"none";
        self.name = @"none";
        self.zone = @"none";
        self.moderators = [NSMutableArray array];
        self.imageData = nil;
        self.posts = nil;
    }
    
    return self;
}

+ (PCSection *)sectionWithInfo:(NSDictionary *)info
{
    PCSection *section = [[PCSection alloc] init];
    [section populate:info];
    return section;
}


- (void)populate:(NSDictionary *)info
{
    self.uniqueId = info[@"id"];
    self.name = info[@"name"];
    self.image = info[@"image"];
    self.zone = info[@"zone"];
    self.moderators = [NSMutableArray arrayWithArray:info[@"moderators"]];
}

- (void)fetchImage
{
    if (self.isFetching)
        return;
    
    self.isFetching = YES;
    if ([self.image isEqualToString:@"none"])
        return;
    
    [[PCWebServices sharedInstance] fetchImage:self.image parameters:@{@"crop":@"640"} completionBlock:^(id result, NSError *error){
        self.isFetching = NO;
        if (error)
            return;
        
        self.imageData = (UIImage *)result;
    }];
}



- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"name":self.name}];
    
    if (self.moderators)
        params[@"moderators"] = self.moderators;

    if (self.image)
        params[@"image"] = self.image;

    if (self.zone)
        params[@"zone"] = self.zone;

    return params;

}


- (NSString *)jsonRepresentation
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self parametersDictionary]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error)
        return nil;
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}




@end
