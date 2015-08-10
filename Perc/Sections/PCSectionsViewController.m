//
//  PCSectionsViewController.m
//  Perc
//
//  Created by Dan Kwon on 8/9/15.
//  Copyright (c) 2015 Perc. All rights reserved.


#import "PCSectionsViewController.h"
#import "PCCreateSectionViewController.h"
#import "PCPostsViewController.h"


@interface PCSectionsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *sectionsTable;
@end

@implementation PCSectionsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        
    }
    
    return self;
    
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    CGRect frame = view.frame;
    
    self.sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f) style:UITableViewStylePlain];
    self.sectionsTable.dataSource = self;
    self.sectionsTable.delegate = self;
    self.sectionsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    [view addSubview:self.sectionsTable];
    
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, kNavBarHeight)];
    topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundBlue.png"]];
    [view addSubview:topBar];
    
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropShadow.png"]];
    dropShadow.frame = CGRectMake(0.0f, kNavBarHeight, dropShadow.frame.size.width, dropShadow.frame.size.height);
    [view addSubview:dropShadow];
    
    [self addSwipeBackGesture:view];

    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(createSection:)];

    
//    [self.loadingIndicator startLoading];
//    [[PCWebServices sharedInstance] fetchSections:@{@"zone":self.currentZone.uniqueId} completion:^(id result, NSError *error){
//        [self.loadingIndicator stopLoading];
//        
//        if (error){
//            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
//            return;
//        }
//        
//        NSDictionary *results = (NSDictionary *)result;
//        NSLog(@"%@", [results description]);
//        
//        self.currentZone.sections = [NSMutableArray array];
//        NSArray *list = results[@"sections"];
//        for (int i=0; i<list.count; i++)
//            [self.currentZone.sections addObject:[PCSection sectionWithInfo:list[i]]];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.sectionsTable reloadData];
//        });
//    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.sectionsTable reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]==NO)
        return;
    
    [object removeObserver:self forKeyPath:@"imageData"];
    [self.sectionsTable reloadData];
}

- (void)createSection:(UIBarButtonItem *)btn
{
//    NSLog(@"createSection: ");
    PCCreateSectionViewController *createSectionVc = [[PCCreateSectionViewController alloc] init];
    [self.navigationController pushViewController:createSectionVc animated:YES];
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentZone.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    PCSection *section = (PCSection *)self.currentZone.sections[indexPath.row];
    cell.textLabel.text = section.name;
    
    if (section.imageData){
        cell.imageView.image = section.imageData;
        return cell;
    }
    
    [section addObserver:self forKeyPath:@"imageData" options:0 context:nil];
    [section fetchImage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCSection *section = (PCSection *)self.currentZone.sections[indexPath.row];

    PCPostsViewController *postsVc = [[PCPostsViewController alloc] init];
    [self.navigationController pushViewController:postsVc animated:YES];
}

@end
