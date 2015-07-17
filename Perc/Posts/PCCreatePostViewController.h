//
//  PCCreatePostViewController.h
//  Perc
//
//  Created by Dan Kwon on 4/17/15.
//  Copyright (c) 2015 Perc. All rights reserved.
//

#import "PCViewController.h"
#import "PCPost.h"

@interface PCCreatePostViewController : PCViewController <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) BOOL isEvent;
@property (strong, nonatomic) PCPost *post;
@end
