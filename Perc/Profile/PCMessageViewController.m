//
//  PCMessageViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/25/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCMessageViewController.h"

@interface PCMessageViewController ()

@end

@implementation PCMessageViewController
@synthesize message;


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = kLightGray;
//    CGRect frame = view.frame;

    
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
