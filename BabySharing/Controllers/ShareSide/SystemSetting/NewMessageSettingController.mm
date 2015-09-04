//
//  NewMessageSettingController.m
//  BabySharing
//
//  Created by Alfred Yang on 3/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import "NewMessageSettingController.h"
#include <vector>

@interface NewMessageSettingController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *queryView;

@end

@implementation NewMessageSettingController {
    NSArray* titles;
    NSArray* titles_cn;
    std::vector<SEL> titles_func;
}

@synthesize queryView = _queryView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _queryView.delegate = self;
    _queryView.dataSource = self;
    
    titles = @[@"mode_science", @"mode_voice", @"mode_viber", @"notify_cycle", @"notify_p2p", @"notify_notification", @"notify_dongda"];
    titles_cn = @[@"安静模式", @"声音", @"震动", @"圈子消息通知", @"私聊消息通知", @"互动消息通知", @"咚嗒提醒通知"];
    
    titles_func.push_back(@selector(mode_science:));
    titles_func.push_back(@selector(mode_voice:));
    titles_func.push_back(@selector(mode_viber:));
    titles_func.push_back(@selector(notify_cycle:));
    titles_func.push_back(@selector(notify_p2p:));
    titles_func.push_back(@selector(notify_notification:));
    titles_func.push_back(@selector(notify_dongda:));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- setting func
- (void)mode_science:(NSNumber*)b {
    NSLog(@"science %@", b);
}

- (void)mode_voice:(NSNumber*)b {
    NSLog(@"voice %@", b);
}

- (void)mode_viber:(NSNumber*)b {
    NSLog(@"viber %@", b);
}

- (void)notify_cycle:(NSNumber*)b {
    NSLog(@"cycle %@", b);
}

- (void)notify_p2p:(NSNumber*)b {
    NSLog(@"p2p %@", b);
}

- (void)notify_notification:(NSNumber*)b {
    NSLog(@"notification %@", b);
}

- (void)notify_dongda:(NSNumber*)b {
    NSLog(@"dongda %@", b);
}

- (void)switchValueChanged:(UISwitch*)sw {
    [self performSelector:titles_func[sw.tag] withObject:[NSNumber numberWithBool:sw.on]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -- table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark -- table data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 3;
    else return  4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    }
   
    NSInteger index = -1;
    if (indexPath.section == 0) {
        index = indexPath.row;
        cell.textLabel.text = [titles_cn objectAtIndex:indexPath.row];
    } else {
        index = 3 + indexPath.row;
        cell.textLabel.text = [titles_cn objectAtIndex:3 + indexPath.row];
    }
 
    // there is a bug when more items
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
   
    UISwitch* sw = [[UISwitch alloc]initWithFrame:CGRectMake(width - 51 - 16, 6, 51, 31)];
    sw.tag = index;
    [cell addSubview:sw];
    [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

    return cell;
}
@end