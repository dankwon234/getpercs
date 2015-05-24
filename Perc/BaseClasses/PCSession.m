//
//  PCSession.m
//  Perc
//
//  Created by Dan Kwon on 5/24/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCSession.h"

@implementation PCSession


- (id)init
{
    self = [super init];
    if (self){
        self.posts = [NSMutableDictionary dictionary];
        
    }
    return self;
}

+ (PCSession *)sharedSession
{
    static PCSession *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PCSession alloc] init];
        
    });
    
    return shared;
}

@end
