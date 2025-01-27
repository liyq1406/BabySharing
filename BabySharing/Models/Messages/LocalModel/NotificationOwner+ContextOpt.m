//
//  NotificationOwner+ContextOpt.m
//  BabySharing
//
//  Created by Alfred Yang on 8/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import "NotificationOwner+ContextOpt.h"
#import "EnumDefines.h"
#import "Targets.h"
#import "Messages.h"

@implementation NotificationOwner(ContextOpt)

#pragma mark -- notification functions
+ (NotificationOwner*)enumNotificationOwnerWithID:(NSString*)user_id inContext:(NSManagedObjectContext*)context {
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"NotificationOwner"];
    request.predicate = [NSPredicate predicateWithFormat:@"user_id = %@", user_id];
    
    NSError* error = nil;
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || matches.count > 1) {
        NSLog(@"error with primary key");
        return nil;
    } else if (matches.count == 1) {
        return matches.firstObject;
    } else {
        NSLog(@"nothing need to be delected");
        NotificationOwner* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"NotificationOwner" inManagedObjectContext:context];
        tmp.user_id = user_id;
        return tmp;
    }
}

+ (Notifications*)addNotification:(NSDictionary*)notification forUser:(NSString*)user_id inContext:(NSManagedObjectContext*)context {

    NotificationOwner* owner = [self enumNotificationOwnerWithID:user_id inContext:context];
   
    Notifications* tmp = [NSEntityDescription insertNewObjectForEntityForName:@"Notifications" inManagedObjectContext:context];
    
    tmp.date = [NSDate dateWithTimeIntervalSince1970:((NSNumber*)[notification objectForKey:@"date"]).longLongValue / 1000];
    tmp.type = (NSNumber*)[notification objectForKey:@"type"];
    tmp.sender_id = user_id;
    tmp.sender_screen_name = [notification objectForKey:@"sender_screen_name"];
    tmp.sender_screen_photo = [notification objectForKey:@"sender_screen_photo"];
    tmp.status = [NSNumber numberWithInt:MessagesStatusUnread];

    tmp.beNotified = owner;
    [owner addNotificationsObject:tmp];
    
    [context save:nil];
   
    return tmp;
}

+ (NSArray*)enumNotificationsForOwner:(NSString*)user_id inContext:(NSManagedObjectContext*)context {
    
    NotificationOwner* owner = [self enumNotificationOwnerWithID:user_id inContext:context];
    return owner.notifications.allObjects;
}

+ (void)removeAllNotificationsForOwner:(NSString*)user_id inContext:(NSManagedObjectContext*)context {

    NotificationOwner* owner = [self enumNotificationOwnerWithID:user_id inContext:context];
    while (owner.notifications.count != 0) {
        Notifications* tmp = owner.notifications.anyObject;
        [owner removeNotificationsObject:tmp];
        [context deleteObject:tmp];
    }
}

+ (void)removeOneNotification:(Notifications*)notification ForOwner:(NSString*)user_id inContext:(NSManagedObjectContext*)context {
    
    NotificationOwner* owner = [self enumNotificationOwnerWithID:user_id inContext:context];
    [owner removeNotificationsObject:notification];
    [context deleteObject:notification];
}

+ (NSInteger)unReadNotificationCountForOwner:(NSString*)user_id inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:user_id inContext:context];

    NSArray* notify_arr = owner.notifications.allObjects;
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"status=%d", [NSNumber numberWithInt:MessagesStatusUnread].integerValue];
   
    return [notify_arr filteredArrayUsingPredicate:pred].count;
}

+ (void)markAllNotificationAsReadedForOwner:(NSString*)user_id inContext:(NSManagedObjectContext*)context {
    
    NotificationOwner* owner = [self enumNotificationOwnerWithID:user_id inContext:context];
    for (Notifications* iter in owner.notifications.allObjects) {
        iter.status = [NSNumber numberWithInt:MessagesStatusReaded];
    }
}

#pragma mark -- p2p chat
+ (void)addMessageWith:(NSString*)owner_id message:(NSDictionary*)message_dic inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];
    
    MessageReceiverType receiver_type = ((NSNumber*)[message_dic objectForKey:@"receiverType"]).intValue;
    NSString* target_id = [message_dic objectForKey:@"sender_id"];
    
    Targets* target = [self enumTargetWith:owner andID:target_id];
    if (target == nil) {
        target = [NSEntityDescription insertNewObjectForEntityForName:@"Targets" inManagedObjectContext:context];
        target.target_id = target_id;
        target.target_type = [NSNumber numberWithInt:receiver_type];
        target.target_name = [message_dic objectForKey:@"sender_screen_name"];
        target.target_photo = [message_dic objectForKey:@"sender_screen_photo"];
        target.chatFrom = owner;
        [owner addChatWithObject:target];
    }

    NSDate* message_date = [NSDate dateWithTimeIntervalSince1970:((NSNumber*)[message_dic objectForKey:@"date"]).longLongValue / 1000];
    target.last_time = message_date;

    Messages* message = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:context];
   
    message.message_type = ((NSNumber*)[message_dic objectForKey:@"messageType"]);
    message.message_date = message_date;
    message.message_content = [message_dic objectForKey:@"content"];
    message.message_status = [NSNumber numberWithInt:MessagesStatusUnread];
    
    message.messageFrom = target;
    [target addMessagesObject:message];
}

+ (Targets*)enumTargetWith:(NotificationOwner*)owner andID:(NSString*)target_id {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"target_id=%@", target_id];
    NSArray* result = [owner.chatWith.allObjects filteredArrayUsingPredicate:pred];
    if (result.count != 1) return nil;
    else return result.firstObject;
}

+ (Targets*)enumTargetWith:(NotificationOwner*)owner andGroupID:(NSNumber*)group_id {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"group_id=%@ AND target_type=%d", group_id, 1];
    NSArray* result = [owner.chatWith.allObjects filteredArrayUsingPredicate:pred];
    if (result.count != 1) return nil;
    else return result.firstObject;
}

+ (NSArray*)enumAllTargetForOwner:(NSString*)owner_id andType:(NSInteger)type inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"target_type=%d", type];
    return [owner.chatWith.allObjects filteredArrayUsingPredicate:pred];
}

+ (NSArray*)enumAllTargetForOwner:(NSString*)owner_id inContext:(NSManagedObjectContext*)context {
    
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];
    return owner.chatWith.allObjects;
}

+ (NSArray*)enumAllMessagesForTarget:(Targets*)target inContext:(NSManagedObjectContext*)context {
    return target.messages.allObjects;
}

+ (Targets*)addTargetWith:(NSString*)owner_id targetDic:(NSDictionary*)tar inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];
    
    MessageReceiverType receiver_type = MessageReceiverTypeUser;
    NSString* target_id = [tar objectForKey:@"user_id"];
    
    Targets* target = [self enumTargetWith:owner andID:target_id];
    if (target == nil) {
        target = [NSEntityDescription insertNewObjectForEntityForName:@"Targets" inManagedObjectContext:context];
        target.target_id = target_id;
        target.target_type = [NSNumber numberWithInt:receiver_type];
        target.target_name = [tar objectForKey:@"screen_name"];
        target.target_photo = [tar objectForKey:@"screen_photo"];
        target.in_the_group = 0;
        target.owner_id = target_id;
        target.number_count = [NSNumber numberWithInt:1];
        target.chatFrom = owner;
        [owner addChatWithObject:target];
    }
    
    return target;
}

+ (Targets*)addChatGroupWithOwnerID:(NSString*)owner_id chatGroup:(NSDictionary*)tar inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];
    
    MessageReceiverType receiver_type = MessageReceiverTypeChatGroup;
    NSNumber* group_id = [tar objectForKey:@"group_id"];
    
    Targets* target = [self enumTargetWith:owner andGroupID:group_id];
    if (target == nil) {
        target = [NSEntityDescription insertNewObjectForEntityForName:@"Targets" inManagedObjectContext:context];
        target.group_id = group_id;
        target.chatFrom = owner;
        [owner addChatWithObject:target];
    }
   
    target.target_type = [NSNumber numberWithInt:receiver_type];
  
    NSEnumerator* enumerator = tar.keyEnumerator;
    id iter = nil;
    
    while ((iter = [enumerator nextObject]) != nil) {
        if ([iter isEqualToString:@"group_name"]) {
            target.target_name = [tar objectForKey:@"group_name"];
        } else if ([iter isEqualToString:@"in_the_group"]) {
            target.in_the_group = [tar objectForKey:@"in_the_group"];
        } else if ([iter isEqualToString:@"owner_id"]) {
            target.owner_id = [tar objectForKey:@"owner_id"];
        } else if ([iter isEqualToString:@"joiners_count"]) {
            target.number_count = [tar objectForKey:@"joiners_count"];
        } else {
            // user id, do nothing
        }
    }
    return target;
}

+ (NSInteger)chatGroupCountWithOwnerID:(NSString *)owner_id andPred:(NSPredicate*)pred inContext:(NSManagedObjectContext *)context {
    return [self enumTargetForOwner:owner_id andPred:pred inContext:context].count;
}

+ (NSArray*)enumTargetForOwner:(NSString*)owner_id andPred:(NSPredicate*)pred inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];
    return [owner.chatWith.allObjects filteredArrayUsingPredicate:pred];
}

+ (NSInteger)chatGroupCountWithOwnerID:(NSString*)owner_id inContext:(NSManagedObjectContext*)context {
    return [self enumAllTargetForOwner:owner_id andType:MessageReceiverTypeChatGroup inContext:context].count;
}

+ (NSArray*)updateMultipleChatGroupWithOwnerID:(NSString*)owner_id chatGroups:(NSArray*)tar inContext:(NSManagedObjectContext*)context {
    NotificationOwner* owner = [self enumNotificationOwnerWithID:owner_id inContext:context];

    NSMutableArray* tmp = [[self enumAllTargetForOwner:owner_id andType:MessageReceiverTypeChatGroup inContext:context] mutableCopy];
    
    while (tmp.count != 0) {
        Targets* iter = [tmp firstObject];
        [owner removeChatWithObject:iter];
        [context deleteObject:iter];
        [tmp removeObject:iter];
    }

    NSMutableArray* reVal = [[NSMutableArray alloc]init];
    for (NSDictionary* dic in tar) {
        [reVal addObject:[self addChatGroupWithOwnerID:owner_id chatGroup:dic inContext:context]];
    }
   
    return reVal;
}
@end
