//
//  OwnerQueryModel.h
//  BabySharing
//
//  Created by Alfred Yang on 3/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AppDelegate;

@interface OwnerQueryModel : NSObject
@property (strong, nonatomic) UIManagedDocument* doc;
@property (strong, nonatomic) NSArray* querydata;
@property (weak, nonatomic, readonly) AppDelegate* delegate;

#pragma mark -- constractor
- (id)initWithDelegate:(AppDelegate*)app;

#pragma mark -- query content with tags
typedef void(^queryFinishedBlock)(BOOL success);
- (NSArray*)queryContentsByUser:(NSString*)user_id withToken:(NSString*)token andOwner:(NSString*)owner_id withStartIndex:(NSInteger)startIndex finishedBlock:(queryFinishedBlock)block;
- (NSArray*)appendContentsByUser:(NSString*)user_id withToken:(NSString*)token andOwner:(NSString*)owner_id withStartIndex:(NSInteger)startIndex finishedBlock:(queryFinishedBlock)block;
@end
