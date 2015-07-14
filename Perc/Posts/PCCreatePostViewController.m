//
//  PCCreatePostViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCCreatePostViewController.h"
#import "PCInviteViewController.h"


@interface PCCreatePostViewController ()
@property (strong, nonatomic) UILabel *lblCreatePost;
@property (strong, nonatomic) UILabel *lblFee;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UIScrollView *theScrollview;
@property (strong, nonatomic) UITextView *contentForm;
@property (strong, nonatomic) UITextField *titleField;
@property (strong, nonatomic) UIImageView *postImage;
@property (strong, nonatomic) UIPickerView *feePicker;
@property (strong, nonatomic) NSMutableArray *fees;
@property (nonatomic) BOOL isEditMode;
@end

static NSString *placeholder = @"Content";

@implementation PCCreatePostViewController
@synthesize post;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.fees = [NSMutableArray array];
        for (int i=0; i<101; i++)
            [self.fees addObject:[NSString stringWithFormat:@"$%d.00", i]];
        
    }
    
    return self;
}


- (void)loadView
{
    if (self.post==nil){
        self.isEditMode = NO;
        self.post = [[PCPost alloc] init];
    }
    else{
        self.isEditMode = YES;
    }
    
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundBlue.png"]];
    CGRect frame = view.frame;
    
    CGFloat dimen = 88.0f;
    self.icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
    self.icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.icon.frame = CGRectMake(0.0f, 0.0f, dimen, dimen);
    self.icon.center = CGPointMake(0.5f*frame.size.width, 0.5f*dimen+84.0f);
    self.icon.layer.cornerRadius = 0.5f*dimen;
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.icon.layer.borderWidth = 1.0f;
    [view addSubview:self.icon];

    
    CGFloat y = self.icon.frame.origin.y+self.icon.frame.size.height+12.0f;
    CGFloat x = 16.0f;
    CGFloat width = frame.size.width-2*x;
    
    self.lblCreatePost = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 20.0f)];
    self.lblCreatePost.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblCreatePost.textColor = [UIColor whiteColor];
    self.lblCreatePost.textAlignment = NSTextAlignmentCenter;
    self.lblCreatePost.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.lblCreatePost.text = (self.isEditMode) ? @"UPDATE POST" : @"CREATE POST";
    [view addSubview:self.lblCreatePost];
    y += self.lblCreatePost.frame.size.height+36.0f;
    
    
    self.theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.theScrollview.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    self.theScrollview.delegate = self;
    self.theScrollview.showsVerticalScrollIndicator = NO;
    [self.theScrollview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    

    static CGFloat h = 44.0f;
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    self.titleField.delegate = self;
    self.titleField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 44.0f)];
    self.titleField.leftViewMode = UITextFieldViewModeAlways;
    self.titleField.backgroundColor = [UIColor whiteColor];
    self.titleField.alpha = 0.8f;
    self.titleField.placeholder = @"Title";
    self.titleField.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    if ([self.post.title isEqualToString:@"none"]==NO && self.post.title.length > 0)
        self.titleField.text = self.post.title;
    
    [self.theScrollview addSubview:self.titleField];
    y += self.titleField.frame.size.height+1.0f;

    
    UIView *bgContent = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 240.0f)];
    bgContent.backgroundColor = [UIColor whiteColor];
    bgContent.alpha = 0.8f;
    
    self.contentForm = [[UITextView alloc] initWithFrame:CGRectMake(x, 10.0f, width, 220.0f)];
    self.contentForm.delegate = self;
    self.contentForm.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.contentForm.backgroundColor = [UIColor clearColor];
    self.contentForm.text = (self.post.content.length > 1) ? self.post.content : placeholder;
    if (self.post.content.length > 4){
        self.contentForm.text = self.post.content;
        self.contentForm.textColor = [UIColor darkGrayColor];
    }
    else {
        self.contentForm.text = placeholder;
        self.contentForm.textColor = [UIColor lightGrayColor];
    }
    
    [bgContent addSubview:self.contentForm];
    [self.theScrollview addSubview:bgContent];
    y += bgContent.frame.size.height+1.0f;
    
    UIView *bgPublic = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    bgPublic.backgroundColor = [UIColor whiteColor];
    bgPublic.alpha = 0.8f;
    
    UILabel *lblPublic = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, frame.size.width-24.0f, h)];
    lblPublic.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblPublic.text = @"Public";
    [bgPublic addSubview:lblPublic];
    
    UISwitch *togglePublic = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width-63.0f, 6.5f, 51.0f, 31.0)];
    togglePublic.on = (self.isEditMode) ? self.post.isPublic : YES;
    [togglePublic addTarget:self action:@selector(togglePublic:) forControlEvents:UIControlEventValueChanged];
    [bgPublic addSubview:togglePublic];
    
    [self.theScrollview addSubview:bgPublic];
    y += bgPublic.frame.size.height+1.0f;

    UIView *bgFee = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
    bgFee.backgroundColor = [UIColor whiteColor];
    [bgFee addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeFee:)]];
    bgFee.alpha = 0.8f;
    
    self.lblFee = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, frame.size.width-24.0f, 44.0f)];
    self.lblFee.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblFee.text = @"Fee: FREE";
    [bgFee addSubview:self.lblFee];

    [self.theScrollview addSubview:bgFee];
    y += bgFee.frame.size.height+1.0f;
    
    if (self.isEditMode){
        UIView *bgVisible = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
        bgVisible.backgroundColor = [UIColor whiteColor];
        bgVisible.alpha = 0.8f;
        
        UILabel *lblVisible = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, frame.size.width-24.0f, h)];
        lblVisible.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        lblVisible.text = @"Visible";
        [bgVisible addSubview:lblVisible];
        
        UISwitch *toggleVisible = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width-63.0f, 6.5f, 51.0f, 31.0)];
        toggleVisible.on = self.post.isVisible;
        [toggleVisible addTarget:self action:@selector(toggleVisibility:) forControlEvents:UIControlEventValueChanged];
        [bgVisible addSubview:toggleVisible];
        
        [self.theScrollview addSubview:bgVisible];
        y += bgVisible.frame.size.height+1.0f;
    }


    UIView *bgImage = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 2*h)];
    bgImage.backgroundColor = [UIColor whiteColor];
    bgImage.alpha = 0.8f;
    [bgImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)]];
    
    dimen = bgImage.frame.size.height-20.0f;
    self.postImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, dimen, dimen)];
    self.postImage.layer.borderWidth = 1.0f;
    self.postImage.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.postImage.backgroundColor = [UIColor lightGrayColor];
    self.postImage.image = (self.post.imageData) ? self.post.imageData : [UIImage imageNamed:@"iconCamera.png"];
    self.post.imageData = nil; // have to nil this out so the update function won't upload image unnecesarily
    [bgImage addSubview:self.postImage];
    
    [self.theScrollview addSubview:bgImage];
    y += bgImage.frame.size.height;

    if (self.isEditMode==NO){
        UILabel *lblZone = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, h)];
        lblZone.backgroundColor = [UIColor grayColor];
        lblZone.textAlignment = NSTextAlignmentCenter;
        lblZone.textColor = [UIColor whiteColor];
        lblZone.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        lblZone.text = @"This Post Will Show In";
        [self.theScrollview addSubview:lblZone];
        y += lblZone.frame.size.height;
        
        
        NSString *towns = @"";
        for (int i=0; i<self.currentZone.towns.count; i++) {
            NSString *town = [self.currentZone.towns[i] capitalizedString];
            towns = [towns stringByAppendingString:town];
            if (i != self.currentZone.towns.count-1)
                towns = [towns stringByAppendingString:@", "];
        }
        
        CGRect boundingRect = [towns boundingRectWithSize:CGSizeMake(width, 200.0f)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:16.0f]}
                                                  context:nil];
        
        CGFloat height = (boundingRect.size.height > h) ? boundingRect.size.height+24.0f : h;
        UIView *bgTowns = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, height)];
        bgTowns.backgroundColor = [UIColor whiteColor];
        bgTowns.alpha = 0.8f;
        
        UILabel *lblTowns = [[UILabel alloc] initWithFrame:CGRectMake(x, 0.0f, width, height)];
        lblTowns.text = towns;
        lblTowns.textColor = [UIColor grayColor];
        lblTowns.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        lblTowns.lineBreakMode = NSLineBreakByWordWrapping;
        lblTowns.numberOfLines = 0;
        [bgTowns addSubview:lblTowns];
        
        [self.theScrollview addSubview:bgTowns];
        y += bgTowns.frame.size.height;
    }


    

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
    NSString *btnTitle = (self.isEditMode) ? @"UPDATE POST" : @"CREATE POST";
    [btnCreate setTitle:btnTitle forState:UIControlStateNormal];
    [btnCreate addTarget:self action:@selector(createPost:) forControlEvents:UIControlEventTouchUpInside];
    [bgCreate addSubview:btnCreate];
    [self.theScrollview addSubview:bgCreate];
    y += bgCreate.frame.size.height;
    
    
    [view addSubview:self.theScrollview];
    self.theScrollview.contentSize = CGSizeMake(0, y);
    
    self.feePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, 180.0f)];
    self.feePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.feePicker.dataSource = self;
    self.feePicker.delegate = self;
    self.feePicker.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.feePicker];
    
    
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
            self.icon.alpha = 1.0f;
            return;
        }
        
        self.icon.alpha = 1.0f-(offset/100.0f);
        self.lblCreatePost.alpha = self.icon.alpha;
    }
}





- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissKeyboard
{
    if (self.contentForm.isFirstResponder)
        [self.contentForm resignFirstResponder];
    
    if (self.titleField.isFirstResponder)
        [self.titleField resignFirstResponder];
}

- (void)createPost:(UIButton *)btn
{
    NSLog(@"createPost: ");

    if (self.titleField.text.length==0){
        [self showAlertWithTitle:@"Missing Title" message:@"Please enter a title for your post."];
        return;
    }

    if (self.contentForm.text.length==0){
        [self showAlertWithTitle:@"Missing Content" message:@"Please enter you post content."];
        return;
    }
    
    // populate profile stuff:
    self.post.title = self.titleField.text;
    self.post.content = self.contentForm.text;
    self.post.profile = self.profile;
    if (self.isEditMode==NO)
        [self.post.zones addObject:self.currentZone.uniqueId];
    
    
    if (self.post.isPublic==NO){ // private post - segue to invite view controller
        PCInviteViewController *inviteVc = [[PCInviteViewController alloc] init];
        inviteVc.post = self.post;
        [self.navigationController pushViewController:inviteVc animated:YES];
        return;
    }
    
    [self.loadingIndicator startLoading];
    if (self.post.imageData){
        [[PCWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            if (error){ // remove image and submit post
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.post.imageData = nil;
                    [self createPost:nil];
                });
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            [self uploadImage:results[@"upload"]];
        }];
        
        return;
    }
    
    
    if (self.isEditMode){
        [[PCWebServices sharedInstance] updatePost:self.post incrementView:NO completion:^(id result, NSError *error){
            [self.loadingIndicator stopLoading];
            if (error){
                [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            [self.post populate:results[@"post"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPostUpdatedNotification object:nil]];
                [self showAlertWithTitle:@"Post Updated!" message:@"Your post has been updated."];
            });
        }];
        
        return;
    }

    [[PCWebServices sharedInstance] createPost:self.post completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        [self.post populate:results[@"post"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPostCreatedNotification object:nil userInfo:@{@"post":self.post}]];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}


- (void)uploadImage:(NSString *)uploadUrl
{
    NSDictionary *pkg = @{@"data":UIImageJPEGRepresentation(self.post.imageData, 0.5f), @"name":@"image.jpg"};
    [[PCWebServices sharedInstance] uploadImage:pkg toUrl:uploadUrl completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *imageInfo = results[@"image"];
            self.post.image = imageInfo[@"id"];
            self.post.imageData = nil;
            
            [self createPost:nil];
        });
    }];
}


- (void)changeFee:(UIGestureRecognizer *)tap
{
    NSLog(@"changeFee: ");
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.feePicker.frame;
                         frame.origin.y = self.view.frame.size.height-frame.size.height;
                         self.feePicker.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
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

- (void)togglePublic:(UISwitch *)toggleSwitch
{
    NSLog(@"togglePublic: %@", (toggleSwitch.on) ? @"yes" : @"no");
    self.post.isPublic = toggleSwitch.on;
}

- (void)toggleVisibility:(UISwitch *)toggleSwitch
{
    NSLog(@"toggleVisibility: %@", (toggleSwitch.on) ? @"yes" : @"no");
    self.post.isVisible = toggleSwitch.on;
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


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.fees.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.fees[row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.post.fee = (int)row;
    self.lblFee.text = (row==0) ? @"Fee: FREE" : [NSString stringWithFormat:@"Fee: %@", self.fees[row]];
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.feePicker.frame;
                         frame.origin.y = self.view.frame.size.height;
                         self.feePicker.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.theScrollview.delegate = nil;
    [self.theScrollview setContentOffset:CGPointMake(0, 80.0f) animated:YES];
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
    
    self.postImage.image = image;
    self.post.imageData = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
