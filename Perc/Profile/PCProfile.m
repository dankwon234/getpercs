//
//  PCProfile.m
//  Perc
//
//  Created by Dan Kwon on 3/19/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCProfile.h"
#import "PCWebServices.h"

@interface PCProfile ()
@property (nonatomic) BOOL isFetching;
@end

@implementation PCProfile
@synthesize uniqueId;
@synthesize firstName;
@synthesize lastName;
@synthesize phone;
@synthesize email;
@synthesize image;
@synthesize imageData;
@synthesize password;
@synthesize isPopulated;
@synthesize orderHistory;
@synthesize deviceToken;
@synthesize lastZone;
@synthesize messages;
@synthesize isPublic;
@synthesize posts;
@synthesize points;
@synthesize promoCode;
@synthesize bio;
@synthesize referral;
@synthesize invited;
@synthesize venmoId;

- (id)init
{
    self = [super init];
    if (self){
        [self clear];
        
//        if ([self populateFromCache])
//            [self refreshProfileInfo];

    }
    
    return self;
}


+ (PCProfile *)sharedProfile
{
    static PCProfile *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PCProfile alloc] init];
        if ([shared populateFromCache])
            [shared refreshProfileInfo];
        
    });
    
    return shared;
}

+ (PCProfile *)profileWithInfo:(NSDictionary *)info
{
    PCProfile *profile = [[PCProfile alloc] init];
    profile.isPublic = YES;
    [profile populate:info];
    return profile;
}

- (void)clear
{
    self.uniqueId = @"none";
    self.firstName = @"none";
    self.lastName = @"none";
    self.email = @"none";
    self.phone = @"none";
    self.image = @"none";
    self.bio = @"none";
    self.lastZone = @"none";
    self.promoCode = @"none";
    self.venmoId = @"none";
    self.referral = @"none";
    if (self.deviceToken==nil)
        self.deviceToken = @"none";

    self.password = nil;
    self.orderHistory = nil;
    self.messages = nil;
    self.posts = nil;
    self.invited = nil;
    self.isPopulated = NO;
    self.hasCreditCard = NO;
    self.isPublic = NO;
    self.points = 0;
    self.isFetching = NO;
}

- (void)logout
{
    [self clear];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
    [defaults synchronize];
}

- (void)populate:(NSDictionary *)profileInfo
{
    self.uniqueId = profileInfo[@"id"];
    self.firstName = profileInfo[@"firstName"];
    self.lastName = profileInfo[@"lastName"];
    self.email = profileInfo[@"email"];
    self.phone = profileInfo[@"phone"];
    self.image = profileInfo[@"image"];
    self.deviceToken = profileInfo[@"deviceToken"];
    self.lastZone = profileInfo[@"lastZone"];
    self.lastZone = profileInfo[@"promoCode"];
    self.bio = profileInfo[@"bio"];
    self.venmoId = profileInfo[@"venmoId"];
    self.points = [profileInfo[@"points"] intValue];
    if (profileInfo[@"creditCard"])
        self.hasCreditCard = [profileInfo[@"creditCard"] isEqualToString:@"yes"];
    
    
    self.isPopulated = YES;
    
    if (self.isPublic) // don't cache public profiles
        return;
    
    [self cacheProfile];
}

- (void)refreshProfileInfo
{
    //    NSLog(@"REFRESH PROFILE INFO: %@", self.uniqueId);
    if ([self.uniqueId isEqualToString:@"none"])
        return;
    
    [[PCWebServices sharedInstance] fetchProfileInfo:self completionBlock:^(id result, NSError *error){
        if (error)
            return;
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"REFRESH PROFILE INFO: %@", [results description]);
        if ([results[@"confirmation"] isEqualToString:@"success"]==NO)
            return;
        
        [self populate:results[@"profile"]]; //update profile with most refreshed data
    }];
}

- (void)updateProfile
{
    if ([self.uniqueId isEqualToString:@"none"])
        return;
    
    NSLog(@"updateProfile: %@", self.uniqueId);
    [[PCWebServices sharedInstance] updateProfile:self completionBlock:^(id result, NSError *error){
        if (error)
            return;
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"PROFILE UPDATED: %@", [results description]);
    }];
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



- (void)cacheProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [self jsonRepresentation];
    [defaults setObject:jsonString forKey:@"user"];
    [defaults synchronize];
}

- (BOOL)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"user"];
    if (!json)
        return NO;
    
    NSError *error = nil;
    NSDictionary *profileInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"STORED PROFILE: %@", [profileInfo description]);
    
    if (error)
        return NO;
    
    [self populate:profileInfo];
    return YES;
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"image":self.image, @"firstName":self.firstName, @"lastName":self.lastName, @"email":self.email, @"phone":self.phone, @"deviceToken":self.deviceToken}];
    
    if (self.password)
        params[@"password"] = self.password;
    
    if (self.lastZone)
        params[@"lastZone"] = self.lastZone;

    if (self.bio)
        params[@"bio"] = self.bio;
    
    if (self.referral)
        params[@"referral"] = self.referral;

    if (self.venmoId)
        params[@"venmoId"] = self.venmoId;


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

- (NSDictionary *)contactInfoDict
{
    NSString *fullName = self.firstName;
    if ([self.lastName isEqualToString:@"none"]==NO)
        fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@"%@", self.lastName]];
    
    NSDictionary *contactInfo = @{@"firstName":self.firstName, @"lastName":self.lastName, @"phoneNumber":self.phone, @"fullName":fullName};
    return contactInfo;
}




@end
