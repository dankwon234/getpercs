//
//  PCDateFormatter.m
//  Perc
//
//  Created by Dan Kwon on 3/23/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCDateFormatter.h"

@implementation PCDateFormatter
@synthesize monthsArray;

- (id)init
{
    self = [super init];
    if (self){
        
        [self setDateFormat:@"EEE MMM dd HH:mm:ss z yyyy"]; //Tue Jun 17 00:52:49 UTC 2014
        self.monthsArray = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"June", @"July", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
        
    }
    
    return self;
}


+ (PCDateFormatter *)sharedDateFormatter
{
    
    static PCDateFormatter *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[PCDateFormatter alloc] init];
        
    });
    
    return shared;
}




@end
