//
//  LKTabViewController.m
//  LKBrowser
//
//  Created by Lookis on 16/03/2017.
//  Copyright © 2017 Lookis. All rights reserved.
//

#import "LKTabViewController.h"
#import "LKTabCell.h"
#import "LKTabTransitioning.h"
#import "LKTabExitTransitioning.h"
#import "BrowserViewController.h"

@interface LKTabViewController () <UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *cellLayout;
@property (nonatomic, strong) NSMutableArray<BrowserViewController *> *browserArray;
@property (nonatomic) BOOL firstLoading;
@property (nonatomic, strong) LKTabTransitioning *presentTransitioning;
@property (nonatomic, strong) LKTabExitTransitioning *dismissTransitioning;
@property (nonatomic, strong) NSTimer *refreshTimer;
@end

static NSString * const reuseIdentifier = @"LKCell";

@implementation LKTabViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    _browserArray = [[NSMutableArray alloc] init];
    _presentTransitioning = [[LKTabTransitioning alloc] init];
    _dismissTransitioning = [[LKTabExitTransitioning alloc] init];
    _firstLoading = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = CGSizeMake(rect.size.width/4, rect.size.height/4);
    [_cellLayout setItemSize:size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [[self collectionView] reloadData];
}


-(void)viewDidAppear:(BOOL)animated{
    if(_firstLoading){
        _firstLoading = NO;
        [self createDefaultTabAndPresent];
    }
}

- (void)createDefaultTabAndPresent{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BrowserViewController *browserController = [storyboard instantiateViewControllerWithIdentifier:@"browserViewController"];
    [browserController setTransitioningDelegate:self];
    [_browserArray addObject:browserController];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_browserArray count] - 1 inSection:0];
    [self setSelectedFrame:[self.collectionView cellForItemAtIndexPath:indexPath].frame];
    [self presentViewController:[_browserArray firstObject] animated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_browserArray count];
}

- (LKTabCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
    LKTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    BrowserViewController *browserController = _browserArray[indexPath.row];
    UIView *snapshot = nil;
    if (browserController.cover){
        snapshot = [browserController.cover snapshotViewAfterScreenUpdates:YES];
    }else{
        snapshot = [[UIView alloc] init];
        [snapshot setBackgroundColor:[UIColor whiteColor]];
    }
    [snapshot setContentMode:UIViewContentModeScaleAspectFit];
    [snapshot setFrame:cell.contentView.frame];
    [[cell contentView] addSubview:snapshot];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self setSelectedFrame:[self.collectionView cellForItemAtIndexPath:indexPath].frame];
    BrowserViewController *browserController = [_browserArray objectAtIndex:indexPath.row];
    [self presentViewController:browserController animated:YES completion:nil];
}


#pragma mark <UIViewControllerAnimatedTransitioning>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return _presentTransitioning;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return _dismissTransitioning;
}

@end

