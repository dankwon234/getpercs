//
//  PCSession.h
//  Perc
//
//  Created by Dan Kwon on 5/24/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSession : NSObject


@property (strong, nonatomic) NSMutableDictionary *posts;
+ (PCSession *)sharedSession;
@end
