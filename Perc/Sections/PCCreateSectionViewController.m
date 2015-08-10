//
//  PCCreateSectionViewController.m
//  Perc
//
//  Created by Dan Kwon on 8/9/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCCreateSectionViewController.h"
#import "PCSection.h"

@interface PCCreateSectionViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UIImageView *sectionImage;
@property (strong, nonatomic) PCSection *section;
@end

@implementation PCCreateSectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.section = [[PCSection alloc] init];
        
    }
    
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLights.png"]];
    CGRect frame = view.frame;
    
    CGFloat x = 24.0f;
    CGFloat y = 110.0f;
    CGFloat width = frame.size.width;
    
    UILabel *lblCreate = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblCreate.textColor = [UIColor whiteColor];
    lblCreate.textAlignment = NSTextAlignmentCenter;
    lblCreate.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblCreate.text = @"Create Section";
    [view addSubview:lblCreate];
    y += lblCreate.frame.size.height+32.0f;
    
    
    CGFloat h = 44.0f;
    x = 36.0f;
    
    UIColor *white = [UIColor whiteColor];
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, y, width, 44.0f)];
    self.nameField.delegate = self;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, x, h)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.backgroundColor = [UIColor clearColor];
    self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Section Name" attributes:@{ NSForegroundColorAttributeName : white }];
    self.nameField.alpha = 0.8f;
    self.nameField.textColor = [UIColor darkGrayColor];
    self.nameField.placeholder = @"Section Name";
    self.nameField.returnKeyType = UIReturnKeyNext;
    self.nameField.font = [UIFont fontWithName:kBaseFontName size:14.0];
    self.nameField.textColor = white;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, h-6.0f, width-2*x, 1.0f)];
    line.backgroundColor = white;
    [self.nameField addSubview:line];
    
    [view addSubview:self.nameField];
    y += self.nameField.frame.size.height+8.0f;
    
    CGFloat dimen = 72.0f;
    self.sectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, dimen, dimen)];
    self.sectionImage.image = [UIImage imageNamed:@"icon.png"];
    self.sectionImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.sectionImage.layer.borderWidth = 2.0f;
    self.sectionImage.userInteractionEnabled = YES;
    [self.sectionImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)]];
    [view addSubview:self.sectionImage];
    
    UILabel *tapToChange = [[UILabel alloc] initWithFrame:CGRectMake(x+dimen+6.0f, y, frame.size.width, 16.0f)];
    tapToChange.center = CGPointMake(tapToChange.center.x, self.sectionImage.center.y);
    tapToChange.textColor = [UIColor whiteColor];
    tapToChange.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    tapToChange.text = @"Tap Icon to Change Section Image";
    [view addSubview:tapToChange];
    
    y += self.sectionImage.frame.size.height+24.0f;
    
    
    UIButton *btnCreate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCreate.frame = CGRectMake(x, y, width-2*x, h);
    btnCreate.backgroundColor = [UIColor clearColor];
    btnCreate.layer.cornerRadius = 0.5f*h;
    btnCreate.layer.masksToBounds = YES;
    btnCreate.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnCreate.layer.borderWidth = 2.0f;
    [btnCreate setTitle:@"Create" forState:UIControlStateNormal];
    [btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCreate.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [btnCreate addTarget:self action:@selector(createSection:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCreate];


    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];

    [self addSwipeBackGesture:view];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];

}


- (void)createSection:(UIButton *)btn
{
    NSLog(@"createSection: ");
    
    if (self.nameField.text.length==0){
        [self showAlertWithTitle:@"Missing Name" message:@"Please enter a name for the section."];
        return;
    }
    
    [self.loadingIndicator startLoading];
    if (self.section.imageData){
        [[PCWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            if (error){ // remove image and submit section
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.section.imageData = nil;
                    [self createSection:nil];
                });
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            [self uploadImage:results[@"upload"]];
        }];
        
        return;
    }
    
    self.section.name = self.nameField.text;
    self.section.zone = self.currentZone.uniqueId;
    [self.section.moderators addObject:self.profile.uniqueId];
    
    [[PCWebServices sharedInstance] createSection:self.section completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        [self.section populate:results[@"section"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.currentZone.sections insertObject:self.section atIndex:0];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        
    }];
}

- (void)uploadImage:(NSString *)uploadUrl
{
    NSDictionary *pkg = @{@"data":UIImageJPEGRepresentation(self.section.imageData, 0.5f), @"name":@"image.jpg"};
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
            self.section.image = imageInfo[@"id"];
            self.section.imageData = nil;
            
            [self createSection:nil];
        });
    }];
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


- (void)selectImage:(UIGestureRecognizer *)tap
{
    //    NSLog(@"selectImage: ");
    [self dismissKeyboard];
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
    actionsheet.frame = CGRectMake(0, 150.0f, self.view.frame.size.width, 100.0f);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)dismissKeyboard
{
    [self.nameField resignFirstResponder];
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
    
    self.section.imageData = image;
    self.sectionImage.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}







@end
