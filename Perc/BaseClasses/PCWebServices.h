//
//  PCWebServices.h
//  Perc
//
//  Created by Dan Kwon on 3/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCProfile.h"
#import "PCOrder.h"
#import "PCPost.h"
#import "PCMessage.h"
#import "PCComment.h"

typedef void (^PCWebServiceRequestCompletionBlock)(id result, NSError *error);


@interface PCWebServices : NSObject

@property (nonatomic) BOOL isConnected;
+ (PCWebServices *)sharedInstance;
- (BOOL)checkConnection;

// PROFILES
- (void)registerProfile:(PCProfile *)profile completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)login:(NSDictionary *)credentials completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchProfileInfo:(PCProfile *)profile completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)updateProfile:(PCProfile *)profile completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock;


// VENUES
- (void)fetchVenuesInZone:(NSString *)zone completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchVenuesNearLocation:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock;

// POSTS
- (void)fetchPosts:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchPost:(NSString *)postId completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)createPost:(PCPost *)post completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)updatePost:(PCPost *)post incrementView:(BOOL)addView completion:(PCWebServiceRequestCompletionBlock)completionBlock;

// ZONE
- (void)fetchZone:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock;

// ORDER
- (void)fetchOrdersForProfile:(PCProfile *)profile completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)submitOrder:(PCOrder *)order completion:(PCWebServiceRequestCompletionBlock)completionBlock;

// MESSAGES
- (void)sendMessage:(PCMessage *)message completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchMessages:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock;

// COMMENTS
- (void)submitComment:(PCComment *)comment completion:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchComments:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock;


// STRIPE
- (void)processStripeToken:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock;


// Images
- (void)fetchImage:(NSString *)imageId parameters:(NSDictionary *)params completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchUploadString:(PCWebServiceRequestCompletionBlock)completionBlock;
- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(PCWebServiceRequestCompletionBlock)completionBlock;


// Venmo

@end
