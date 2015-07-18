//
//  PCCreditCardViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCCreditCardViewController.h"
#import "STPCard.h"
#import "STPToken.h"
#import "STPAPIClient.h"

@interface PCCreditCardViewController() <PTKViewDelegate>
@property (strong, nonatomic) UILabel *lblCredit;
@property (strong, nonatomic) UIButton *btnCharge;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (weak, nonatomic) PTKView *paymentView;
@end


@implementation PCCreditCardViewController

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundBlue.png"]];
    CGRect frame = view.frame;
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.delegate = self;
   
    self.lblCredit.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblCredit = [[UILabel alloc] initWithFrame:CGRectMake(20, 48.0f, frame.size.width-40.0f, 22.0f)];
    self.lblCredit.textAlignment = NSTextAlignmentCenter;
    self.lblCredit.textColor = [UIColor whiteColor];
    self.lblCredit.text = @"Add Credit Card";
    self.lblCredit.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    [self.theScrollview addSubview:self.lblCredit];
    
    if (frame.size.height <= 568.0f) // enable scrolling only on iPhone 5 and less
         self.theScrollview.contentSize = CGSizeMake(0, 680.0f);
    
    [view addSubview:self.theScrollview];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    CGRect frame = self.view.frame;
    PTKView *creditCardField = [[PTKView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width-30.0f, 55.0f)];
    creditCardField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    creditCardField.center = CGPointMake(0.5f*self.view.frame.size.width, 120.0f);
    self.paymentView = creditCardField;
    self.paymentView.delegate = self;
    [self.theScrollview addSubview:self.paymentView];
    CGFloat y = creditCardField.frame.origin.y+creditCardField.frame.size.height+20.0f;
    
    
    self.btnCharge = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCharge.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnCharge.frame = CGRectMake(0.0f, y, creditCardField.frame.size.width, 44.0f);
    self.btnCharge.center = CGPointMake(0.5f*frame.size.width, self.btnCharge.center.y);
    self.btnCharge.backgroundColor = [UIColor clearColor];
    self.btnCharge.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnCharge.layer.borderWidth = 1.0f;
    self.btnCharge.layer.cornerRadius = 22.0f;
    self.btnCharge.layer.masksToBounds = YES;
    self.btnCharge.userInteractionEnabled = NO;
    self.btnCharge.alpha = 0.5f;
    [self.btnCharge setTitle:@"Submit" forState:UIControlStateNormal];
    [self.btnCharge setTitleColor:[UIColor whiteColor] forState:16.0f];
    [self.btnCharge addTarget:self action:@selector(chargeCard:) forControlEvents:UIControlEventTouchUpInside];
    [self.theScrollview addSubview:self.btnCharge];
    y += self.btnCharge.frame.size.height +24.0f;
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, creditCardField.frame.size.width, 150.0f)];
    lblDescription.numberOfLines = 0;
    lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
    lblDescription.textAlignment = NSTextAlignmentCenter;
    lblDescription.textColor = [UIColor whiteColor];
    lblDescription.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblDescription.backgroundColor = [UIColor clearColor];
    lblDescription.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblDescription.center = CGPointMake(self.btnCharge.center.x, lblDescription.center.y);
    lblDescription.text = @"Your card will not be charged. Our driver will send you a text message with the full price (including delivery fee) then the card will be charged. Afterward, you do not have to add your credit card number again.";
    [self.theScrollview addSubview:lblDescription];
    
}


- (void)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)chargeCard:(UIButton *)btn
{
    NSLog(@"chargeCard: ");
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    
    [self.loadingIndicator startLoading];
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  [self.loadingIndicator stopLoading];
                                                  NSLog(@"ERROR: %@", [error localizedDescription]);
                                                  //                                                  [self handleError:error];
                                                  return;
                                              }
                                              
                                              NSLog(@"SUCCESS: createBackendChargeWithToken: %@", token.tokenId);
                                              [self createBackendChargeWithToken:token];
                                              //                                              [self createBackendChargeWithToken:token completion:NULL];
                                          }];
    
}

- (void)createBackendChargeWithToken:(STPToken *)token
{
    NSDictionary *params = @{@"stripeToken":token.tokenId, @"profile":self.profile.uniqueId};
    NSLog(@"createBackendChargeWithToken: %@", [params description]);
    
    [[PCWebServices sharedInstance] processStripeToken:params completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error) {
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        [self.profile populate:results[@"profile"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kCreditCardAddedNotification object:nil]];
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            
        });
        
        
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.paymentView resignFirstResponder];
}



#pragma mark - PTKViewDelegate
- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"paymentView: withCard: isValid:");
    self.btnCharge.userInteractionEnabled = valid;
    self.btnCharge.alpha = (valid) ? 1.0f : 0.5f;

    // Toggle navigation, for example
    //    self.saveButton.enabled = valid;
}

@end
