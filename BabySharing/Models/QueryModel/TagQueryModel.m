//
//  TagQueryModel.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 20/06/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "TagQueryModel.h"
#import <CoreData/CoreData.h>
#import "QueryContent+ContextOpt.h"
#import "ModelDefines.h"
#import "RemoteInstance.h"

@interface TagQueryModel()
@end

@implementation TagQueryModel

@synthesize querydata = _querydata;
@synthesize delegate = _delegate;
@synthesize doc = _doc;

#pragma mark -- instuction
- (void)enumDataFromLocalDB:(UIManagedDocument*)document {
//    dispatch_queue_t aq = dispatch_queue_create("load_query_data", NULL);
//    
//    dispatch_async(aq, ^(void){
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            [document.managedObjectContext performBlock:^(void){
//                _querydata =  [QueryContent enumLocalQueyDataInContext:document.managedObjectContext];
//                if (_querydata == nil || _querydata.count == 0) {
//                    [self refreshQueryDataByUser:self.delegate.lm.current_user_id withToken:self.delegate.lm.current_auth_token];
//                }
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"query data ready" object:nil];
//            }];
//        });
//    });
}

- (id)initWithDelegate:(AppDelegate*)app {
    self = [super init];
    if (self) {
        
        _delegate = app;
        /**
         * get previous data from local database
         */
        NSString* docs=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL* url =[NSURL fileURLWithPath:[docs stringByAppendingPathComponent:LOCALDB_TAG_QUERY]];
        _doc = (UIManagedDocument*)[[UIManagedDocument alloc]initWithFileURL:url];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:[url path] isDirectory:nil]) {
            [_doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                NSLog(@"create query database callback");
                [self enumDataFromLocalDB:_doc];
            }];
        } else if (_doc.documentState == UIDocumentStateClosed) {
            [_doc openWithCompletionHandler:^(BOOL success) {
                NSLog(@"open query database callback");
                [self enumDataFromLocalDB:_doc];
            }];
        } else {
            
        }
    }
    
    return self;
}

#pragma mark -- query content with tags
- (NSArray*)queryTagContentsByUser:(NSString*)user_id withToken:(NSString*)token andTagType:(NSInteger)type andTagName:(NSString*)content withStartIndex:(NSInteger)startIndex finishedBlock:(queryFinishedBlock)block {

    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:token forKey:@"auth_token"];
    [dic setValue:user_id forKey:@"user_id"];
    [dic setValue:[NSNumber numberWithInteger:type] forKey:@"tag_type"];
    [dic setValue:content forKey:@"tag_name"];
    [dic setValue:[NSNumber numberWithInteger:startIndex] forKey:@"skip"];
    
    NSError * error = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:[TAG_HOST_DOMAIN stringByAppendingString:TAG_QUERY]]];
    
    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSArray* reVal = [result objectForKey:@"result"];
        NSNumber*  time = [result objectForKey:@"date"];
        _querydata = [QueryContent refrashLocalQueryDataInContext:_doc.managedObjectContext withData:reVal andTimeSpan:time.longLongValue];
        block(YES);
        
    } else {
//        NSDictionary* reError = [result objectForKey:@"error"];
//        NSString* msg = [reError objectForKey:@"message"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//        [alert show];
        block(NO);
    }
    return nil;
}

- (NSArray*)appendTagContentsByUser:(NSString*)user_id withToken:(NSString*)token andTagType:(NSInteger)type andTagName:(NSString*)content withStartIndex:(NSInteger)startIndex finishedBlock:(queryFinishedBlock)block {
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:token forKey:@"auth_token"];
    [dic setValue:user_id forKey:@"user_id"];
    [dic setValue:[NSNumber numberWithInteger:type] forKey:@"tag_type"];
    [dic setValue:content forKey:@"tag_name"];
    [dic setValue:[NSNumber numberWithInteger:startIndex] forKey:@"skip"];

    NSNumber* time = [QueryContent enumContentTimeSpanInContext:_doc.managedObjectContext];
    [dic setValue:time forKey:@"date"];
    
    NSError * error = nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dic copy] options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary* result = [RemoteInstance remoteSeverRequestData:jsonData toUrl:[NSURL URLWithString:[TAG_HOST_DOMAIN stringByAppendingString:TAG_QUERY]]];
    
    if ([[result objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSArray* reVal = [result objectForKey:@"result"];
        _querydata = [QueryContent appendLocalQueryDataInContext:_doc.managedObjectContext withData:reVal];
        block(YES);
        
    } else {
//        NSDictionary* reError = [result objectForKey:@"error"];
//        NSString* msg = [reError objectForKey:@"message"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//        [alert show];
        block(NO);
    }
    return nil;
}
@end
