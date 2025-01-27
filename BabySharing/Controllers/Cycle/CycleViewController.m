//
//  CycleViewController.m
//  BabySharing
//
//  Created by Alfred Yang on 12/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import "CycleViewController.h"
#import "AppDelegate.h"
#import "LoginModel.h"
#import "MessageModel.h"
#import "DropDownMenu.h"
#import "WEPopoverController.h"
#import "MyCycleCellHeader.h"

#import "CycleAddDescriptionViewController.h"
#import "CycleDetailController.h"

#import "Reachability.h"
#import "CycleOverCell.h"
#import "Targets.h"

#import "ChatGroupController.h"

@interface CycleViewController () <UITableViewDataSource, UITableViewDelegate, DropDownMenuProcotol, WEPopoverControllerDelegate, UIPopoverControllerDelegate, createUpdateDetailProtocol>
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UITableView *cycleTableView;

@property (weak, nonatomic) LoginModel* lm;
@property (weak, nonatomic) MessageModel* mm;
@property (weak, nonatomic) Reachability* ry;

@property (weak, nonatomic) id<CycleSyncDataProtocol> notifyObject;
@end

@implementation CycleViewController {
	WEPopoverController *popoverController;
    
    NSMutableDictionary* dic_description;
    BOOL isSync;
    
    BOOL isRecommmend;
    
    NSArray* chatGroupArray_mine;
    NSArray* chatGroupArray_recommend;
}

@synthesize descriptionView = _descriptionView;
@synthesize cycleTableView = _cycleTableView;

@synthesize lm = _lm;
@synthesize mm = _mm;
@synthesize ry = _ry;

@synthesize notifyObject = _notifyObject;

- (void)viewDidLoad {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f]];

    _cycleTableView.dataSource = self;
    _cycleTableView.delegate = self;
    [_cycleTableView registerNib:[UINib nibWithNibName:@"CycleOverCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cycle over cell"];
    [_cycleTableView registerClass:[MyCycleCellHeader class] forHeaderFooterViewReuseIdentifier:@"my cycle header"];

    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    NSString* str = @"丰富自己的描述，找到属于自己的圈子";
    UIFont* font = [UIFont systemFontOfSize:17.f];
    CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
//    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, size.height + 10)];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 66)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = str;
//    label.center = CGPointMake(width / 2, height / 2 - 100);
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f];
    [_descriptionView addSubview:label];
    
//    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width * 0.6, 30)];
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
//    btn.layer.borderWidth = 1.f;
//    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.layer.cornerRadius = 50.f;
    btn.clipsToBounds = YES;
   
    CALayer* outer_layer = [CALayer layer];
    outer_layer.backgroundColor = [UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:0.3].CGColor;
    outer_layer.bounds = CGRectMake(0, 0, 100, 100);
    outer_layer.position = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
    [btn.layer addSublayer:outer_layer];
    
    CALayer* mid_layer = [CALayer layer];
    mid_layer.backgroundColor = [UIColor colorWithRed:0.3126 green:0.7529 blue:0.8941 alpha:1.f].CGColor;
    mid_layer.bounds = CGRectMake(0, 0, 80, 80);
    mid_layer.cornerRadius = mid_layer.bounds.size.width / 2;
    mid_layer.masksToBounds = YES;
    mid_layer.position = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
    [btn.layer addSublayer:mid_layer];

    CALayer* inner_layer = [CALayer layer];
    inner_layer.backgroundColor = [UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f].CGColor;
    inner_layer.bounds = CGRectMake(0, 0, 60, 60);
    inner_layer.cornerRadius = inner_layer.bounds.size.width / 2;
    inner_layer.masksToBounds = YES;
    inner_layer.position = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
    [btn.layer addSublayer:inner_layer];
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"描述" forState:UIControlStateNormal];
    [btn setFont:[UIFont systemFontOfSize:14.f]];
//    btn.center = CGPointMake(label.center.x, label.center.y + 25);
    btn.center = CGPointMake(width / 2, height / 2 - 100);
    [_descriptionView addSubview:btn];
    [btn addTarget:self action:@selector(addDescriptionBtnSelected) forControlEvents:UIControlEventTouchDown];
    
    UILabel* label_2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, size.height + 10)];
    label_2.textAlignment = NSTextAlignmentCenter;
    label_2.text = @"了解更多";
    label_2.textColor = [UIColor redColor];
    label_2.center = CGPointMake(btn.center.x, btn.center.y + 100);
    [_descriptionView addSubview:label_2];
    
    UILabel* label_3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, size.width + 10)];
    label_3.textAlignment = NSTextAlignmentCenter;
    label_3.text = @"... ...";
    label_3.textColor = [UIColor redColor];
    label_3.center = CGPointMake(btn.center.x, btn.center.y + 100 + size.height + 20);
    [_descriptionView addSubview:label_3];
   
    _descriptionView.backgroundColor = [UIColor whiteColor];
   
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString* filepath = [resourceBundle pathForResource:@"Plus2" ofType:@"png"];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:filepath] style:UIBarButtonItemStylePlain target:self action:@selector(plusBtnSelected:)];
    
    self.preferredContentSize = CGSizeMake(100, 100);
    
    
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _lm = app.lm;
    _mm = app.mm;
    _ry = app.reachability;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    isRecommmend = YES;
    isSync = NO;
  
    if (_ry.isReachable) {
        [self resetDataForViews];
    }
    
    UILabel* label_t = [[UILabel alloc]init];
    label_t.text = @"圈子";
    label_t.textColor = [UIColor whiteColor];
    [label_t sizeToFit];
    self.navigationItem.titleView = label_t;
   
    UIButton* barBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, 32, 30, 25)];
//    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
//    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
//    NSString* filepath = [resourceBundle pathForResource:@"Previous_blue" ofType:@"png"];
//    NSString* filepath = [resourceBundle pathForResource:@"Previous_simple" ofType:@"png"];
    CALayer * layer = [CALayer layer];
    layer.contents = (id)[UIImage imageNamed:filepath].CGImage;
    layer.frame = CGRectMake(0, 0, 25, 25);
    layer.position = CGPointMake(10, barBtn.frame.size.height / 2);
    [barBtn.layer addSublayer:layer];
//    [barBtn setBackgroundImage:[UIImage imageNamed:filepath] forState:UIControlStateNormal];
//    [barBtn setImage:[UIImage imageNamed:filepath] forState:UIControlStateNormal];
    [barBtn addTarget:self action:@selector(plusBtnSelected:) forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:barBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    dic_description = [[_lm currentDeltailInfoLocal] mutableCopy];
    chatGroupArray_mine = [_mm enumMyChatGroupLocal];
    chatGroupArray_recommend = [_mm enumRecommendChatGroupLocal];
    [self viewDidLayoutSubviews];
    
}

- (void)reachabilityChanged:(Reachability*)sender {
    
    if (self.tabBarController.selectedIndex != 1) return;
    
    if ([sender isReachable]) {
        [self resetDataForViews];

    } else if (![sender isReachable]) {
        isSync = NO;
        [_notifyObject detailInfoSynced:isSync];
    }
}

- (void)resetDataForViews {
    [_lm currentDeltailInfoAsyncWithFinishBlock:^(BOOL success, NSDictionary * dic) {
        if (success) {
            dic_description = [dic mutableCopy];
            [_lm updateDetailInfoLocalWithData:dic];
            [_mm enumChatGroupWithFinishBlock:^(BOOL success, NSArray* result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    chatGroupArray_mine = [_mm enumMyChatGroupLocal];
                    chatGroupArray_recommend = [_mm enumRecommendChatGroupLocal];
                    [_cycleTableView reloadData];
                });
            }];
            if (dic_description.count > 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self resetViews];
                });
            }
            isSync = YES;
            [_notifyObject detailInfoSynced:isSync];
        }
    }];
}

- (BOOL)isDescriptionValidate {
    return dic_description && dic_description.count > 1 && ((NSNumber*)[dic_description objectForKey:@"age"]).integerValue > 0 && ((NSArray*)[dic_description objectForKey:@"kids"]).count > 0;
}

- (void)resetViews {
//    if (dic_description && dic_description.count > 1) {
    if ([self isDescriptionValidate]) {
        _cycleTableView.hidden = NO;
        _descriptionView.hidden = YES;
    } else {
        _cycleTableView.hidden = YES;
        _descriptionView.hidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
   
    CGRect rc = CGRectMake(0, 20 + 44, width, height - 44 - 49);
    _descriptionView.frame = rc;
    _cycleTableView.frame = rc;
    
    [self resetViews];
}

- (BOOL)hasViewDescription {
    return [_lm isCurrentHasDetailInfo];
//    return YES;
}

- (void)addDescriptionBtnSelected {
    [self performSegueWithIdentifier:@"addDescription" sender:nil];
}

#pragma mark -- table view delegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // TODO: segue to user chat
    [self performSegueWithIdentifier:@"enterChatGroup" sender:indexPath];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isRecommmend) return 2;
    else return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* reVal = [[UIView alloc]init];
    reVal.backgroundColor = [UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f];
    
    UILabel* label = [[UILabel alloc]init];
    
    if (section == 0) {
        label.text = @"我的圈子";
    } else {
        label.text = @"猜你喜欢";
    }
   
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    [reVal addSubview:label];
   
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 44;
    
    label.center = CGPointMake(width / 2 , height / 2);
    
    return reVal;
    
//    if (section == 0) {
//        MyCycleCellHeader* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"my cycle header"];
//        if (header == nil) {
//            header = [[MyCycleCellHeader alloc]init];
//        }
//       
//        header.role_tag = @"tags";
//        [header viewLayoutSubviews];
//        return header;
//        
//    } else if (section == 1) {
//        return nil;
//        
//    } else {
//        return nil;
//    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [MyCycleCellHeader preferHeight];
    } else {
        return 44;
    }
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        return @"推荐";
//    } return nil;
//}

#pragma mark -- table view datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CycleOverCell preferredHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return chatGroupArray_mine.count;
    else return chatGroupArray_recommend.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    CycleOverCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cycle over cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CycleOverCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    Targets* tmp = nil;
    if (indexPath.section == 0) {
        tmp = [chatGroupArray_mine objectAtIndex:indexPath.row];
    } else {
        tmp = [chatGroupArray_recommend objectAtIndex:indexPath.row];
    }
    
    cell.numLabel.text = @"7";
    cell.themeLabel.text = tmp.target_name;
    
    return cell;
}

- (void)plusBtnSelected:(id)sender {

    if (!popoverController) {
     
        NSArray* arr = nil;
//        if (_descriptionView.hidden == NO) {
            arr = @[@"创建圈子", @"编辑描述", @"更多推荐", @"取消"];
//        } else {
//            if (isRecommmend) arr = @[@"编辑描述", @"更多推荐", @"关闭圈子推荐", @"取消"];
//            else arr = @[@"编辑描述", @"更多推荐", @"开启圈子推荐", @"取消"];
//        }
        
//        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        DropDownMenu* menu = [[DropDownMenu alloc]init];
        [menu setMenuText:arr];
        menu.dropdownDelegate = self;
        
        popoverController = [[WEPopoverController alloc] initWithContentViewController:menu];
        popoverController.delegate = self;
        popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
        
//        [popoverController presentPopoverFromBarButtonItem:sender
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
                                  permittedArrowDirections:(UIPopoverArrowDirectionUp)
                                                  animated:YES];
        
    } else {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
}


#pragma mark -- drop down menu
- (void)dropDownMenu:(DropDownMenu *)menu didSelectMuneItemAtIndex:(NSInteger)index {
   
//    if (_descriptionView.hidden == NO && index == 0) {
//        [self performSegueWithIdentifier:@"addCycle" sender:nil];
//    } else if (_descriptionView.hidden == YES && index == 0) {
//        [self performSegueWithIdentifier:@"addDescription" sender:nil];
//    } else if (_descriptionView.hidden == NO && index == 1) {
//        [self performSegueWithIdentifier:@"addDescription" sender:nil];
//    }
    
    if (index == 0) {
        [self performSegueWithIdentifier:@"addCycle" sender:nil];
    } else if (index == 1) {
        [self performSegueWithIdentifier:@"addDescription" sender:nil];
    }
    
    [popoverController dismissPopoverAnimated:YES];
    popoverController = nil;
}

#pragma mark -- segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ((UIViewController*)segue.destinationViewController).hidesBottomBarWhenPushed = YES;
    
    if ([segue.identifier isEqualToString:@"addCycle"]) {
    } else if ([segue.identifier isEqualToString:@"addDescription"]) {
        ((CycleAddDescriptionViewController*)segue.destinationViewController).lm = self.lm;
        ((CycleAddDescriptionViewController*)segue.destinationViewController).dic_description = dic_description;
        ((CycleAddDescriptionViewController*)segue.destinationViewController).isEditable = isSync;
        _notifyObject = (CycleAddDescriptionViewController*)segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"enterChatGroup"]) {
        
        NSIndexPath* path = (NSIndexPath*)sender;
        Targets* tmp = nil;
        if (path.section == 0) {
            tmp = [chatGroupArray_mine objectAtIndex:path.row];
        } else {
            tmp = [chatGroupArray_recommend objectAtIndex:path.row];
        }
        ((ChatGroupController*)segue.destinationViewController).group_id = tmp.group_id;
        ((ChatGroupController*)segue.destinationViewController).joiner_count = tmp.number_count;
        ((ChatGroupController*)segue.destinationViewController).group_name = tmp.target_name;
        ((ChatGroupController*)segue.destinationViewController).founder_id = tmp.owner_id;
    }
}

#pragma mark -- create update detail chat group
- (void)createUpdateChatGroup:(BOOL)success {
    if (success) {
        chatGroupArray_mine = [_mm enumMyChatGroupLocal];
        chatGroupArray_recommend = [_mm enumRecommendChatGroupLocal];
        [_cycleTableView reloadData];
    }
}
@end
