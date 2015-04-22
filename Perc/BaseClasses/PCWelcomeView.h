//
//  PCWelcomeView.h
//  Perc
//
//  Created by Dan Kwon on 3/21/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCWelcomeViewDelegate <NSObject>
- (void)buttonPressed:(id)sender;
@end

@interface PCWelcomeView : UIView

@property (assign) id delegate;
@property (strong, nonatomic) UIButton *btnEnter;
@property (strong, nonatomic) UIButton *btnProfile;
- (void)introAnimation;
@end
