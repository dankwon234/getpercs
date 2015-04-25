//
//  PCMessageViewController.h
//  Perc
//
//  Created by Dan Kwon on 4/25/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCViewController.h"
#import "PCMessage.h"
#import <MessageUI/MessageUI.h>

@interface PCMessageViewController : PCViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>


@property (strong, nonatomic) PCMessage *message;
@end
