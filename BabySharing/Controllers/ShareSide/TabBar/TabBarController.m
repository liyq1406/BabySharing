//
//  TabBarController.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 20/12/2014.
//  Copyright (c) 2014 YY. All rights reserved.
//

#import "TabBarController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTType.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "ShareSideBaseController.h"
//#import "MovingButton.h"

#import "AlbumViewController.h"
#import "CVMovieController.h"
#import "CVViewController2.h"
#import "WebSearchController.h"

//#define MOVING_DISTANCE     90
//#define MOVING_BASE         20
//#define MOVING_ANGLE        0.6

@interface TabBarController ()

@end

@implementation TabBarController {
//    MovingButton* photoBtn;
//    MovingButton* movieBtn;
//    MovingButton* compareBtn;
    
    UIView* backView;
}

@synthesize lm = _lm;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
  
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    UITabBarItem* item0 = [self.tabBar.items objectAtIndex:0];
    item0.image =[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Home"] ofType:@"png"]];

    UITabBarItem* item1 = [self.tabBar.items objectAtIndex:1];
    item1.image =[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Chat"] ofType:@"png"]];

    UITabBarItem* item2 = [self.tabBar.items objectAtIndex:2];
    item2.image =[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Plus"] ofType:@"png"]];

    UITabBarItem* item3 = [self.tabBar.items objectAtIndex:3];
    item3.image =[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Message"] ofType:@"png"]];

    UITabBarItem* item4 = [self.tabBar.items objectAtIndex:4];
    item4.image =[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Personal_Center"] ofType:@"png"]];

    [self setUpMovingButtonsWithBoundle:resourceBundle];

    ((UITabBarItem*)[self.tabBar.items objectAtIndex:3]).badgeValue = [NSString stringWithFormat:@"%d",[_mm unReadNotificationCount]];
}

- (void)setUpMovingButtonsWithBoundle:(NSBundle*)bundle {
    CGRect rc = [UIScreen mainScreen].bounds;
    CGRect rc_tb = self.tabBar.bounds;
    backView = [[UIView alloc]initWithFrame:CGRectMake(rc.origin.x, rc.origin.y, rc.size.width, rc.size.height - rc_tb.size.height)];
    backView.backgroundColor =  [UIColor colorWithWhite:0.0 alpha:0.0];
    [self.view addSubview:backView];
    
    [self.view bringSubviewToFront:backView];
    backView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma marks - change to side B
- (void)showSecretSideOnController:(UIViewController*)parent {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SecretNib" bundle:nil];
    UIViewController* SecretNav = [storyboard instantiateViewControllerWithIdentifier:@"SecretNav"];
    [parent presentViewController:SecretNav animated:YES completion: ^(void){
        NSLog(@"Secret running ...");
    }];
}

#pragma marks - tabBar delegate

- (void)showCameraControllerOnController:(UIViewController*)parent {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CameraNib2" bundle:nil];
    CVViewController2* cameraNav = [storyboard instantiateViewControllerWithIdentifier:@"cameraNav"];
    cameraNav.delegate = self;
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:cameraNav];
//    [parent presentViewController:cameraNav animated:YES completion: ^(void){
    [nav setNavigationBarHidden:YES];
    [parent presentViewController:nav animated:YES completion: ^(void){
        NSLog(@"camera running ...");
    }];
}

- (void)showMovieControllerOnController:(UIViewController*)parent {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MovieNib" bundle:nil];
    CVMovieController* cameraNav = [storyboard instantiateViewControllerWithIdentifier:@"MovieNib"];
    cameraNav.delegate = self;
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:cameraNav];
    [nav setNavigationBarHidden:YES];
//    [parent presentViewController:cameraNav animated:YES completion: ^(void){
    [parent presentViewController:nav animated:YES completion: ^(void){
        NSLog(@"movie running ...");
    }];
}

- (void)showNetControllerOnController:(UIViewController*)parent {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"webNab" bundle:nil];
    WebSearchController* cameraNav = [storyboard instantiateViewControllerWithIdentifier:@"webNab"];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:cameraNav];
    [nav setNavigationBarHidden:YES];
    //    [parent presentViewController:cameraNav animated:YES completion: ^(void){
    [parent presentViewController:nav animated:YES completion: ^(void){
        NSLog(@"movie running ...");
    }];
}

- (void)showAblumCameraController:(UIViewController*)parent andType:(AlbumControllerType)type {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AlbumNib" bundle:nil];
    UIViewController* postNav = [storyboard instantiateViewControllerWithIdentifier:@"AlbumNav"];
    [parent presentViewController:postNav animated:YES completion: ^(void){
        NSLog(@"Post controller running ...");
        AlbumViewController* pv = [[postNav childViewControllers] firstObject];
        pv.delegate = self;
        pv.actionType = type;
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"select tab %@", item.title);
   
    if ([item.title isEqualToString:@"Post"]) {
        [self showCameraControllerOnController:self];
    }
}

- (void)tabBar:(UITabBar *)tabBar willBeginCustomizingItems:(NSArray *)items {
    NSLog(@"customzing items ...");
}


#pragma marks - tabbar controller delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController.tabBar.selectedItem.title isEqualToString:@"Post"]) {
        return NO;
    }
    
    if (backView.hidden == NO) {
        return NO;
    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    for (UIViewController * iter in viewControllers) {
        NSLog(@"%@", iter.title);
    }
}

#pragma mark -- Post Action Delegate
- (void)didCameraBtn: (UIViewController*)pv {
    [pv dismissViewControllerAnimated:YES completion:^{
        [self showCameraControllerOnController:self];
    }];
}

- (void)didMovieBtn:(UIViewController *)pv {
    [pv dismissViewControllerAnimated:YES completion:^{
        [self showMovieControllerOnController:self];
    }];
}

- (void)didCompareBtn: (UIViewController*)pv {
    [pv dismissViewControllerAnimated:YES completion:^{
        [self showNetControllerOnController:self];
    }];   
}

- (void)postViewController:(UIViewController*)pv didPostSueecss:(BOOL)success {
    if (success) {
        [pv dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- camera action protocol
- (void)didSelectAlbumBtn:(UIViewController*)cur andCurrentType:(AlbumControllerType)type {
    [cur dismissViewControllerAnimated:YES completion:^{
        [self showAblumCameraController:self andType:type];
    }];
}

- (void)didSelectMovieBtn2:(UIViewController*)cur {
    [cur dismissViewControllerAnimated:YES completion:^{
        [self showMovieControllerOnController:self];
    }];
}

- (void)didSelectCameraBtn2:(UIViewController*)cur {
    [cur dismissViewControllerAnimated:YES completion:^{
        [self showCameraControllerOnController:self];
    }];
}

- (void)didSelectAlbumBtn2:(UIViewController*)cur {
    
}

#pragma mark -- notifications
- (void)addOneNotification {
    ((UITabBarItem*)[self.tabBar.items objectAtIndex:3]).badgeValue = [NSString stringWithFormat:@"%d",[_mm unReadNotificationCount]];
}
@end
