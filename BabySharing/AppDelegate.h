//
//  AppDelegate.h
//  YYBabyAndMother
//
//  Created by Alfred Yang on 16/12/2014.
//  Copyright (c) 2014 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "LoginModel.h"
#import "PostModel.h"
#import "QueryModel.h"
#import "GroupModel.h"
#import "MessageModel.h"
#import "TagQueryModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WeiboSDKDelegate, WXApiDelegate> {
    enum WXScene _scene;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) LoginModel* lm;
@property (strong, nonatomic, readonly) PostModel* pm;
@property (strong, nonatomic, readonly) QueryModel* qm;
@property (strong, nonatomic, readonly) GroupModel* gm;
@property (strong, nonatomic, readonly) MessageModel* mm;
@property (strong, nonatomic, readonly) TagQueryModel* tm;

- (void)createQueryModel;
- (void)createGroupModel;
@end