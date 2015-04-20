//
//  PCPostViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostViewController.h"
#import "PCConnectViewController.h"

@interface PCPostViewController ()
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UITableView *theTableview;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblContent;
@property (strong, nonatomic) UITextField *commentField;
@end

@implementation PCPostViewController
@synthesize post;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardAppearNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        
    }
    return self;
}

- (void)dealloc
{
    [self.theTableview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    if (self.post.imageData){
        CGFloat width = frame.size.width;
        double scale = width/self.post.imageData.size.width;
        CGFloat height = scale*self.post.imageData.size.height;
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
        self.backgroundImage.image = self.post.imageData;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        CGRect bounds = self.backgroundImage.bounds;
        bounds.size.height *= 0.6f;
        gradient.frame = bounds;
        gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f] CGColor], (id)[[UIColor clearColor] CGColor]];
        [self.backgroundImage.layer insertSublayer:gradient atIndex:0];

        [view addSubview:self.backgroundImage];
    }
    
    UIFont *boldFont = [UIFont fontWithName:kBaseFontName size:22.0f];
    CGFloat w = frame.size.width-40.0f;
    CGRect boundingRect = [self.post.title boundingRectWithSize:CGSizeMake(w, 60)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:boldFont}
                                                        context:nil];
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, w, boundingRect.size.height)];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.numberOfLines = 2;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.font = boldFont;
    self.lblTitle.text = self.post.title;
    [view addSubview:self.lblTitle];
    
    self.theTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f)];
    self.theTableview.dataSource = self;
    self.theTableview.delegate = self;
    self.theTableview.backgroundColor = [UIColor clearColor];
    self.theTableview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.theTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.theTableview addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    
    CGFloat width = frame.size.width-40.0f;
    UIFont *baseFont = [UIFont fontWithName:kBaseFontName size:16.0f];
    boundingRect = [self.post.content boundingRectWithSize:CGSizeMake(width, 800.0f)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:baseFont}
                                                   context:nil];
    
//    NSLog(@"HEIGHT: %.2f", boundingRect.size.height);

    CGFloat h = (boundingRect.size.height < 98.0f) ? 400.0f : boundingRect.size.height+302.0f;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, h)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgPost.png"]];
    
    self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 175.0f, frame.size.width-20.0f, 22.0f)];
    self.lblDate.textColor = kOrange;
    self.lblDate.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.lblDate.textAlignment = NSTextAlignmentRight;
    self.lblDate.text = self.post.formattedDate;
    [header addSubview:self.lblDate];
    
    self.lblContent = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 220.0f, width, boundingRect.size.height)];
    self.lblContent.numberOfLines = 0;
    self.lblContent.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblContent.font = baseFont;
    self.lblContent.textColor = [UIColor darkGrayColor];
    self.lblContent.text = self.post.content;
    [header addSubview:self.lblContent];
    self.theTableview.tableHeaderView = header;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 44.0f)];
    footer.backgroundColor = [UIColor lightGrayColor];
    
    self.commentField = [[UITextField alloc] initWithFrame:CGRectMake(6.0f, 6.0f, frame.size.width-100.0f, footer.frame.size.height-12.0f)];
    self.commentField.delegate = self;
    self.commentField.backgroundColor = [UIColor whiteColor];
    self.commentField.alpha = 0.85f;
    self.commentField.layer.cornerRadius = 2.0f;
    self.commentField.layer.masksToBounds = YES;
    self.commentField.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    self.commentField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 6.0f, self.commentField.frame.size.height)];
    self.commentField.leftViewMode = UITextFieldViewModeAlways;
    self.commentField.textColor = [UIColor darkGrayColor];
    [footer addSubview:self.commentField];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSend.frame = CGRectMake(frame.size.width-106.0f, footer.frame.size.height-28.0f, 100.0f, 22.0f);
    [btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    btnSend.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    btnSend.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [footer addSubview:btnSend];
    self.theTableview.tableFooterView = footer;
    
    
    [view addSubview:self.theTableview];

    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    [[PCWebServices sharedInstance] updatePost:self.post incrementView:YES completion:^(id result, NSError *error){
        if (error)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            [self.post populate:results[@"post"]];
        });
        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]==NO)
        return;
    
    CGFloat offset = self.theTableview.contentOffset.y;
    if (offset > 220.0f)
        return;
    
    if (offset > 0){ // moving up - shift image up. 0 to 220.
        CGRect frame = self.backgroundImage.frame;
        frame.origin.y = -0.4f*offset;
        if (frame.origin.y > 0.0f)
            frame.origin.y = 0.0f;
        
        self.backgroundImage.frame = frame;
        return;
    }
    
    
    double magnitude = -0.01f*offset+1.0f;
    self.backgroundImage.transform = CGAffineTransformMakeScale(magnitude, magnitude);
}


- (void)back:(UIGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardAppearNotification:(NSNotification *)note
{
//    NSLog(@"keyboardAppearNotification: %@", [note.userInfo description]);
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self shiftUp:keyboardFrame.size.height-kNavBarHeight];
}

- (void)keyboardHideNotification:(NSNotification *)note
{
//    NSLog(@"keyboardHideNotification: %@", [note.userInfo description]);
    [self shiftBack:kNavBarHeight];
}




#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    if (self.commentField.isFirstResponder)
        [self.commentField resignFirstResponder];
}


#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return nil;
    
    return @"Comments";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return 3;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        static NSString *cellId = @"cellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGFloat rgb = 235.0f/255.0f;
            cell.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0f];
        }
        
        if (indexPath.row==2){
            cell.textLabel.textColor = kOrange;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"iconEnvelope.png"];
            cell.textLabel.text = @"REPLY";
        }
        else{
            cell.textLabel.textColor = kLightBlue;
            cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if (indexPath.row==0){
                cell.imageView.image = [UIImage imageNamed:@"iconView.png"];
                cell.textLabel.text = [NSString stringWithFormat:@"%d Views", self.post.numViews];
                
            }
            else{
                cell.imageView.image = [UIImage imageNamed:@"iconComment.png"];
                cell.textLabel.text = [NSString stringWithFormat:@"%d Comments", self.post.numComments];
            }

        }

        return cell;
    }
    
    static NSString *commentCellId = @"commentCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Comment %d", (int)indexPath.row];
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
        return;

    
    if (indexPath.row != 2)
        return;
    
    PCConnectViewController *connectVc = [[PCConnectViewController alloc] init];
    connectVc.post = self.post;
    [self.navigationController pushViewController:connectVc animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
