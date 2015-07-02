//
//  HomeDetailViewController.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 12/01/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "HomeDetailViewController.h"
#import "QueryContent+ContextOpt.h"
#import "TmpFileStorageModel.h"
#import "QueryContentItem.h"
#import "HomeCommentsController.h"
#import "QueryComments.h"
#import "UserProfileViewController.h"

#pragma mark -- cells
#import "QueryCommentsCell.h"
#import "QueryDetailImageCell.h"
#import "QueryLikesCell.h"
#import "CommentsHeaderAndFooterCell.h"
#import "QueryOwnerCell.h"
#import "QueryDescriptionCell.h"

#pragma mark -- for animation
#import "INTUAnimationEngine.h"
#import "AppDelegate.h"

#pragma mark -- for tags
#import "QueryContentTag.h"
#import "HomeTagsController.h"

#pragma mark -- secter numbers
#define REFERSH_HEADER                  0
#define OWNER_NAME_SECTOR               1
#define ITEM_SECTOR                     2
#define OWNER_DESCRIPTION_SECTOR        3
#define LIKES_SECTOR                    4
#define HOT_COMMENTS_TITLE_SECTOR       5
#define HOT_COMMENTS_SECTOR             6
#define RESENT_COMMENTS_TITLE_SECTOR    7
#define RESENT_COMMENTS_SECTOR          8
#define APPEND_FOOTER                   9

#define TOTAL_SECTORS                   10

#define CHECK_SECTOR(lhs, rhs)        \
    if (lhs == rhs) break;

@interface HomeDetailViewController () {
    NSArray* comments_array;
    
    BOOL isLoading;
}
@property (weak, nonatomic) IBOutlet UITableView *queryView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@end

@implementation HomeDetailViewController {
    NSInteger selected_tag_type;
    NSString* selected_tag_name;
}

@synthesize queryView = _queryView;
@synthesize inputView = _inputView;

@synthesize qm = _qm;
@synthesize current_content = _current_content;
@synthesize current_user_id = _current_user_id;
@synthesize current_auth_token = _current_auth_token;

#pragma mark -- only for move play
@synthesize player = _player;
@synthesize current_image = _current_image;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    comments_array = [_current_content.comments.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([((QueryComments*)obj1).comment_date timeIntervalSince1970] <= [((QueryComments*)obj2).comment_date timeIntervalSince1970])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    
    /**
     * comments header and footer
     */
    [_queryView registerNib:[UINib nibWithNibName:@"CommentsHeaderAndFooterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"comments header and footer"];
    
    /**
     * comments cell
     */
    [_queryView registerNib:[UINib nibWithNibName:@"QueryCommentsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"comments cell"];
    
    /**
     * detail image cell
     */
    [_queryView registerNib:[UINib nibWithNibName:@"QueryDetailImageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"detail image cell"];
    
    /**
     * owner cell
     */
    [_queryView registerNib:[UINib nibWithNibName:@"QueryOwnerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"owner cell"];
    
    /**
     * likes cell
     */
    [_queryView registerNib:[UINib nibWithNibName:@"QueryLikesCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"likes photo cell"];
    
    /**
     * owner description cell
     */
    [_queryView registerNib:[UINib nibWithNibName:@"QueryDescriptionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"owner description cell"];

//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishDownloadImage:) name:@"download finish" object:nil];
    
    _inputView.delegate = self;
    isLoading = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -- table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selet row");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSInteger range = [self checkRangeNameWithIndex:indexPath.row];
    
    switch (range) {
        case REFERSH_HEADER:
        case APPEND_FOOTER:
            return 44;
            
        case OWNER_NAME_SECTOR:
            return 46;
            
        case ITEM_SECTOR:
            return [QueryDetailImageCell getPerferCellHeight];
            
        case OWNER_DESCRIPTION_SECTOR:
            return 46;
            
        case LIKES_SECTOR:
            return 44;
            
        case HOT_COMMENTS_TITLE_SECTOR:
            return 36;
            
        case RESENT_COMMENTS_TITLE_SECTOR:
            return 36;
            
        case HOT_COMMENTS_SECTOR:
        case RESENT_COMMENTS_SECTOR:
            return 101;
            
        default:
            NSLog(@"wrong with ranges");
            return -1;
    }
//    
//    NSInteger item_count = _current_content.items.count;
//    NSInteger index = indexPath.row;
//    NSInteger height = 0;
//    NSInteger hot_comment_count = [self enumMostPopularCommentsCount];
//    if (index >= 0 && index < item_count) {
//        height = 241; // image
//    } else if (index == item_count) {
//        height = 133; // owner
//    } else if (index == item_count + 1) {
//        height = 44; // like
//    } else if (index == item_count + 2) {
//        height = 30; // comment header
//    } else if (index > item_count + 2 && index < item_count + 3 + hot_comment_count) {
//        height = 133; // comment
//    } else if (index == item_count + 3 + hot_comment_count) {
//        height = 30; // comment footer
//    } else {
//        // todo: related items
//        NSLog(@"error");
//    }
//    
//    return height;
}

#pragma mark -- table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    NSInteger range = [self checkRangeNameWithIndex:indexPath.row];
    
    switch (range) {
        case REFERSH_HEADER:
            return [self queryDefaultCellInitWithTableView:tableView withTitle:@"refreshing ..."];
        case APPEND_FOOTER:
            return [self queryDefaultCellInitWithTableView:tableView withTitle:@"more comments ..."];
            
        case OWNER_NAME_SECTOR:
            return [self queryOwnerCellInitWithTableView:tableView];
            
        case ITEM_SECTOR: {
            NSRange r = [self rangeOfSector:range];
            NSInteger item_index = indexPath.row - r.location;
            return [self queryImageCellInitWithTableView:tableView andIndex:item_index];
            }
            
        case OWNER_DESCRIPTION_SECTOR:
            return [self queryDescriptionCellInitWithTableView:tableView];
            
        case LIKES_SECTOR:
            return [self queryLikesCellInitWithTableView:tableView];
            
        case HOT_COMMENTS_TITLE_SECTOR:
            return [self queryCommentsTitleWithTableView:tableView andTitle:@"Hot Comments"];
            
        case HOT_COMMENTS_SECTOR: {
            NSRange r = [self rangeOfSector:range];
            NSInteger comment_index = indexPath.row - r.location;
            return [self queryCommentsCellWithTableView:tableView andIndex:comment_index];
            }
    
        case RESENT_COMMENTS_TITLE_SECTOR:
            return [self queryCommentsTitleWithTableView:tableView andTitle:@"Resent Comments"];
            
        case RESENT_COMMENTS_SECTOR: {
            NSRange r = [self rangeOfSector:range];
            NSInteger comment_index = indexPath.row - r.location;
            return [self queryCommentsCellWithTableView:tableView andIndex:comment_index];
            }
            
        default:
            NSLog(@"wrong with ranges");
            return nil;
    }
    
//    NSInteger item_count = _current_content.items.count;
//    NSInteger index = indexPath.row;
//    UITableViewCell* cell = nil;
//    NSInteger resent_comment_count = [self enumMostPopularCommentsCount];
//    if (index >= 0 && index < item_count) {
//        cell = [self queryImageCellInitWithTableView:tableView andIndex:indexPath];
//    } else if (index == item_count) {
//        cell = [self queryOwnerCellInitWithTableView:tableView];
//    } else if (index == item_count + 1) {
//        cell = [self queryLikesCellInitWithTableView:tableView];
//    } else if (index == item_count + 2) {
//        cell = [self queryCommentsHeaderCellWithTableView:tableView];
//    } else if (index > item_count + 2 && index < item_count + 3 + resent_comment_count) {
//        cell = [self queryCommentsCellWithTableView:tableView andIndex:index - item_count - 3];
//    } else if (index == item_count + 3 + resent_comment_count) {
//        cell = [self queryCommentsFooterCellWithTableView:tableView];
//    } else {
//        // todo: related items
//        NSLog(@"error");
//    }
//    
//    return cell;
}

- (NSInteger)checkRangeNameWithIndex:(NSInteger)index {
    for (NSInteger tmp = 0; tmp < TOTAL_SECTORS; ++tmp) {
        NSRange tr = [self rangeOfSector:tmp];
        if (index >= tr.location && index < tr.location + tr.length) {
            return tmp;
        }
    }
    NSLog(@"error with range");
    return -1;
}

- (NSRange)rangeOfSector:(NSInteger)secter {
    NSRange result;
    
    switch (secter) {
        case REFERSH_HEADER:
        case OWNER_NAME_SECTOR:
        case ITEM_SECTOR:
        case OWNER_DESCRIPTION_SECTOR:
        case LIKES_SECTOR:
        case HOT_COMMENTS_TITLE_SECTOR:
        case HOT_COMMENTS_SECTOR:
        case RESENT_COMMENTS_TITLE_SECTOR:
        case RESENT_COMMENTS_SECTOR:
        case APPEND_FOOTER:
            result.location = 0;
            result.length = 1;
            CHECK_SECTOR(secter,REFERSH_HEADER);
            
            result.location += result.length;
            result.length = [self enumOwnerNameCount];
            CHECK_SECTOR(secter, OWNER_NAME_SECTOR);
            
            result.location += result.length;
            result.length = [self enumItemCount];
            CHECK_SECTOR(secter, ITEM_SECTOR);
            
            result.location += result.length;
            result.length = [self enumOwnerDescriptionCount];
            CHECK_SECTOR(secter, OWNER_DESCRIPTION_SECTOR);
            
            result.location += result.length;
            result.length = [self enumLikeColCount];
            CHECK_SECTOR(secter, LIKES_SECTOR);
           
            result.location += result.length;
            result.length = [self enumMostPopularTitleCount];
            CHECK_SECTOR(secter, HOT_COMMENTS_TITLE_SECTOR);
            
            result.location += result.length;
            result.length = [self enumMostPopularCommentsCount];
            CHECK_SECTOR(secter, HOT_COMMENTS_SECTOR);
           
            result.location += result.length;
            result.length = [self enumResentsCommentsTitleCount];
            CHECK_SECTOR(secter, RESENT_COMMENTS_TITLE_SECTOR);
           
            result.location += result.length;
            result.length = [self enumResentsCommentsCount];
            CHECK_SECTOR(secter, RESENT_COMMENTS_SECTOR);

            result.location += result.length;
            result.length = 1;
            CHECK_SECTOR(secter, APPEND_FOOTER);
      
        default:
            NSLog(@"wrong with ranges");
            break;
    }
    return result;
}

- (NSInteger)enumOwnerNameCount { return 1; }
- (NSInteger)enumItemCount { return _current_content.items.count; }
- (NSInteger)enumOwnerDescriptionCount { return 1; }
- (NSInteger)enumLikeColCount { return 1; }
- (NSInteger)enumMostPopularTitleCount { return 1; }
- (NSInteger)enumMostPopularCommentsCount {
    return MIN(2, _current_content.comments.count);
}
- (NSInteger)enumResentsCommentsTitleCount { return 1; }
- (NSInteger)enumResentsCommentsCount { return _current_content.comments.count; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return 1 + [self enumOwnerNameCount] // Owner name Sector
         + [self enumItemCount] // item (photo or movie)
         + [self enumOwnerDescriptionCount] // owner description input
         + [self enumLikeColCount]      // like coloum
         + [self enumMostPopularTitleCount]     // title says hot comments
         + [self enumMostPopularCommentsCount]  // hot comment
         + [self enumResentsCommentsTitleCount] // resent comments title
         + [self enumResentsCommentsCount] + 1;      // all comments goes here
    
//    return [_current_content.items count]  /*image count*/ + 1 /*name area*/ + 1 /*like area*/ + 1 /*comments header*/ + [self enumMostPopularCommentsCount] /*comments*/ + 1 /*comments footer*/;
}

- (void)dealloc {
    ((UIScrollView*)_queryView).delegate = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 假设偏移表格高度的20%进行刷新
    // 假设偏移表格高度的20%进行刷新
    if (!isLoading) { // 判断是否处于刷新状态，刷新中就不执行
        // 取内容的高度：
        // 如果内容高度大于UITableView高度，就取TableView高度
        // 如果内容高度小于UITableView高度，就取内容的实际高度
        float height = scrollView.contentSize.height > _queryView.frame.size.height ?_queryView.frame.size.height : scrollView.contentSize.height;
        if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.2) { // 调用上拉刷新方
            
            isLoading = YES;
            NSInteger skip = _current_content.comments.count;
            // append comments
            CGRect rc = _queryView.frame;
            rc.origin.y = rc.origin.y - 44;
            [_queryView setFrame:rc];
            _current_content = [_qm appendCommentsByUser:_current_user_id withToken:_current_auth_token andBeginIndex:skip andPostID:_current_content.content_post_id];
            rc.origin.y = rc.origin.y + 44;
            [_queryView setFrame:rc];
            //            [_queryView reloadData];
            [self commentUpdate:nil];
            isLoading = NO;
        }
        
        if (- scrollView.contentOffset.y / _queryView.frame.size.height > 0.2) { // 调用下拉刷新方法
            
            // refresh comments
            isLoading = YES;
            CGRect rc = _queryView.frame;
            rc.origin.y = rc.origin.y + 44;
            [_queryView setFrame:rc];
            
            _current_content = [_qm refreshCommentsByUser:_current_user_id withToken:_current_auth_token andPostID:_current_content.content_post_id];
            rc.origin.y = rc.origin.y - 44;
            [_queryView setFrame:rc];
            //            [_queryView reloadData];
            [self commentUpdate:nil];
            isLoading = NO;
        }
    }
}

#pragma mark -- private
- (QueryDescriptionCell*)queryDescriptionCellInitWithTableView:(UITableView*)tableView {
    
    QueryDescriptionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"owner description cell"];
    
    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"QueryDescriptionCell" owner:self options:nil];
        cell = [nib firstObject];
    }
    
    cell.user_description.text = _current_content.content_description;
    cell.content_tags.text = @"alfred test";
    
    return cell;
}

- (QueryDetailImageCell*)queryImageCellInitWithTableView:(UITableView*)tableView andIndex:(NSInteger)index {
    
    QueryDetailImageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"detail image cell"];
   
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryDetailImageCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    QueryContentItem* item = [_current_content.items.allObjects objectAtIndex:index];
    
    if (item.item_type.integerValue != PostPreViewMovie) {
        //    cell.imgView.image =[TmpFileStorageModel enumImageWithName:item.item_name withTableView:tableView inIndex:indexPath];
        cell.imgView.image =[TmpFileStorageModel enumImageWithName:item.item_name withDownLoadFinishBolck:^(BOOL success, UIImage *download_img) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cell) {
                        cell.imgView.image = download_img;
                        NSLog(@"change img success");
                    }
                });
            } else {
                NSLog(@"down load image %@ failed", item.item_name);
            }
        }];
        
        /**
         * only add tags on the first image item
         */
        if (index == 0) {
            for (QueryContentTag* tag in _current_content.tags.allObjects) {
                [cell addTagWithType:tag.tag_type.integerValue andContent:tag.tag_content withPositionX:tag.tag_offset_x.doubleValue andPositionY:tag.tag_offset_y.doubleValue];
            }
        }
    } else {
        cell.type = item.item_type.integerValue;
        cell.imgView.image = _current_image;
        cell.player = _player;
    }
        
    cell.delegate = self;
    return cell;
}

- (UITableViewCell*)queryDefaultCellInitWithTableView:(UITableView*)tableView withTitle:(NSString*)title {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    }
    
    cell.textLabel.text = title;
    return cell;
}

- (QueryOwnerCell*)queryOwnerCellInitWithTableView:(UITableView*)tableView {
    QueryOwnerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"owner cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryOwnerCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    cell.owner_name.text = _current_content.owner_name;
//    cell.owner_img.backgroundColor = [UIColor greenColor];
    cell.owner_img.image =[TmpFileStorageModel enumImageWithName:_current_content.owner_photo withDownLoadFinishBolck:^(BOOL success, UIImage *download_img) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell) {
                    cell.owner_img.image = download_img;
                    NSLog(@"change img success");
                }
            });
        } else {
            NSLog(@"down load image %@ failed", _current_content.owner_photo);
            NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
            NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
            NSString * filePath = [resourceBundle pathForResource:[NSString stringWithFormat:@"User"] ofType:@"png"];
            UIImage *image = [UIImage imageNamed:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell) {
                    cell.owner_img.image = image;
                }
            });
        }
    }];
    cell.owner_tags.text = @"Unknown";
    cell.content_share_number.text = [[NSNumber numberWithInt:1000] stringValue];
    // date
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.formatterBehavior = NSDateFormatterBehavior10_4;
//    formatter.dateStyle = NSDateFormatterShortStyle;
//    formatter.timeStyle = NSDateFormatterShortStyle;
//    NSString *result = [formatter stringForObjectValue:_current_content.content_post_date];
//    cell.post_date.text = result;

    cell.delegate = self;
    return cell;
}

- (QueryLikesCell*)queryLikesCellInitWithTableView:(UITableView*)tableView {
     QueryLikesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"likes photo cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryLikesCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
   
    cell.likesLabel.text = [NSString stringWithFormat:@"%d likes", _current_content.likes_count.intValue];
    [cell setPhotoNameList:_current_content];
    cell.delegate = self;
    
    return cell;   
}

- (CommentsHeaderAndFooterCell*)queryCommentsTitleWithTableView:(UITableView*)tableView andTitle:(NSString*)title {
    
    CommentsHeaderAndFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comments header and footer"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsHeaderAndFooterCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
   
    cell.messageLabel.text = title;
    cell.state = CommentsHeaderAndFooterStatesHeader;
    return cell;
}

- (QueryCommentsCell*)queryCommentsCellWithTableView:(UITableView*)tableView andIndex:(NSInteger)index {
    QueryCommentsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comments cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryCommentsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
   
//    QueryComments* item = [_current_content.comments.allObjects objectAtIndex:index];
    if (comments_array.count > 0) {

        QueryComments* item = [comments_array objectAtIndex:index];
        cell.current_comments = item;

        cell.commentField.text = item.comment_content;
        cell.owner_name_label.text = item.comment_owner_name;
    
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.formatterBehavior = NSDateFormatterBehavior10_4;
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        NSString *result = [formatter stringForObjectValue:item.comment_date];
        cell.comment_post_date_label.text = result;
            
        [cell setCommentOwnerImg:nil];
    }
    
    return cell;
}

//- (CommentsHeaderAndFooterCell*)queryCommentsFooterCellWithTableView:(UITableView*)tableView {
//    
//    CommentsHeaderAndFooterCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comments header and footer"];
//    
//    if (cell == nil) {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsHeaderAndFooterCell" owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
//   
//    cell.messageLabel.text = @"More Comments";
//    cell.state = CommentsHeaderAndFooterStatesFooter;
//    cell.delegate = self;
//    return cell;
//}


#pragma mark -- QueryDetailActionDelegate
- (void)didSelectDetialImageTagsWithContents:(NSString*)tag_name {
    NSLog(@"tag select with %@", tag_name);
}

- (void)didSelectDetialFollowOwner {
    NSLog(@"folow");
}

- (void)didSelectDetialOwnerNameOrImage:(NSString*)owner_id {
    NSLog(@"owner details with id: %@", owner_id);
    [self performSegueWithIdentifier:@"Detial2ProfileSegue" sender:owner_id];
}

- (void)didSelectDetialLikeBtn {
    NSLog(@"like this post");
}

- (void)didSelectDetialCommentDetailWithIndex:(NSInteger)index {
    NSLog(@"select %ld comments", (long)index);
}

- (void)didSelectDetialMoreComments {
    NSLog(@"show all comments");
    [self performSegueWithIdentifier:@"MoreCommentsSegue" sender:nil];
}

- (void)didSelectTagWithType:(NSInteger)type andName:(NSString*)name {
    NSLog(@"show all tags content");
    selected_tag_type = type;
    selected_tag_name = name;
    [self performSegueWithIdentifier:@"tagSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MoreCommentsSegue"]) {
        ((HomeCommentsController*)(segue.destinationViewController)).qm = self.qm;
        ((HomeCommentsController*)(segue.destinationViewController)).current_content = _current_content;
        ((HomeCommentsController*)(segue.destinationViewController)).current_user_id = _current_user_id;
        ((HomeCommentsController*)(segue.destinationViewController)).current_auth_token = _current_auth_token;
        
    } else if ([segue.identifier isEqualToString:@"Detial2ProfileSegue"]) {
       
        ((UserProfileViewController*)segue.destinationViewController).onwer_id = (NSString*)sender;
    } else if ([segue.identifier isEqualToString:@"tagSegue"]) {
        ((HomeTagsController*)segue.destinationViewController).tag_name = selected_tag_name;
        ((HomeTagsController*)segue.destinationViewController).tag_type = selected_tag_type;
    }
}

#pragma mark -- text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag==0) {
        [self moveView:-250];
    }
    
    if (textField.tag==1) {
        [self moveView:-600];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag==0) {
        [self moveView:250];
    }
    
    if (textField.tag==1) {
        [self moveView:600];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (![_inputView.text isEqualToString:@""]) {
        [self postComment];
        _inputView.text = @"";
    }
    [_inputView resignFirstResponder];
    return NO;
}

- (void)moveView:(float)move
{
    static const CGFloat kAnimationDuration = 0.30; // in seconds
    CGRect frame = self.view.frame;
    //    CGRect frameNew = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + move);
    CGRect frameNew = CGRectMake(0, 0, frame.size.width, frame.size.height + move);
    [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                       delay:0.0
                                      easing:INTUEaseInOutQuadratic
                                     options:INTUAnimationOptionNone
                                  animations:^(CGFloat progress) {
                                      self.view.frame = INTUInterpolateCGRect(frame, frameNew, progress);
                                      
                                      // NSLog(@"Progress: %.2f", progress);
                                  }
                                  completion:^(BOOL finished) {
                                      // NOTE: When passing INTUAnimationOptionRepeat, this completion block is NOT executed at the end of each cycle. It will only run if the animation is canceled.
                                      NSLog(@"%@", finished ? @"Animation Completed" : @"Animation Canceled");
                                      //                                                         self.animationID = NSNotFound;
                                  }];
}

#pragma mark -- post comments
- (IBAction)postComment {
    NSLog(@"post Comment");
    /**
     * 1. check post is validate or not
     */
    /**
     * 2. post comment to the service
     */
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    _current_content = [delegate.pm postCommentToServiceWithPostID:_current_content.content_post_id andCommentContent:_inputView.text];
    
    /**
     * 3. refresh local comment database via return value
     */
    [self commentUpdate:nil];
    [_queryView reloadData];
}

- (void)commentUpdate:(NSNotification*)sender {
    NSLog(@"update success");
    //    _current_content = [QueryContent enumQueryContentByPostID:_current_content.content_post_id inContext:_qm.doc.managedObjectContext];
    
    comments_array = [_current_content.comments.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([((QueryComments*)obj1).comment_date timeIntervalSince1970] <= [((QueryComments*)obj2).comment_date timeIntervalSince1970])
            return NSOrderedDescending;
        else
            return NSOrderedAscending;
    }];
    [_queryView reloadData];
}
@end
