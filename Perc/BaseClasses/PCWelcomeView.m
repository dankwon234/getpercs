//
//  PCWelcomeView.m
//  Perc
//
//  Created by Dan Kwon on 3/21/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCWelcomeView.h"
#import "Config.h"

@interface PCWelcomeView()
@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) UIImageView *imgEating;
@end

@implementation PCWelcomeView
@synthesize btnOrder;
@synthesize btnProfile;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.imgEating = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgEating-1.png"]];
        self.imgEating.center = CGPointMake(0.5f*frame.size.width, 0.5f*frame.size.height);
        self.imgEating.alpha = 0.0f;
        [self addSubview:self.imgEating];

        self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-white.png"]];
        self.logo.center = CGPointMake(0.5f*frame.size.width, 0.5f*frame.size.height);
        self.logo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.logo.alpha = 0.0f;
        [self addSubview:self.logo];
        
        static CGFloat x = 20.0;
        CGFloat y = 210.0f;
        static CGFloat h = 44.0f;

        self.btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOrder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.btnOrder.frame = CGRectMake(x, y, frame.size.width-2*x, h);
        self.btnOrder.backgroundColor = [UIColor clearColor];
        self.btnOrder.layer.cornerRadius = 0.5f*h;
        self.btnOrder.layer.masksToBounds = YES;
        self.btnOrder.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.btnOrder.layer.borderWidth = 1.0f;
        self.btnOrder.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnOrder setTitle:@"Order" forState:UIControlStateNormal];
        self.btnOrder.alpha = 0.0f;
        [self.btnOrder addTarget:self action:@selector(btnOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnOrder];
        y += self.btnOrder.frame.size.height+20.0f;


        self.btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnProfile.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.btnProfile.frame = CGRectMake(x, y, frame.size.width-2*x, h);
        self.btnProfile.backgroundColor = [UIColor clearColor];
        self.btnProfile.layer.cornerRadius = 0.5f*h;
        self.btnProfile.layer.masksToBounds = YES;
        self.btnProfile.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.btnProfile.layer.borderWidth = 1.0f;
        self.btnProfile.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        [self.btnProfile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnProfile setTitle:@"Log In" forState:UIControlStateNormal];
        self.btnProfile.alpha = 0.0f;
        [self.btnProfile addTarget:self action:@selector(btnProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnProfile];


    }
    return self;
}

- (void)introAnimation
{

    [UIView animateWithDuration:0.30f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.logo.alpha = 1.0f;

                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.65f
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.imgEating.alpha = 1.0f;

                                              CGPoint center = self.logo.center;
                                              center.y = 0.2f*self.frame.size.height;
                                              self.logo.center = center;
                                              
                                          }
                                          completion:^(BOOL finished){
                                              [self animateBackground];
                                              
                                              [UIView animateWithDuration:0.5f
                                                                    delay:0
                                                                  options:UIViewAnimationOptionCurveLinear
                                                               animations:^{
                                                                   self.btnOrder.alpha = 1.0f;
                                                               }
                                                               completion:^(BOOL finished){
                                                                   
                                                               }];

                                              [UIView animateWithDuration:0.5f
                                                                    delay:0.10f
                                                                  options:UIViewAnimationOptionCurveLinear
                                                               animations:^{
                                                                   self.btnProfile.alpha = 1.0f;
                                                               }
                                                               completion:^(BOOL finished){
                                                                   
                                                               }];


                                              
                                          }];
                         
                     }];
    
}


- (void)animateBackground
{
    [UIView animateWithDuration:55.0f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGPoint center = self.imgEating.center;
                         center.y -= 50.0f;
                         center.x -= 150.0f;
                         self.imgEating.center = center;
                         
                         self.imgEating.transform = CGAffineTransformMakeScale(1.4f, 1.4f);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
}

- (void)btnOrderAction:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
        [self.delegate buttonPressed:btn];
}

- (void)btnProfileAction:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
        [self.delegate buttonPressed:btn];
}

@end
