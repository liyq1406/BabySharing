//
//  PersonalCentreTmpViewController.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 23/01/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "PersonalCentreTmpViewController.h"
#import "AppDelegate.h"
#import "LoginModel.h"
#import "TmpFileStorageModel.h"
#import "ProfileDetailController.h"

@interface PersonalCentreTmpViewController ()
@property (weak, nonatomic, readonly) NSString* current_user_id;
@property (weak, nonatomic, readonly) NSString* current_auth_token;
@property (weak, nonatomic) IBOutlet UITableView *selfTabeView;
@end

#define TITLE 0
#define IMAGE 1

@implementation PersonalCentreTmpViewController {
    NSArray* section_content;
    UIImage* next_indicator;
}

@synthesize current_auth_token = _current_auth_token;
@synthesize current_user_id = _current_user_id;
@synthesize selfTabeView = _selfTabeView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _current_user_id = delegate.lm.current_user_id;
    _current_auth_token = delegate.lm.current_auth_token;
  
    /**
     * Profile Header Cell
     */
    [_selfTabeView registerNib:[UINib nibWithNibName:@"ProfileUserHeaderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Profile Header Cell"];
    
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    UIImage *image0 = [UIImage imageNamed:[resourceBundle pathForResource:@"Share" ofType:@"png"]];
    UIImage *image1 = [UIImage imageNamed:[resourceBundle pathForResource:@"Tag" ofType:@"png"]];
    UIImage *image2 = [UIImage imageNamed:[resourceBundle pathForResource:@"Like" ofType:@"png"]];
    UIImage *image3 = [UIImage imageNamed:[resourceBundle pathForResource:@"Dropbox" ofType:@"png"]];
    UIImage *image4 = [UIImage imageNamed:[resourceBundle pathForResource:@"Info" ofType:@"png"]];
    UIImage *image5 = [UIImage imageNamed:[resourceBundle pathForResource:@"Setting" ofType:@"png"]];

    next_indicator = [UIImage imageNamed:[resourceBundle pathForResource:@"Next2" ofType:@"png"]];
    
    section_content = @[@[@[@"分享", @"标签", @"收集", @"讨论组"], @[image0, image1, image2, image3]], @[@[@"反馈信息中心", @"设置"], @[image4, image5]]];
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

//- (IBAction)didSelectSignOutBtn {
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"current user sign out" object:nil];
//}

#pragma mark -- table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selet row");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            break;
            
        case 1:
        case 2: {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Implement" message:@"个人页面布局待定" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert show];
            }
            break;
        case 3:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"current user sign out" object:nil];
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL result = NO;
    switch (indexPath.section) {
        case 0:
            result = NO;
            break;
            
        case 1:
            result = YES;
            break;
            
        case 2:
            result = YES;
            break;
        case 3:
            result = YES;
            break;
        default:
            break;
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 0;
    switch (indexPath.section) {
        case 0:
            result = 140;
            break;
            
        case 1:
            result = 44;
            break;
            
        case 2:
            result = 44;
            break;
        case 3:
            result = 44;
        default:
            break;
    }
    return result;
}

#pragma mark -- table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    switch (indexPath.section) {
        case 0:
            return [self queryProfileUserHeaderCellInTableView:tableView];
        
        case 1:
        case 2: {
            
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            }
            
            cell.imageView.image = [((NSArray*)[((NSArray*)[section_content objectAtIndex:indexPath.section - 1]) objectAtIndex:IMAGE]) objectAtIndex:indexPath.row];
            cell.textLabel.text = [((NSArray*)[((NSArray*)[section_content objectAtIndex:indexPath.section - 1]) objectAtIndex:TITLE]) objectAtIndex:indexPath.row];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
           
            return cell;
            }
            
        case 3: {
            
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"Sign out"];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,str.length)];
            cell.textLabel.attributedText = str;
            
            return cell;
            }
            
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;
    switch (section) {
        case 0:
            result = 1;
            break;
            
        case 1:
            result = 4;
            break;
            
        case 2:
            result = 2;
            break;
        case 3:
            result = 1;
            break;
        default:
            break;
    }
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {

    NSString* result = nil;
    switch (section) {
        case 0:
            break;
           
        case 1:
            result = @"  ";
            break;
        
        case 2:
            result = @"  ";
            break;
        case 3:
            result = @"  ";
            break;
        default:
            break;
    }
    return result;
}

- (ProfileUserHeaderCell*)queryProfileUserHeaderCellInTableView:(UITableView*)tableView  {
    ProfileUserHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Profile Header Cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileUserHeaderCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
   
    cell.current_user_id = _current_user_id;
    cell.current_auth_token = _current_auth_token;
    cell.delegate = self;
    [cell updateHeaderView];

    return cell;
}

#pragma mark -- scroll refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    // 假设偏移表格高度的20%进行刷新
//    if (!_isLoading) { // 判断是否处于刷新状态，刷新中就不执行
//        // 取内容的高度：
//        // 如果内容高度大于UITableView高度，就取TableView高度
//        // 如果内容高度小于UITableView高度，就取内容的实际高度
//        float height = scrollView.contentSize.height > _queryView.frame.size.height ?_queryView.frame.size.height : scrollView.contentSize.height;
//        
//        if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.2) { // 调用上拉刷新方
//            CGRect rc = _queryView.frame;
//            rc.origin.y = rc.origin.y - 44;
//            [_queryView setFrame:rc];
//            [_qm appendQueryDataByUser:_current_user_id withToken:_current_auth_token andBeginIndex:_qm.querydata.count];
//            rc.origin.y = rc.origin.y + 44;
//            [_queryView setFrame:rc];
//            [_queryView reloadData];
//            return;
//            
//        } else if (- scrollView.contentOffset.y / _queryView.frame.size.height > 0.2) { // 调用下拉刷新方法
//            CGRect rc = _queryView.frame;
//            rc.origin.y = rc.origin.y + 44;
//            [_queryView setFrame:rc];
//            [_qm refreshQueryDataByUser:_current_user_id withToken:_current_auth_token];
//            rc.origin.y = rc.origin.y - 44;
//            [_queryView setFrame:rc];
//            [_queryView reloadData];
//            
//            return;
//        }
//        
//        
//        // move and change
//    }
}

- (void)didSelectDetailProfileBtn {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProfileDetailNib" bundle:nil];
    ProfileDetailController* profileNav = [storyboard instantiateViewControllerWithIdentifier:@"ProfileDetailNib"];
    
    profileNav.current_user_id = _current_user_id;
    profileNav.current_auth_token = _current_auth_token;
    profileNav.query_user_id = _current_user_id;
    [self.navigationController pushViewController:profileNav animated:YES];
}
@end