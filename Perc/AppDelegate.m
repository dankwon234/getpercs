//
//  AppDelegate.m
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "AppDelegate.h"
#import "PCContainerViewController.h"
#import "Stripe.h"
#import "PCProfile.h"

NSString * const StripePublishableKey = @"pk_live_8ftaqUCg4JwMMzw0NK6xl3H2";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // this is how notifications are handled in iOS 8:
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    

    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
//    PCContainerViewController *containerVc = [[PCContainerViewController alloc] init];
    self.window.rootViewController = [[PCContainerViewController alloc] init];
    
    
    [self.window makeKeyAndVisible];

    
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    if (!deviceToken)
        return;
    
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    for (NSString *character in @[@"<", @">", @" "])
        token = [token stringByReplacingOccurrencesOfString:character withString:@""];
    
    NSLog(@"application didRegisterForRemoteNotificationsWithDeviceToken: %@", token);
    PCProfile *profile = [PCProfile sharedProfile];
    if ([profile.deviceToken isEqualToString:token]) // already the same, no need to update
        return;

    profile.deviceToken = token;
    [profile updateProfile];
}



- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications]; // register to receive notifications
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"application handleActionWithIdentifier: %@ forRemoteNotification: %@", identifier, [userInfo description]);
    
    
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        
    }
    
    if ([identifier isEqualToString:@"answerAction"]){
        
    }
}

// this handles push notifications when the app is currently running in the foreground:
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"application didReceiveRemoteNotification: %@", [userInfo description]);
    // sample:
    //    2015-03-24 03:35:41.696 Perc[540:29320] application didReceiveRemoteNotification: {
    //        aps =     {
    //            alert = "This is a test message";
    //        };
    //    }
    
    NSDictionary *aps = userInfo[@"aps"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perc Notification"
                                                    message:aps[@"alert"]
                                                   delegate:nil cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
