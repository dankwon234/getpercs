//
//  PCVenueViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCVenueViewController.h"
#import "PCCreditCardViewController.h"
#import "PCOrder.h"

@interface PCVenueViewController ()
@property (strong, nonatomic) UITextView *orderForm;
@property (strong, nonatomic) UITextField *addressField;
@property (strong, nonatomic) UILabel *lblTown;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UIImageView *venueIcon;
@end

static NSString *placeholder = @"Type your order here.";
#define kTopInset 0.0f

@implementation PCVenueViewController
@synthesize venue;
@synthesize order;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(creditCardAdded:)
                                                     name:kCreditCardAddedNotification
                                                   object:nil];

    }
    return self;
}


- (void)loadView
{
    if (self.order==nil) // this can be assigned from the parent vc
        self.order = [[PCOrder alloc] init];

    
    UIView *view = [self baseView];
    UIImage *imgBackground = [UIImage imageNamed:@"hopper.png"];
    view.backgroundColor = [UIColor colorWithPatternImage:imgBackground];
    CGRect frame = view.frame;
    
    static CGFloat dimen = 88.0f;
    self.venueIcon = [[UIImageView alloc] initWithImage:self.venue.iconData];
    self.venueIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.venueIcon.frame = CGRectMake(0.0f, 0.0f, dimen, dimen);
    self.venueIcon.center = CGPointMake(0.5f*frame.size.width, 0.5f*dimen+20.0f);
    self.venueIcon.layer.cornerRadius = 0.5f*dimen;
    self.venueIcon.layer.masksToBounds = YES;
    self.venueIcon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.venueIcon.layer.borderWidth = 1.0f;
    [view addSubview:self.venueIcon];
    
    
    CGFloat y = self.venueIcon.frame.origin.y+self.venueIcon.frame.size.height+12.0f;
    CGFloat x = 20.0f;
    CGFloat width = frame.size.width-2*x;
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 20.0f)];
    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblLocation.textColor = [UIColor whiteColor];
    self.lblLocation.textAlignment = NSTextAlignmentCenter;
    self.lblLocation.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.lblLocation.text = [NSString stringWithFormat:@"%@ \u00b7 Min Delivery Fee: $%d", [venue.city capitalizedString], venue.fee];
    [view addSubview:self.lblLocation];
    y += self.lblLocation.frame.size.height+20.0f;
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.delegate = self;
    self.theScrollview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.theScrollview.showsVerticalScrollIndicator = NO;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    UIView *orderBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 240.0f)];
    orderBackground.backgroundColor = [UIColor whiteColor];
    orderBackground.alpha = 0.8f;
    
    self.orderForm = [[UITextView alloc] initWithFrame:CGRectMake(x, 10.0f, width, 220.0f)];
    self.orderForm.delegate = self;
    self.orderForm.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.orderForm.backgroundColor = [UIColor clearColor];
    self.orderForm.text = (self.order.order.length > 1) ? self.order.order : placeholder;
    if (self.order.order.length > 4){ // set 4 as minimum bc 'none' is 4 characters
        self.orderForm.text = self.order.order;
        self.orderForm.textColor = [UIColor grayColor];
    }
    else {
        self.orderForm.text = placeholder;
        self.orderForm.textColor = [UIColor lightGrayColor];
    }
    
    [orderBackground addSubview:self.orderForm];
    [self.theScrollview addSubview:orderBackground];
    y += orderBackground.frame.size.height;
    
    static CGFloat h = 44.0f;
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblAddress.backgroundColor = [UIColor grayColor];
    lblAddress.textAlignment = NSTextAlignmentCenter;
    lblAddress.textColor = [UIColor whiteColor];
    lblAddress.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblAddress.text = @"YOUR ADDRESS";
    [self.theScrollview addSubview:lblAddress];
    y += lblAddress.frame.size.height;

    UIView *addressBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    addressBackground.backgroundColor = [UIColor whiteColor];
    addressBackground.alpha = 0.8f;
    self.addressField = [[UITextField alloc] initWithFrame:CGRectMake(x, 5.0f, width, 34.0f)];
    self.addressField.delegate = self;
    self.addressField.textColor = [UIColor grayColor];
    self.addressField.placeholder = @"Your Address";
    self.addressField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [addressBackground addSubview:self.addressField];
    [self.theScrollview addSubview:addressBackground];
    y += addressBackground.frame.size.height+1.0f;

    UIView *bgTown = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    bgTown.backgroundColor = [UIColor whiteColor];
    bgTown.alpha = 0.8f;
    self.lblTown = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0, frame.size.width-20.0f, h)];
    self.lblTown.backgroundColor = [UIColor clearColor];
    self.lblTown.textColor = [UIColor grayColor];
    self.lblTown.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblTown.text = [self.locationMgr.cities[0] uppercaseString];
    [bgTown addSubview:self.lblTown];
    [self.theScrollview addSubview:bgTown];
    y += bgTown.frame.size.height;

    UILabel *lblPayment = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    lblPayment.backgroundColor = [UIColor grayColor];
    lblPayment.textAlignment = NSTextAlignmentCenter;
    lblPayment.textColor = [UIColor whiteColor];
    lblPayment.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblPayment.text = @"PAYMENT METHOD";
    [self.theScrollview addSubview:lblPayment];
    y += lblPayment.frame.size.height;

    UIButton *btnCash = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCash.tag = 1000;
    btnCash.frame = CGRectMake(0.0f, y, frame.size.width, h);
    btnCash.backgroundColor = [UIColor whiteColor];
    btnCash.alpha = 0.8f;
    [btnCash setTitle:@"CASH" forState:UIControlStateNormal];
    [btnCash setTitleColor:kOrange forState:UIControlStateNormal];
    btnCash.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnCash.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnCash.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [btnCash addTarget:self action:@selector(selectPaymentMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self.theScrollview addSubview:btnCash];
    y += btnCash.frame.size.height+1.0f;

    
    UIButton *btnCredit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCredit.tag = 1001;
    btnCredit.frame = CGRectMake(0.0f, y, frame.size.width, h);
    btnCredit.backgroundColor = [UIColor whiteColor];
    btnCredit.alpha = 0.8f;
    [btnCredit setTitle:@"CREDIT ($1.50 processing fee)" forState:UIControlStateNormal];
    [btnCredit setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnCredit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnCredit.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    btnCredit.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [btnCredit addTarget:self action:@selector(selectPaymentMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self.theScrollview addSubview:btnCredit];
    y += btnCredit.frame.size.height;

    
    UIView *bgOrder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgOrder.backgroundColor = [UIColor grayColor];
    
    UIButton *btnOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOrder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnOrder.frame = CGRectMake(x, 0.5f*(bgOrder.frame.size.height-h), width, h);
    btnOrder.backgroundColor = [UIColor clearColor];
    btnOrder.layer.cornerRadius = 0.5f*h;
    btnOrder.layer.masksToBounds = YES;
    btnOrder.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnOrder.layer.borderWidth = 1.0f;
    [btnOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOrder setTitle:@"SUBMIT ORDER" forState:UIControlStateNormal];
    [btnOrder addTarget:self action:@selector(submitOrder:) forControlEvents:UIControlEventTouchUpInside];
    [bgOrder addSubview:btnOrder];
    [self.theScrollview addSubview:bgOrder];
    y += bgOrder.frame.size.height+44.0f;
    
    [view addSubview:self.theScrollview];
    self.theScrollview.contentSize = CGSizeMake(0, y);

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(exit:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [view addGestureRecognizer:tap];

    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        UIScrollView *scrollview = self.theScrollview;
        CGFloat offset = scrollview.contentOffset.y;
        if (offset < 0){
            self.venueIcon.alpha = 1.0f;
            return;
        }
        
        self.venueIcon.alpha = 1.0f-(offset/100.0f);
        self.lblLocation.alpha = self.venueIcon.alpha;
        
    }
}


- (void)exit:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNavigationTitleView
{
    // override because we actually don't want it in this view
}



- (void)dismissKeyboard
{
    if (self.orderForm.isFirstResponder)
        [self.orderForm resignFirstResponder];

    if (self.addressField.isFirstResponder)
        [self.addressField resignFirstResponder];

}


- (void)submitOrder:(UIButton *)btn
{
    if (self.profile.isPopulated==NO){
        UIAlertView *alert = [self showAlertWithTitle:@"Log In" message:@"Please log in or register to place an order."];
        alert.delegate = self;
        return;
    }
    
    if ([self.currentZone.status isEqualToString:@"open"]==NO){
        [self showAlertWithTitle:@"Not In Service" message:self.currentZone.message];
        return;
    }
    
    if (self.addressField.text.length < 5){
        [self showAlertWithTitle:@"No Address" message:@"Please fill in your address."];
        return;
    }
    
    self.order.address = [NSString stringWithFormat:@"%@, %@", self.addressField.text, self.locationMgr.cities[0]];
    
    UIButton *btnCash = (UIButton *)[self.view viewWithTag:1000];
    if (btnCash.isSelected)
        self.order.paymentType = @"cash";
    
    UIButton *btnCredit = (UIButton *)[self.view viewWithTag:1001];
    if (btnCredit.isSelected)
        self.order.paymentType = @"credit";
    
    self.order.profile = self.profile.uniqueId;
    self.order.order = self.orderForm.text;
    self.order.venue = self.venue;
    self.order.image = self.venue.icon;
    self.order.minDeliveryFee = self.venue.fee;
    if (self.currentZone)
        self.order.orderZone = self.currentZone.uniqueId;

    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] submitOrder:self.order completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.profile.orderHistory)
                [self.profile.orderHistory insertObject:[PCOrder orderWithInfo:results[@"order"]] atIndex:0];
            
            [self showAlertWithTitle:@"Confirmed" message:@"Your order is confirmed. Our driver will text you with the full price and when the food is about to arrive!"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}


- (void)selectPaymentMethod:(UIButton *)btn
{
    UIColor *gray = [UIColor grayColor];

    if (btn.tag==1000){
        [btn setTitleColor:kOrange forState:UIControlStateNormal];
        btn.selected = YES;
        
        UIButton *btnCredit = (UIButton *)[self.view viewWithTag:1001];
        [btnCredit setTitleColor:gray forState:UIControlStateNormal];
        btnCredit.selected = NO;
        return;
    }
    
    if (self.profile.hasCreditCard){
        UIButton *btnCash = (UIButton *)[self.view viewWithTag:1000];
        [btnCash setTitleColor:gray forState:UIControlStateNormal];
        btnCash.selected = NO;

        [btn setTitleColor:kOrange forState:UIControlStateNormal];
        btn.selected = YES;
        return;
    }

    [self addCreditCard];
}


- (void)addCreditCard
{
    if (self.profile.isPopulated==NO){
        [self showAlertWithTitle:@"Log In" message:@"Please log in or register to add a credit card to your profile."];
        [self showLoginView:YES];
        return;
    }
    
    PCCreditCardViewController *creditCardVc = [[PCCreditCardViewController alloc] init];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:creditCardVc];
    navCtr.navigationBar.barTintColor = kLightBlue;
    [self presentViewController:navCtr animated:YES completion:^{
        
    }];
}

- (void)creditCardAdded:(NSNotification *)note
{
    if (self.profile.hasCreditCard==NO)
        return;
    

    UIButton *btnCash = (UIButton *)[self.view viewWithTag:1000];
    [btnCash setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnCash.selected = NO;
    
    UIButton *btnCreditCard = (UIButton *)[self.view viewWithTag:1001];
    [btnCreditCard setTitleColor:kOrange forState:UIControlStateNormal];
    btnCreditCard.selected = YES;
}





#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex == %ld", (long)buttonIndex);
    [self showLoginView:YES]; // not logged in - go to log in / register view controller
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    [self dismissKeyboard];
}

- (void)resetDelegate
{
    self.theScrollview.delegate = self;
//    self.addressField.delegate = self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 280.0f) animated:YES];
//    [self.theScrollview setContentOffset:CGPointMake(0, textField.frame.origin.y+self.orderForm.frame.origin.y+88.0f) animated:YES];
    [self performSelector:@selector(resetDelegate) withObject:nil afterDelay:0.6f];

    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholder]){
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor];
    }
    
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 80.0f) animated:YES];
    [self performSelector:@selector(resetDelegate) withObject:nil afterDelay:0.6f];
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length==0){
        textView.text = placeholder;
        textView.textColor = [UIColor lightGrayColor];
    }
    
//    [self.theScrollview setContentOffset:CGPointMake(0, 0.0f) animated:YES];
    return YES;
}



@end
