//
//  PCViewController.h
//  Perc
//
//  Created by Dan Kwon on 3/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import <UIKit/UIKit.h>
#import "Config.h"
#import "PCLoadingIndicator.h"
#import "PCProfile.h"
#import "PCZone.h"
#import "PCWebServices.h"
#import "PCLocationManager.h"
#import "PCSession.h"


@interface PCViewController : UIViewController

@property (strong, nonatomic) PCLoadingIndicator *loadingIndicator;
@property (strong, nonatomic) PCProfile *profile;
@property (strong, nonatomic) PCZone *currentZone;
@property (strong, nonatomic) PCSession *session;
@property (strong, nonatomic) PCLocationManager *locationMgr;
- (UIView *)baseView;
- (UIView *)baseViewWithNavBar;
- (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)msg;
- (void)shiftUp:(CGFloat)distance;
- (void)shiftBack:(CGFloat)origin;
- (void)addNavigationTitleView;
- (void)addCustomBackButton;
- (void)addMenuButton;
- (void)addOptionsButton;
- (void)toggleOptionsView:(UIButton *)btn;
- (void)showLoginView:(BOOL)animated;
- (void)showAccountView;
- (void)viewMenu:(id)sender;
- (void)back:(UIButton *)btn;
@end
