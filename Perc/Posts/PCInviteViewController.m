//
//  PCInviteViewController.m
//  Perc
//
//  Created by Dan Kwon on 5/28/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCInviteViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PCContactCell.h"


@interface PCInviteViewController ()
@property (strong, nonatomic) UITableView *contactsTable;
@property (strong, nonatomic) NSMutableArray *contactList;
@end

@implementation PCInviteViewController
@synthesize post;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.contactList = [NSMutableArray array];
        
    }
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    
    self.contactsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    self.contactsTable.dataSource = self;
    self.contactsTable.delegate = self;
    self.contactsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.contactsTable.showsVerticalScrollIndicator = NO;
    self.contactsTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.contactsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 96.0f)];
    self.contactsTable.contentInset = UIEdgeInsetsMake(180.0f, 0, 0, 0);
    self.contactsTable.backgroundColor = [UIColor clearColor];
    [view addSubview:self.contactsTable];
    
    
    
    CGFloat y = frame.size.height-96.f;
    CGFloat h = 44.0f;
    CGFloat x = 16.0f;
    CGFloat width = frame.size.width-2*x;

    UIView *bgCreate = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 96.0f)];
    bgCreate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
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
//    NSString *btnTitle = (self.isEditMode) ? @"UPDATE POST" : @"CREATE POST";
    [btnCreate setTitle:@"CREATE POST" forState:UIControlStateNormal];
    [btnCreate addTarget:self action:@selector(createPost:) forControlEvents:UIControlEventTouchUpInside];
    [bgCreate addSubview:btnCreate];
    [view addSubview:bgCreate];
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    [self requestAddresBookAccess];
}

- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createPost:(UIButton *)btn
{
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
//            NSLog(@"%@", [results description]);
            [self uploadImage:results[@"upload"]];
        }];
        
        return;
    }

    NSDictionary *host = @{@"fullName":[NSString stringWithFormat:@"%@ %@", self.profile.firstName, self.profile.lastName] , @"firstName":self.profile.firstName, @"lastName":self.profile.lastName, @"phoneNumber":self.profile.phone};
    [self.post.invited addObject:host];
    [self.post.confirmed addObject:host];
    
    self.post.type = @"event"; // private posts default as events for now
    self.post.isVisible = NO; // private posts are not visible to everyone
    
    NSLog(@"createPost: %@", [self.post jsonRepresentation]);

    
    [[PCWebServices sharedInstance] createPost:self.post completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        [self.post populate:results[@"post"]];
        
        if (self.profile.invited==nil)
            self.profile.invited = [NSMutableArray array];
        
        [self.profile.invited insertObject:self.post atIndex:0];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPostCreatedNotification object:nil userInfo:@{@"post":self.post}]];
            
            NSArray *viewControllers = [self.navigationController viewControllers];
            [self.navigationController popToViewController:viewControllers[1] animated:YES];
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



//search for beginning of first or last name, have search work for only prefixes
- (void)requestAddresBookAccess//call to get address book, latency
{;
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (error) {
        //        NSLog(@"Address book error: %@", [nsError localizedDescription]);
        [self showAlertWithTitle:@"Contact List Unauthorized" message:@"Please go to the settings app and allow PERC to access your address book to request references."];
        return;
    }
    
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        if (!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                //                NSLog(@"Address book access denied");
                [self showAlertWithTitle:@"Contact List Unauthorized" message:@"Please go to the settings app and allow PERC to access your address book to request references."];
                return;
            });
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"Address book access granted");
            [self parseContactsList:addressBook];
        });
    });
}



- (void)parseContactsList:(ABAddressBookRef)addressBook
{
    //    NSLog(@"Address book access granted");
    static NSString *numbers = @"0123456789";
    NSMutableArray *added = [NSMutableArray array];

    NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (int i=0; i<allContacts.count; i++) {
        ABRecordRef contact = (__bridge ABRecordRef)allContacts[i];
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty);
        
        // phone:
        ABMultiValueRef phones = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        NSString *phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
        
        BOOL enoughInfo = NO;
        if (firstName != nil && phoneNumber != nil)
            enoughInfo = YES;
        
        if (enoughInfo==NO)
            continue;
        
        
        NSMutableDictionary *contactInfo = [NSMutableDictionary dictionary];
        contactInfo[@"firstName"] = [firstName lowercaseString];
        
        NSString *formattedNumber = @"";
        for (int i=0; i<phoneNumber.length; i++) {
            NSString *character = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
            if ([numbers rangeOfString:character].location != NSNotFound){
                formattedNumber = [formattedNumber stringByAppendingString:character];
                
                NSString *firstNum = [formattedNumber substringWithRange:NSMakeRange(0, 1)];
                if ([firstNum isEqualToString:@"1"])
                    formattedNumber = [formattedNumber substringFromIndex:1];
            }
        }
        
        if ([formattedNumber isEqualToString:self.profile.phone]) // this is the user's phone - ignore
            continue;
        
        
        contactInfo[@"phoneNumber"] = formattedNumber;
        
        // email:
        ABMultiValueRef emails = ABRecordCopyValue(contact, kABPersonEmailProperty);
        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
        if (email)
            contactInfo[@"email"] = email;
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty);
        if (lastName){
            contactInfo[@"lastName"] = [lastName lowercaseString];
            contactInfo[@"fullName"] = [[[NSString stringWithFormat:@"%@ %@", firstName, lastName] lowercaseString] capitalizedString];
        }
        else{
            contactInfo[@"fullName"] = [[firstName lowercaseString] capitalizedString];
        }
        
        NSString *fullName = contactInfo[@"fullName"];
        if ([added containsObject:fullName]==YES) // it's already there
            continue;
        
        [added addObject:fullName];
        [self.contactList addObject:contactInfo]; // add contact to full contact list
    }
    
    CFRelease(addressBook);
    
    // alphabetize the contact list
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    [self.contactList sortUsingDescriptors:@[descriptor]];
    
    [self.contactsTable reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.contactList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PCContactCell *cell = (PCContactCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[PCContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *contactInfo = self.contactList[indexPath.row];
    cell.lblName.text = contactInfo[@"fullName"];
    cell.imgCheckmark.image = ([self.post.invited containsObject:contactInfo]) ? [UIImage imageNamed:@"iconCheckmark.png"] : nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *contactInfo = self.contactList[indexPath.row];
    if ([self.post.invited containsObject:contactInfo]){
        [self.post.invited removeObject:contactInfo];
        [self.contactsTable reloadData];
        return;
    }
    
    [self.post.invited addObject:contactInfo];
    [self.contactsTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PCContactCell standardCellHeight];
}


@end
