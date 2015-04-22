//
//  PCMessagesViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/22/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessagesViewController.h"
#import "PCMessage.h"


@interface PCMessagesViewController ()

@end

@implementation PCMessagesViewController


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = kLightGray;
//    CGRect frame = view.frame;

    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    
    if (self.profile.messages)
        return;
    
    self.profile.messages = [NSMutableArray array];
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] fetchMessages:@{@"profile":self.profile.uniqueId} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            NSArray *m = results[@"messages"];
            for (int i=0; i<m.count; i++)
                [self.profile.messages addObject:[PCMessage messageWithInfo:m[i]]];
        });
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
