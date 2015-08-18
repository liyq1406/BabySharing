//
//  MessageViewController.m
//  BabySharing
//
//  Created by Alfred Yang on 3/07/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageViewCell.h"
#import "MesssageTableDelegate.h"
#import "FriendsTableDelegate.h"
#import "INTUAnimationEngine.h"
#import "ConnectionModel.h"
#import "AppDelegate.h"
#import "DDNNotificationViewController.h"
#import "UserChatController.h"
#import "Targets.h"

@interface MessageViewController () <UISearchBarDelegate>
@property (strong, nonatomic) UITableView *friendsQueryView;
@property (strong, nonatomic) UISegmentedControl *friendSeg;
@property (strong, nonatomic) UISearchBar *friendsSearchBar;

@property (weak, nonatomic, readonly) ConnectionModel *cm;
@property (weak, nonatomic, readonly) MessageModel *mm;
@property (weak, nonatomic, readonly) LoginModel *lm;
@end

@implementation MessageViewController {
    MesssageTableDelegate* md;
    FriendsTableDelegate* fd;
    
    UISegmentedControl* title_seg;
}

@synthesize queryView = _queryView;     // message

// friends
@synthesize friendSeg = _friendSeg;
@synthesize friendsQueryView = _friendsQueryView;
@synthesize friendsSearchBar = _friendsSearchBar;

@synthesize mm = _mm; // for query messages
@synthesize cm = _cm; // for query relationships
@synthesize lm = _lm;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_queryView registerNib:[UINib nibWithNibName:@"MessageViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Message View Cell"];
    [_queryView registerNib:[UINib nibWithNibName:@"MessageNotificationCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Notificaton View Cell"];
    
    _queryView = [[UITableView alloc]init];
    [self.view addSubview:_queryView];
    md = [[MesssageTableDelegate alloc]init];
    _queryView.delegate = md;
    _queryView.dataSource = md;
    md.queryView = _queryView;
    md.current = self;
    
    _friendsQueryView = [[UITableView alloc]init];
    [self.view addSubview:_friendsQueryView];
    fd = [[FriendsTableDelegate alloc]init];
    _friendsQueryView.delegate = fd;
    _friendsQueryView.dataSource = fd;
    fd.queryView = _friendsQueryView;
    fd.current = self;
    
    _friendSeg = [[UISegmentedControl alloc]initWithItems:@[@"好友", @"关注", @"粉丝"]];
    [_friendSeg addTarget:self action:@selector(friendSegValueChanged:) forControlEvents:UIControlEventValueChanged];
    _friendSeg.selectedSegmentIndex = 0;
    [self.view addSubview:_friendSeg];
    
    _friendsSearchBar = [[UISearchBar alloc]init];
    _friendsSearchBar.delegate = self;
    for (UIView* v in _friendsSearchBar.subviews)
    {
        if ( [v isKindOfClass: [UITextField class]] )
        {
            UITextField *tf = (UITextField *)v;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            break;
        }
    }
    [self.view addSubview:_friendsSearchBar];
    
    [self layoutSubviews];
    
    title_seg = [[UISegmentedControl alloc]initWithItems:@[@"消息", @"好友"]];
    title_seg.selectedSegmentIndex = 0;
    self.navigationItem.titleView = title_seg;
    [title_seg addTarget:self action:@selector(titleSegValueChanged:) forControlEvents:UIControlEventValueChanged];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加好友" style:UIBarButtonItemStylePlain target:self action:@selector(friendsAddingBtnSelected)];
    
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _cm = app.cm;
    _lm = app.lm;
    _mm = app.mm;
    md.mm = _mm;
    md.lm = _lm;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_queryView reloadData];
}

- (void)layoutSubviews {
    CGFloat width  = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
   
    CGFloat offset_x = 0;
    CGFloat offset_y = 0;
   
    _queryView.frame = CGRectMake(offset_x, offset_y, width, height);
    offset_x += width;

#define SEARCH_BAR_HEIGHT   44
    offset_y += 64;
    _friendsSearchBar.frame = CGRectMake(offset_x, offset_y, width, SEARCH_BAR_HEIGHT);
    offset_y += SEARCH_BAR_HEIGHT;

#define SEGAMENT_HEGHT      29
    _friendSeg.frame = CGRectMake(offset_x, offset_y, width, SEGAMENT_HEGHT);
    offset_y += SEGAMENT_HEGHT;
    
    CGFloat height_last = height - offset_y;
    _friendsQueryView.frame = CGRectMake(offset_x, offset_y, width, height_last);
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"addFriends"]) {
        
    } else if ([segue.identifier isEqualToString:@"showNotifications"]) {
        ((DDNNotificationViewController*)segue.destinationViewController).lm = self.lm;
        ((DDNNotificationViewController*)segue.destinationViewController).mm = self.mm;
    } else if ([segue.identifier isEqualToString:@"startChat"]) {
        UserChatController* con = (UserChatController*)segue.destinationViewController;
        con.lm = self.lm;
        con.mm = self.mm;
      
        NSIndexPath* index = (NSIndexPath*)sender;
        GotyeOCChatTarget* gotTarget = [_mm getTargetByIndex:index.row - 1];
        Targets* tmp = [_mm enumAllTargetWithTargetID:gotTarget.name];
        if (tmp != nil) {
            con.chat_user_id = tmp.target_id;
            con.chat_user_name = tmp.target_name;
            con.chat_user_photo = tmp.target_photo;
        } else {
            con.chat_user_id = gotTarget.name;
        }
        
        con.hidesBottomBarWhenPushed = YES;
    }
}

- (void)titleSegValueChanged:(id)sender {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if (title_seg.selectedSegmentIndex == 0 && _queryView.frame.origin.x < 0) {
        [self moveContentView:width];
    } else if (title_seg.selectedSegmentIndex == 1 && _queryView.frame.origin.x >= 0) {
        [self moveContentView:-width];
    }
}

- (void)friendSegValueChanged:(id)sender {
    
    switch (_friendSeg.selectedSegmentIndex) {
        case 0: {
            [_cm queryFriendsWithUser:_lm.current_user_id andFinishBlock:^(BOOL success) {
                [fd refreshShowingListWithUserList:[_cm queryLocalFriendsWithUser:_lm.current_user_id]];
            }];}
            break;
        case 1: {
            [_cm queryFollowingWithUser:_lm.current_user_id andFinishBlock:^(BOOL success) {
                [fd refreshShowingListWithUserList:[_cm queryLocalFollowingWithUser:_lm.current_user_id]];
            }];}
            break;
        case 2: {
            [_cm queryFollowedWithUser:_lm.current_user_id andFinishBlock:^(BOOL success) {
                [fd refreshShowingListWithUserList:[_cm queryLocalFollowedWithUser:_lm.current_user_id]];
            }];}
            break;
        default:
            break;
    }
}

- (void)friendsAddingBtnSelected {
    [self performSegueWithIdentifier:@"addFriends" sender:nil];
}

- (void)moveContentView:(CGFloat)offset {
    static const CGFloat kAnimationDuration = 0.30; // in seconds
    CGPoint p_query_start = _queryView.center;
    CGPoint p_query_end = CGPointMake(p_query_start.x + offset, p_query_start.y);

    CGPoint p_friend_query_start = _friendsQueryView.center;
    CGPoint p_friend_query_end = CGPointMake(p_friend_query_start.x + offset, p_friend_query_start.y);

    CGPoint p_friend_seg_start = _friendSeg.center;
    CGPoint p_friend_seg_end = CGPointMake(p_friend_seg_start.x + offset, p_friend_seg_start.y);

    CGPoint p_friend_search_start = _friendsSearchBar.center;
    CGPoint p_friend_search_end = CGPointMake(p_friend_search_start.x + offset, p_friend_search_start.y);
    [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                       delay:0.0
                                      easing:INTUEaseInOutQuadratic
                                     options:INTUAnimationOptionNone
                                  animations:^(CGFloat progress) {
                                      _queryView.center = INTUInterpolateCGPoint(p_query_start, p_query_end, progress);
                                      _friendsQueryView.center = INTUInterpolateCGPoint(p_friend_query_start, p_friend_query_end, progress);
                                      _friendsSearchBar.center = INTUInterpolateCGPoint(p_friend_search_start, p_friend_search_end, progress);
                                      _friendSeg.center = INTUInterpolateCGPoint(p_friend_seg_start, p_friend_seg_end, progress);
                                      
                                      // NSLog(@"Progress: %.2f", progress);
                                      
                                  }
                                  completion:^(BOOL finished) {
                                      // NOTE: When passing INTUAnimationOptionRepeat, this completion block is NOT executed at the end of each cycle. It will only run if the animation is canceled.
                                      NSLog(@"%@", finished ? @"Animation Completed" : @"Animation Canceled");
                                      //                                                         self.animationID = NSNotFound;
                                      if (title_seg.selectedSegmentIndex == 1) {
                                          [self friendSegValueChanged:nil];
                                      }
                                  }];
}
@end