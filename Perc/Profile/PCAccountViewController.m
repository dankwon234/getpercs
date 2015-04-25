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
@end

#define kTopInset 220.0f


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
    self.lblName.textAlignment = NSTextAlignmentCenter;
    self.lblName.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblName.text = [NSString stringWithFormat:@"%@ %@", [self.profile.firstName uppercaseString], [self.profile.lastName uppercaseString]];
    [view addSubview:self.lblName];
    y += self.lblName.frame.size.height;
    
    
    self.view = view;
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
    if ([keyPath isEqualToString:@"imageData"]==NO)
        return;
    
    [self.profile removeObserver:self forKeyPath:@"imageData"];
    
    if (self.profile.imageData)
        self.icon.image = self.profile.imageData;
    
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
        
        [[PCWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            if (error) {
                return;
            }

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

- (void)updateProfile
{
    [[PCWebServices sharedInstance] updateProfile:self.profile completionBlock:^(id result, NSError *error){
        if (error) {
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
    }];
}



- (void)uploadImage:(NSString *)uploadUrl
{
    NSDictionary *pkg = @{@"data":UIImageJPEGRepresentation(self.profile.imageData, 0.5f), @"name":@"image.jpg"};
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
            self.profile.image = imageInfo[@"id"];
            self.profile.imageData = nil;
            
            [self updateProfile];
        });
        
    }];
    
}



/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        PCOrder *order = (PCOrder *)object;
        [order removeObserver:self forKeyPath:@"imageData"];
        
        //this is smoother than a conventional reload. it doesn't stutter the UI:
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = (int)[self.profile.orderHistory indexOfObject:order];
            PCVenueCell *cell = (PCVenueCell *)[self.ordersTable cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if (!cell)
                return;
            
            cell.icon.image = order.imageData;
        });
    }
    
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.ordersTable.contentOffset.y;
        if (offset < -kTopInset){
            self.icon.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        self.icon.alpha = 1.0f-(distance/100.0f);
        self.lblName.alpha = self.icon.alpha;
        self.lblOrderHistory.alpha = self.icon.alpha;
    }
}*/

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
