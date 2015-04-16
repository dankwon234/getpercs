//
//  PCPostsViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/16/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostsViewController.h"

@interface PCPostsViewController ()

@end

@implementation PCPostsViewController


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBurger.png"]];
    CGRect frame = view.frame;
    


    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post"
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:nil];

    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] fetchPostsInZone:self.currentZone.uniqueId completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
    }];
}

- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
