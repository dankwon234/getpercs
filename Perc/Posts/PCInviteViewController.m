//
//  PCInviteViewController.m
//  Perc
//
//  Created by Dan Kwon on 5/28/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCInviteViewController.h"

@implementation PCInviteViewController
@synthesize post;


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor greenColor];
    CGRect frame = view.frame;
    
    
    CGFloat y = frame.size.height-96.f;
    CGFloat h = 44.0f;
    CGFloat x = 16.0f;
    CGFloat width = frame.size.width-2*x;

    UIView *bgCreate = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgCreate.backgroundColor = [UIColor grayColor];
    
    UIButton *btnCreate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCreate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnCreate.frame = CGRectMake(x, 0.5f*(bgCreate.frame.size.height-h), width, h);
    btnCreate.backgroundColor = [UIColor clearColor];
    btnCreate.layer.cornerRadius = 0.5f*h;
    btnCreate.layer.masksToBounds = YES;
    btnCreate.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnCreate.layer.borderWidth = 1.0f;
    [btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    NSString *btnTitle = (self.isEditMode) ? @"UPDATE POST" : @"CREATE POST";
    [btnCreate setTitle:@"CREATE POST" forState:UIControlStateNormal];
//    [btnCreate addTarget:self action:@selector(createPost:) forControlEvents:UIControlEventTouchUpInside];
    [bgCreate addSubview:btnCreate];
    [view addSubview:bgCreate];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}


@end
