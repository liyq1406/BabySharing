//
//  MessageModel.m
//  ChatModel
//
//  Created by Alfred Yang on 3/05/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "MessageModel.h"
#import "ModelDefines.h"
#import <CoreData/CoreData.h>
#import "RemoteInstance.h"
//#import "Messages+ContextOpt.h"
#import "AppDelegate.h"
#import "EnumDefines.h"
#import "NotificationOwner+ContextOpt.h"

#import "GotyeOCAPI.h"
#import "GotyeOCChatTarget.h"
#import "GotyeOCMessage.h"

@implementation MessageModel

@synthesize delegate = _delegate;
@synthesize doc = _doc;

#pragma mark -- constractor
- (void)enumDataFromLocalDB:(UIManagedDocument*)document {
    dispatch_queue_t aq = dispatch_queue_create("load_message_queue", NULL);
    
    dispatch_async(aq, ^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [document.managedObjectContext performBlock:^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"message data ready" object:nil];
            }];
        });
    });
}

- (id)initWithDelegate:(AppDelegate*)app {
    self = [super init];
    /**
     * get authorised user array in the local database
     */
    NSString* docs=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL* url =[NSURL fileURLWithPath:[docs stringByAppendingPathComponent:LOCALDB_MESSAGEG_NOTIFICATION]];
    _doc = (UIManagedDocument*)[[UIManagedDocument alloc]initWithFileURL:url];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:[url path] isDirectory:NO]) {
        [_doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            [self enumDataFromLocalDB:_doc];
        }];
    } else if (_doc.documentState == UIDocumentStateClosed) {
        [_doc openWithCompletionHandler:^(BOOL success){
            [self enumDataFromLocalDB:_doc];
        }];
    } else {
        
    }
    return self;
}

#pragma mark -- save notifications
- (void)save {
    [_doc.managedObjectContext save:nil];
}

#pragma mark -- notification functions
- (void)addNotification:(NSDictionary*)notification withFinishBlock:(receiveNotification)block {
    [NotificationOwner addNotification:notification forUser:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
    if (block) block();
}

- (NSArray*)enumNotifications {
    return [NotificationOwner enumNotificationsForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
}

- (void)removeAllNotifications {
    [NotificationOwner removeAllNotificationsForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
}

- (void)removeOneNotification:(Notifications*)notification {
    [NotificationOwner removeOneNotification:notification ForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
}

- (NSInteger)unReadNotificationCount {
    return [NotificationOwner unReadNotificationCountForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
}

- (void)markAllNotificationsAsReaded {
    [NotificationOwner markAllNotificationAsReadedForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
}

#pragma mark -- p2p chat message and group chat message
- (void)addMessage:(NSDictionary*)message {
    [NotificationOwner addMessageWith:_delegate.lm.current_user_id message:message inContext:_doc.managedObjectContext];
}

- (NSArray*)enumAllTargets {
    return [NotificationOwner enumAllTargetForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext];
}

- (NSArray*)enumAllMessagesWithTarget:(Targets*)target {
    return [NotificationOwner enumAllMessagesForTarget:target inContext:_doc.managedObjectContext];
}

- (void)sendMessageToUser:(NSString*)target_id messageType:(MessageType)type messageContent:(NSString*)contents {
   
    GotyeOCChatTarget* ct = [GotyeOCUser userWithName:target_id];
    GotyeOCMessage* m = [GotyeOCMessage createTextMessage:ct text:contents];
    [GotyeOCAPI sendMessage:m];
}

- (Targets*)enumAllTargetWithTargetID:(NSString*)target_id {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"target_id=%@", target_id];
    return [[NotificationOwner enumAllTargetForOwner:_delegate.lm.current_user_id inContext:_doc.managedObjectContext] filteredArrayUsingPredicate:pred].firstObject;
}

- (Targets*)addTarget:(NSDictionary*)tar {
    return [NotificationOwner addTargetWith:_delegate.lm.current_user_id targetDic:tar inContext:_doc.managedObjectContext];
}

#pragma mark -- p2p chat message and group chat message use GotyeOCAPI
- (NSInteger)getMesssageSessionCount {
    return [GotyeOCAPI getSessionList].count;
}

- (NSInteger)getMesssageSessionCountWithTargetType:(MessageReceiverType*)type {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"type=%%d", type];
    return [[GotyeOCAPI getSessionList] filteredArrayUsingPredicate:pred].count;
}

- (id)getTargetByIndex:(NSInteger)index {
    return [[GotyeOCAPI getSessionList] objectAtIndex:index];
}

- (id)getTargetByIndex:(NSInteger)index WithTargetType:(MessageReceiverType*)type {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"type=%%d", type];
    return [[[GotyeOCAPI getSessionList] filteredArrayUsingPredicate:pred] objectAtIndex:index];
}

- (NSString*)getLastestMessageWith:(GotyeOCChatTarget*)target {
    return [GotyeOCAPI getLastMessage:target].text;
}

- (NSInteger)getUnreadMessageCount:(GotyeOCChatTarget*)target {
    return [GotyeOCAPI getUnreadMessageCount:target];
}

- (NSArray*)getAllMessagesWithTarget:(NSString*)target_id andTargetType:(MessageReceiverType)type {
    GotyeOCChatTarget* t = nil;
    switch (type) {
        case MessageReceiverTypeUser:
            t = [GotyeOCUser userWithName:target_id];
                 break;
            
        default:
            break;
    }
    
    return [GotyeOCAPI getMessageList:t more:NO];
}

- (void)beginActiveForTarget:(NSString*)target_id {
    GotyeOCChatTarget* t = [GotyeOCUser userWithName:target_id];
    [GotyeOCAPI activeSession:t];
}

- (void)endActiveForTarget:(NSString*)target_id {
    GotyeOCChatTarget* t = [GotyeOCUser userWithName:target_id];
    [GotyeOCAPI deactiveSession:t];
}

- (NSInteger)getAllUnreadMessageCount {
    return [GotyeOCAPI getUnreadMessageCountOfTypes:@[@0]];
}
@end
