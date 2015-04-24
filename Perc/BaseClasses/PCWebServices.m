//
//  PCWebServices.m
//  Perc
//
//  Created by Dan Kwon on 3/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCWebServices.h"
#import "AFNetworking.h"
#import "Reachability.h"
#include <sys/xattr.h>

#define kErrorDomain @"com.getpercs"
#define kBaseUrl @"https://get-percs.appspot.com/"
#define kPathUpload @"/api/upload/"
#define kPathLogin @"/api/login/"
#define kPathStripe @"/stripe/card/"
#define kPathApplication @"/api/applications/"

// Resources:
#define kPathImages @"/site/images/"
#define kPathProfiles @"/api/profiles/"
#define kPathVenues @"/api/venues/"
#define kPathMessages @"/api/messages/"
#define kPathComments @"/api/comments/"
#define kPathZones @"/api/zones/"
#define kPathOrders @"/api/orders/"
#define kPathPosts @"/api/posts/"



@implementation PCWebServices
@synthesize isConnected;


+ (PCWebServices *)sharedInstance
{
    static PCWebServices *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PCWebServices alloc] init];
    });
    
    return shared;
}

- (BOOL)checkConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}




// PROFILES
- (void)registerProfile:(PCProfile *)profile completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathProfiles
       parameters:[profile parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      NSLog(@"REGISTRATION FAILED");
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];

}

- (void)login:(NSDictionary *)credentials completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];

    [manager POST:kPathLogin
       parameters:credentials
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}


- (void)fetchProfileInfo:(PCProfile *)profile completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager GET:[kPathProfiles stringByAppendingString:profile.uniqueId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = [responseDictionary objectForKey:@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(results, nil);
                 return ;
             }
             
             if (completionBlock){
                 NSLog(@"fetchProfileInfo: UPDATE FAILED");
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)updateProfile:(PCProfile *)profile completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager PUT:[kPathProfiles stringByAppendingString:profile.uniqueId]
      parameters:[profile parametersDictionary]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSLog(@"JSON: %@", responseObject);
             
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                 if (completionBlock){
                     completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                 }
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

// VENUES
- (void)fetchVenuesInZone:(NSString *)zone completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathVenues
      parameters:@{@"zone":zone}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)fetchVenuesNearLocation:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathVenues
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}



- (void)fetchZone:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathZones
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


#pragma mark - Posts
- (void)fetchPostsInZone:(NSString *)zone completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathPosts
      parameters:@{@"zone":zone}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)fetchPosts:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathPosts
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)createPost:(PCPost *)post completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathPosts
       parameters:[post parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}

- (void)updatePost:(PCPost *)post incrementView:(BOOL)addView completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[post parametersDictionary]];
    if (addView)
        params[@"action"] = @"addView";
    
    [manager PUT:[kPathPosts stringByAppendingString:post.uniqueId]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock)
                  completionBlock(nil, error);
          }];
    
}

#pragma mark - Order
- (void)fetchOrdersForProfile:(PCProfile *)profile completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathOrders
      parameters:@{@"profile":profile.uniqueId}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}



- (void)submitOrder:(PCOrder *)order completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathOrders
       parameters:[order parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}


#pragma mark - Messages
- (void)sendMessage:(PCMessage *)message completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathMessages
       parameters:[message parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}

- (void)fetchMessages:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathMessages
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


#pragma mark - Comments
- (void)fetchComments:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathComments
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)submitComment:(PCComment *)comment completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager POST:kPathComments
       parameters:[comment parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}

#pragma mark - Stripe
- (void)processStripeToken:(NSDictionary *)params completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager POST:kPathStripe
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];

}

- (void)submitDriverApplication:(NSDictionary *)application completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager POST:kPathApplication
       parameters:application
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}


#pragma mark - Images
- (void)fetchImage:(NSString *)imageId completionBlock:(PCWebServiceRequestCompletionBlock)completionBlock
{
    //check cache first:
    NSString *filePath = [self createFilePath:imageId];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data){
        UIImage *image = [UIImage imageWithData:data];
        //        NSLog(@"CACHED IMAGE: %@, %d bytes", imageId, (int)data.length);
        if (!image)
            NSLog(@"CACHED IMAGE IS NIL:");
        
        if (completionBlock)
            completionBlock(image, nil);
        
        return;
    }
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    AFImageResponseSerializer *serializer = [[AFImageResponseSerializer alloc] init];
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"image/jpeg", @"image/png"]];
    manager.responseSerializer = serializer;
    
    
    [manager GET:[kPathImages stringByAppendingString:imageId]
      parameters:@{@"crop":@"640"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             //Save image to cache directory:
             UIImage *img = (UIImage *)responseObject;
             NSData *imgData = UIImageJPEGRepresentation(img, 1.0f);
             //             [imgData writeToFile:filePath atomically:YES];
             //             [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
             
             [self cacheImage:img toPath:filePath];
             img = [UIImage imageWithData:imgData];
             completionBlock(img, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)fetchUploadString:(PCWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [manager GET:kPathUpload
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSDictionary *results = responseDictionary[@"results"];
             
             if ([results[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(results, nil);
                 return;
             }
             
             if (completionBlock)
                 completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(PCWebServiceRequestCompletionBlock)completionBlock
{
    NSData *imageData = image[@"data"];
    NSString *imageName = image[@"name"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:uploadUrl
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              NSDictionary *results = responseDictionary[@"results"];
              
              if ([results[@"confirmation"] isEqualToString:@"success"]){
                  if (completionBlock)
                      completionBlock(results, nil);
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completionBlock(nil, error);
              
          }];
}



- (AFHTTPRequestOperationManager *)requestManagerForJSONSerializiation
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}


#pragma mark - FileSavingStuff:
- (void)cacheImage:(UIImage *)image toPath:(NSString *)filePath
{
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    [imgData writeToFile:filePath atomically:YES];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
}



- (NSString *)createFilePath:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}




@end
