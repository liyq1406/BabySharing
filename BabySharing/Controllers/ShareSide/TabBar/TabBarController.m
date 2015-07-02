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
#import "MovingButton.h"

#import "AlbumViewController.h"
#import "CVMovieController.h"
#import "CVViewController2.h"
#import "WebSearchController.h"

#define MOVING_DISTANCE     90
#define MOVING_BASE         20
#define MOVING_ANGLE        0.6

@interface TabBarController ()

@end

@implementation TabBarController {
//    MovingButton* ablumBtn;
    MovingButton* photoBtn;
    MovingButton* movieBtn;
    MovingButton* compareBtn;
    
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
}

- (void)setUpMovingButtonsWithBoundle:(NSBundle*)bundle {
    CGRect rc = [UIScreen mainScreen].bounds;
    CGRect rc_tb = self.tabBar.bounds;
    backView = [[UIView alloc]initWithFrame:CGRectMake(rc.origin.x, rc.origin.y, rc.size.width, rc.size.height - rc_tb.size.height)];
//    backView.backgroundColor =  [UIColor colorWithWhite:0.0 alpha:0.8];
    backView.backgroundColor =  [UIColor colorWithWhite:0.0 alpha:0.0];
    [self.view addSubview:backView];
    
    CGPoint start_pos = self.tabBar.center;
    CGPoint end_pos_1 = CGPointMake(start_pos.x - MOVING_DISTANCE, start_pos.y - MOVING_BASE - MOVING_DISTANCE * 0.5);
    CGPoint end_pos_2 = CGPointMake(start_pos.x, start_pos.y - MOVING_BASE - MOVING_DISTANCE);
    CGPoint end_pos_3 = CGPointMake(start_pos.x + MOVING_DISTANCE, start_pos.y - MOVING_BASE - MOVING_DISTANCE * 0.5);
    
    photoBtn = [[MovingButton alloc]initWithOrigin:start_pos andFinal:end_pos_1 andRangle:-MOVING_ANGLE];
    [photoBtn setBackgroundImage:[UIImage imageNamed:[bundle pathForResource:@"Camera_Small" ofType:@"png"]] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(didSelectPhotoBtn:) forControlEvents:UIControlEventTouchDown];
    
    movieBtn = [[MovingButton alloc]initWithOrigin:start_pos andFinal:end_pos_2 andRangle:0];
    [movieBtn setBackgroundImage:[UIImage imageNamed:[bundle pathForResource:@"Movie_Small" ofType:@"png"]] forState:UIControlStateNormal];
    [movieBtn addTarget:self action:@selector(didSelectMovieBtn:) forControlEvents:UIControlEventTouchDown];
    
    compareBtn = [[MovingButton alloc]initWithOrigin:start_pos andFinal:end_pos_3 andRangle:MOVING_ANGLE];
    [compareBtn setBackgroundImage:[UIImage imageNamed:[bundle pathForResource:@"Compare" ofType:@"png"]] forState:UIControlStateNormal];
    [compareBtn addTarget:self action:@selector(didSelectCompareBtn:) forControlEvents:UIControlEventTouchDown];
    
//    [backView addSubview:ablumBtn];
//    [backView addSubview:photoBtn];
//    [backView addSubview:movieBtn];
    
    [self.view bringSubviewToFront:backView];
    backView.hidden = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(movingAnimation:)];
    [backView addGestureRecognizer:gesture];
    
    [self.view addSubview:photoBtn];
    [self.view addSubview:movieBtn];
    [self.view addSubview:compareBtn];
    
    [self.view bringSubviewToFront:photoBtn];
    [self.view bringSubviewToFront:movieBtn];
    [self.view bringSubviewToFront:compareBtn];
    
    photoBtn.hidden = YES;
    movieBtn.hidden = YES;
    compareBtn.hidden = YES;
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
   
    if (backView.hidden == NO) {
        [self movingAnimation:nil];
    }
    
    else if ([item.title isEqualToString: @"Post"]) {
        // [self showAblumCameraController:self];
        [self movingAnimation:nil];
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

//#pragma marks - camera actions
//- (void)didSelectPhotoAblum: (CVViewController*)cv {
//    NSLog(@"Show Album");
//    
//    //检查相机模式是否可用
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        NSLog(@"sorry, no camera or camera is unavailable!!!");
//        return;
//    }
//    //获得相机模式下支持的媒体类型
//    NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//    BOOL canTakeVideo = NO;
//    for (NSString* mediaType in availableMediaTypes) {
//        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
//            //支持摄像
//            canTakeVideo = YES;
//            break;
//        }
//    }
//    //检查是否支持摄像
//    if (!canTakeVideo) {
//        NSLog(@"sorry, capturing video is not supported.!!!");
//        return;
//    }
//    //创建图像选取控制器
//    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
//    //设置图像选取控制器的来源模式为相机模式
//    //imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    //  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    //设置图像选取控制器的类型为动态图像
//    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, (NSString*)kUTTypeImage, nil];
//    //设置摄像图像品质
//    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    //设置最长摄像时间
//    imagePickerController.videoMaximumDuration = 30;
//    //允许用户进行编辑
//    imagePickerController.allowsEditing = YES;
//    //设置委托对象
//    imagePickerController.delegate = self;
//    //以模式视图控制器的形式显示
//    [cv presentModalViewController:imagePickerController animated:YES];
//}
//
//- (void)didCapturePicture : (CVViewController*)cv{
//    
//}
//
//- (void)didStartTakeVedio : (CVViewController*)cv{
//    
//}
//
//- (void)didStopTakeVedio : (CVViewController*)cv{
//    
//}

#pragma mark - import photo from 
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    if (!error) {
        NSLog(@"picture saved with no error.");

    } else {
        NSLog(@"error occured while saving the picture%@", error);
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //打印出字典中的内容
    NSLog(@"get the media info: %@", info);
    //获取媒体类型
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取用户编辑之后的图像
        UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        //将该图像保存到媒体库中
        UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        //获取视频文件的url
        //        NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //        //创建ALAssetsLibrary对象并将视频保存到媒体库
        //        ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
        //        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:mediaURL completionBlock:^(NSURL *assetURL, NSError *error) {
        //            if (!error) {
        //                NSLog(@"captured video saved with no error.");
        //            }else
        //            {
        //                NSLog(@"error occured while saving the video:%@", error);
        //            }
        //        }];
        //        [assetsLibrary release];
    }
    //    [picker dismissModalViewControllerAnimated:YES];
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

#pragma mark -- post buttons at tabbar and buttons animation
- (void)didSelectCompareBtn:(id)sender {
    NSLog(@"did select ablum button");
    [self showAblumCameraController:self andType:AlbumControllerTypeCompire];
    [self resetMovingAnimation];
}

- (void)didSelectPhotoBtn:(id)sender {
    NSLog(@"did select camera button");
//    [self showCameraControllerOnController:self];
    [self showAblumCameraController:self andType:AlbumControllerTypePhoto];
    [self resetMovingAnimation];
}

- (void)didSelectMovieBtn:(id)sender {
    NSLog(@"did select movie button");
    [self showMovieControllerOnController:self];
    [self resetMovingAnimation];
}

- (void)resetMovingAnimation {
    backView.hidden = YES;
    [compareBtn resetPos];
    compareBtn.hidden = YES;
    [photoBtn resetPos];
    photoBtn.hidden = YES;
    [movieBtn resetPos];
    movieBtn.hidden = YES;
}

- (void)movingAnimation:(id)sender {
    // [self showAblumCameraController:self];
    compareBtn.hidden = NO;
    photoBtn.hidden = NO;
    movieBtn.hidden = NO;
    backView.hidden = NO;
    
    [compareBtn moveWithFinishBlock:^(BOOL finished, MovingButton *btn) {
        if (btn.isMoved == YES) {
            btn.hidden = NO;
            backView.hidden = NO;
        } else {
            btn.hidden = YES;
            backView.hidden = YES;
        }
    }];
    [photoBtn moveWithFinishBlock:^(BOOL finished, MovingButton *btn) {
        if (btn.isMoved == YES) {
            btn.hidden = NO;
            backView.hidden = NO;
        } else {
            btn.hidden = YES;
            backView.hidden = YES;
        }
    }];
    [movieBtn moveWithFinishBlock:^(BOOL finished, MovingButton *btn) {
        if (btn.isMoved == YES) {
            btn.hidden = NO;
            backView.hidden = NO;
        } else {
            btn.hidden = YES;
            backView.hidden = YES;
        }
    }];
}
@end