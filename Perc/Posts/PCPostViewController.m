//
//  PCPostViewController.m
//  Perc
//
//  Created by Dan Kwon on 4/18/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCPostViewController.h"
#import "PCConnectViewController.h"
#import "PCComment.h"

@interface PCPostViewController ()
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UITableView *theTableview;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblContent;
@property (strong, nonatomic) UITextField *commentField;
@property (strong, nonatomic) PCComment *nextComment;
@property (strong, nonatomic) UIImageView *fullImage;
@property (strong, nonatomic) UIScrollView *fullImageView;

@end

@implementation PCPostViewController
@synthesize post;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.nextComment = [[PCComment alloc] init];
        
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
    
    CGFloat h = (boundingRect.size.height < 98.0f) ? 428.0f : boundingRect.size.height+302.0f;
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
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, h-0.5f, frame.size.width, 0.5f)];
    line.backgroundColor = [UIColor lightGrayColor];
    [header addSubview:line];
    
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
    [btnSend addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:btnSend];
    self.theTableview.tableFooterView = footer;
    
    
    [view addSubview:self.theTableview];

    
    
    self.fullImageView = [[UIScrollView alloc] initWithFrame:view.frame];
    self.fullImageView.delegate = self;
    self.fullImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.fullImageView.backgroundColor = [UIColor blackColor];
    self.fullImageView.minimumZoomScale = 1.0f;
    self.fullImageView.maximumZoomScale = 3.0f;
    self.fullImageView.alpha = 0.0f;
//    self.fullImageView.contentSize = CGSizeMake(self.post.frame.size.width, self.postImage.frame.size.height);
    
    self.fullImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.width)];
    self.fullImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.fullImage.center = self.fullImageView.center;
    [self.fullImageView addSubview:self.fullImage];
    [view addSubview:self.fullImageView];

    
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
            
            [self fetchComments];
            
        });
        
    }];
}

- (void)fetchComments
{
    if (self.post.comments)
        return;
    
    
    [[PCWebServices sharedInstance] fetchComments:@{@"thread":self.post.uniqueId} completion:^(id result, NSError *error){
        if (error)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            NSArray *c = results[@"comments"];
            self.post.comments = [NSMutableArray array];
            for (NSDictionary *commentInfo in c)
                [self.post.comments addObject:[PCComment commentWithInfo:commentInfo]];
            
            [self.theTableview reloadData];
        });
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]==NO)
        return;
    
    CGFloat offset = self.theTableview.contentOffset.y;
    CGRect frame = self.backgroundImage.frame;
    if (offset > 220.0f){
        if (frame.origin.y > 0.0f)
            frame.origin.y = 0.0f;
        return;
    }
    
    if (offset > 0){ // moving up - shift image up. 0 to 220.
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
    if (self.fullImageView.alpha == 0){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 0.0f;
                         self.fullImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];

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

- (void)submitComment:(UIButton *)btn
{
    if (self.commentField.text.length==0){
        [self showAlertWithTitle:@"Missing Comment" message:@"Please enter a comment first."];
        return;
    }
    
    self.nextComment.text = self.commentField.text;
    self.nextComment.profile = self.profile.uniqueId;
    self.nextComment.thread = self.post.uniqueId;
    [self.commentField resignFirstResponder];
    
    NSLog(@"submitComment: %@", [self.nextComment jsonRepresentation]);
    
    [self.loadingIndicator startLoading];
    [[PCWebServices sharedInstance] submitComment:self.nextComment completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        self.nextComment = [[PCComment alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.commentField.text = @"";
            
            if (self.post.comments==nil)
                self.post.comments = [NSMutableArray array];
            
            [self.post.comments addObject:[PCComment commentWithInfo:results[@"comment"]]];
            [self.theTableview reloadData];
        });
        
    }];
    
}

- (void)viewFullImage
{
//    CGPoint location = [tap locationInView:self.threadTable];
//    NSLog(@"viewImage: %.2f, %.2f", location.x, location.y);
    
    self.fullImage.image = self.post.imageData;
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 1.0f;
                         self.fullImageView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    if (self.commentField.isFirstResponder)
        [self.commentField resignFirstResponder];
    
    if ([scrollView isEqual:self.fullImageView]) // ingore this guy
        return;

}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"scrollViewDidEndDragging: %.2f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -80.0f)
        [self viewFullImage];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.fullImageView]==NO)
        return nil;
    
    return self.fullImage;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}




#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return 3;
    
    return self.post.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        static NSString *cellId = @"cellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = kLightGray;
        }
        
        // Reply Cell
        if (indexPath.row==0){
            cell.textLabel.textColor = kOrange;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"iconEnvelope.png"];
            cell.textLabel.text = @"REPLY";
            return cell;

        }
        
        cell.textLabel.textColor = kLightBlue;
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row==1){ // views cell:
            cell.imageView.image = [UIImage imageNamed:@"iconView.png"];
            cell.textLabel.text = [NSString stringWithFormat:@"%d Views", self.post.numViews];
            return cell;
        }
        
        // comments cell:
        cell.imageView.image = [UIImage imageNamed:@"iconComment.png"];
        cell.textLabel.text = [NSString stringWithFormat:@"%d Comments", self.post.numComments];
        return cell;
    }
    
    static NSString *commentCellId = @"commentCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:commentCellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
        cell.detailTextLabel.textColor = kLightBlue;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:line];
    }
    
    PCComment *comment = (PCComment *)self.post.comments[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n", comment.text];
    cell.detailTextLabel.text = comment.formattedDate;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
        return;

    
    if (indexPath.row != 0)
        return;
    
    PCConnectViewController *connectVc = [[PCConnectViewController alloc] init];
    connectVc.post = self.post;
    [self.navigationController pushViewController:connectVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
        return 44.0f;
    
    PCComment *comment = (PCComment *)self.post.comments[indexPath.row];
    CGRect bounds = [comment.text boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 300.0f)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:14.0f]}
                                               context:nil];

    return bounds.size.height+54.0f;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
