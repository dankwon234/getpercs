//
//  PCAccountViewController.m
//  Perc
//
//  Created by Dan Kwon on 3/20/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCAccountViewController.h"
#import "PCCollectionViewFlowLayout.h"
#import "PCOrderViewController.h"
#import "PCVenueCell.h"

@interface PCAccountViewController ()
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UILabel *lblName;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextView *bioTextView;
@end

#define kTopInset 0.0f
static NSString *placeholder = @"Bio";

@implementation PCAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgBurger.png"]];
    CGRect frame = view.frame;
    
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    self.icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.icon.center = CGPointMake(0.5f*frame.size.width, 88.0f);
    self.icon.layer.cornerRadius = 0.5f*self.icon.frame.size.height;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.borderWidth = 1.0f;
    self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.icon.userInteractionEnabled = YES;
    [self.icon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)]];
    [view addSubview:self.icon];
    CGFloat y = self.icon.frame.origin.y+self.icon.frame.size.height+16.0f;
    
    self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, frame.size.width-40.0f, 22.0f)];
    self.lblName.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblName.textAlignment = NSTextAlignmentCenter;
    self.lblName.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblName.text = [NSString stringWithFormat:@"%@ %@", [self.profile.firstName uppercaseString], [self.profile.lastName uppercaseString]];
    [view addSubview:self.lblName];
    y += self.lblName.frame.size.height+24.0f;
    
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.delegate = self;
    self.theScrollview.showsVerticalScrollIndicator = NO;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    static CGFloat h = 44.0f;
    self.firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    self.firstNameField.delegate = self;
    self.firstNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 44.0f)];
    self.firstNameField.leftViewMode = UITextFieldViewModeAlways;
    self.firstNameField.backgroundColor = [UIColor whiteColor];
    self.firstNameField.alpha = 0.8f;
    self.firstNameField.placeholder = @"First Name";
    self.firstNameField.textColor = [UIColor darkGrayColor];
    self.firstNameField.text = ([self.profile.firstName isEqualToString:@"none"]) ? @"" : self.profile.firstName;
    self.firstNameField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.theScrollview addSubview:self.firstNameField];
    y += h+1.0f;

    self.lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    self.lastNameField.delegate = self;
    self.lastNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 44.0f)];
    self.lastNameField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameField.backgroundColor = [UIColor whiteColor];
    self.lastNameField.alpha = 0.8f;
    self.lastNameField.placeholder = @"Last Name";
    self.lastNameField.textColor = [UIColor darkGrayColor];
    self.lastNameField.text = ([self.profile.lastName isEqualToString:@"none"]) ? @"" : self.profile.lastName;
    self.lastNameField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [self.theScrollview addSubview:self.lastNameField];
    y += h+1.0f;

    
    
    UIView *bgBio = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 260.0f)];
    bgBio.backgroundColor = [UIColor whiteColor];
    bgBio.alpha = 0.8f;
    
    CGFloat x = 12.0f;
    CGFloat width = frame.size.width-2*x;

    self.bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(x, 10.0f, width, bgBio.frame.size.height-20.0f)];
    self.bioTextView.delegate = self;
    self.bioTextView.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.bioTextView.backgroundColor = [UIColor clearColor];
    if (self.profile.bio.length > 4){ // set 4 as minimum bc 'none' is 4 characters
        self.bioTextView.text = self.profile.bio;
        self.bioTextView.textColor = [UIColor darkGrayColor];
    }
    else {
        self.bioTextView.text = placeholder;
        self.bioTextView.textColor = [UIColor lightGrayColor];
    }
    
    [bgBio addSubview:self.bioTextView];
    [self.theScrollview addSubview:bgBio];
    y += bgBio.frame.size.height;

    UIView *bgUpdate = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgUpdate.backgroundColor = [UIColor grayColor];
    
    UIButton *btnUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpdate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnUpdate.frame = CGRectMake(x, 0.5f*(bgUpdate.frame.size.height-h), width, h);
    btnUpdate.backgroundColor = [UIColor clearColor];
    btnUpdate.layer.cornerRadius = 0.5f*h;
    btnUpdate.layer.masksToBounds = YES;
    btnUpdate.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnUpdate.layer.borderWidth = 1.0f;
    [btnUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnUpdate setTitle:@"UPDATE" forState:UIControlStateNormal];
    [btnUpdate addTarget:self action:@selector(updateProfile:) forControlEvents:UIControlEventTouchUpInside];
    [bgUpdate addSubview:btnUpdate];
    [self.theScrollview addSubview:bgUpdate];
    y += bgUpdate.frame.size.height+h;

    self.theScrollview.contentSize = CGSizeMake(0, y);
    
    [view addSubview:self.theScrollview];
    [view bringSubviewToFront:self.icon];
    
    self.view = view;
}

- (void)dealloc
{
    [self.theScrollview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    UIBarButtonItem *btnLogout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(logout:)];
    self.navigationItem.rightBarButtonItem = btnLogout;
    
    if ([self.profile.image isEqualToString:@"none"])
        return;
    
    
    if (self.profile.imageData){
        self.icon.image = self.profile.imageData;
        return;
    }
    
    [self.profile addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [self.profile fetchImage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        [self.profile removeObserver:self forKeyPath:@"imageData"];
        
        if (self.profile.imageData)
            self.icon.image = self.profile.imageData;
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.theScrollview.contentOffset.y;
        if (offset < -kTopInset){
            self.icon.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        self.icon.alpha = 1.0f-(distance/100.0f);
        self.lblName.alpha = self.icon.alpha;
    }
    
}


- (void)selectImage:(UIGestureRecognizer *)tap
{
    //    NSLog(@"selectImage: ");
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
    actionsheet.frame = CGRectMake(0, 150.0f, self.view.frame.size.width, 100.0f);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)launchImageSelector:(UIImagePickerControllerSourceType)sourceType
{
    [self.loadingIndicator startLoading];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.loadingIndicator stopLoading];
    }];
    
}

- (void)dismissKeyboard
{
    if (self.bioTextView.isFirstResponder)
        [self.bioTextView resignFirstResponder];
    
    if (self.firstNameField.isFirstResponder)
        [self.firstNameField resignFirstResponder];
    
    if (self.lastNameField.isFirstResponder)
        [self.lastNameField resignFirstResponder];

}

- (void)resetDelegate
{
    self.theScrollview.delegate = self;
}


- (void)updateProfile:(UIButton *)btn
{
    if (self.firstNameField.text.length==0){
        [self showAlertWithTitle:@"Missing First Name" message:@"Please enter your first name."];
        return;
    }
    
    if (self.lastNameField.text.length==0){
        [self showAlertWithTitle:@"Missing Last Name" message:@"Please enter your last name."];
        return;
    }
    
    self.profile.firstName = self.firstNameField.text;
    self.profile.lastName = self.lastNameField.text;
    self.profile.bio = self.bioTextView.text;
    
    [self.loadingIndicator startLoading];
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] updateProfile:self.profile completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error) {
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            [self showAlertWithTitle:@"Profile Updated" message:@"Your profile has been updated."];
            self.lblName.text = [NSString stringWithFormat:@"%@ %@", [self.profile.firstName uppercaseString], [self.profile.lastName uppercaseString]];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kProfileUpdatedNotification object:nil]];
        });
        
    }];
}



#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholder]){
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor];
    }
    
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 124.0f) animated:YES];
    [self performSelector:@selector(resetDelegate) withObject:nil afterDelay:0.6f];
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length==0){
        textView.text = placeholder;
        textView.textColor = [UIColor lightGrayColor];
    }
    
    return YES;
}





#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    [self dismissKeyboard];
}



#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex==0){
        [self launchImageSelector:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if (buttonIndex==1){
        [self launchImageSelector:UIImagePickerControllerSourceTypeCamera];
    }
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: didFinishPickingMediaWithInfo: %@", [info description]);
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (w != h){
        CGFloat dimen = (w < h) ? w : h;
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0.5*(image.size.width-dimen), 0.5*(image.size.height-dimen), dimen, dimen));
        image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.5f)];
        CGImageRelease(imageRef);
    }
    
    self.profile.imageData = image;
    self.icon.image = self.profile.imageData;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self.loadingIndicator startLoading];
        [[PCWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            if (error)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *results = (NSDictionary *)result;
                NSLog(@"%@", [results description]);
                [self uploadImage:results[@"upload"]];
            });
        }];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


- (void)uploadImage:(NSString *)uploadUrl
{
    NSDictionary *pkg = @{@"data":UIImageJPEGRepresentation(self.profile.imageData, 0.5f), @"name":@"image.jpg"};
    [[PCWebServices sharedInstance] uploadImage:pkg toUrl:uploadUrl completion:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *imageInfo = results[@"image"];
            self.profile.image = imageInfo[@"id"];
            self.profile.imageData = nil;
            
            [self updateProfile:nil];
        });
        
    }];
    
}




- (void)logout:(id)sender
{
    [self.profile clear];
    [self back:nil];
}


- (void)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}






@end
