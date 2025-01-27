//
//  ViewController.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 16/12/2014.
//  Copyright (c) 2014 YY. All rights reserved.
//

#import "ViewController.h"
#import "LoginModel.h"

#import "LoginViewController.h"
#import "TabBarController.h"

#import "AppDelegate.h"
#import "INTUAnimationEngine.h"
#import "RegTmpToken+ContextOpt.h"
#import "NicknameInputViewController.h"
#import "AlreadLogedViewController.h"

#import "LoginInputView.h"
#import "ChooseAreaViewController.h"

#import "GotyeOCAPI.h"
#import "GotyeOCDeleget.h"

#import "RemoteInstance.h"

@interface ViewController () <LoginInputViewDelegate, AreaViewControllerDelegate, GotyeOCDelegate>

@property (nonatomic, weak) LoginModel* lm;
@property (nonatomic, weak) MessageModel* mm;
@property (nonatomic, weak) UIViewController* loginController;
@property (nonatomic, weak) TabBarController* contentController;
@property (nonatomic, weak) UIViewController* secretController;

enum DisplaySide {
    shareSide,
    secretSide,
};

@property (nonatomic) enum DisplaySide currentDispley;
@end

@implementation ViewController {
    CGPoint point;                   // for gesture
    
    BOOL isMoved;

    CGFloat h_offset;
    CGFloat v_offset_title;
    CGFloat v_offset_input;
    
    BOOL isHerMoved;
    
    NSTimer* timer;
    NSInteger seconds;
   
    /**********************************************/
//    UILabel * title;                // title
    UIImageView* title;                // title
    
    LoginInputView* inputView;
    BOOL isSNSLogin;
    
    BOOL isQueryModelReady;
    BOOL isMessageModelReady;
}

@synthesize lm = _lm;
@synthesize loginController = _loginController;
@synthesize contentController = _contentController;
@synthesize secretController = _secretController;
@synthesize currentDispley = _currentDispley;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f]];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f]];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f]];
    
    AppDelegate * del =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    _lm = del.lm;
   
    [self createSubviews];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLogedIn:) name:@"SNS login success" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogedIn:) name:@"login success" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIsReady:) name:@"app ready" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDataIsReady:) name:@"query data ready" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAndNotificationDataIsReady:) name:@"message data ready" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogedOut:) name:@"current user sign out" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changingSide:) name:@"changing side" object:nil];
   
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    isSNSLogin = NO;

    [GotyeOCAPI addListener:self];
    
    isQueryModelReady = NO;
    isMessageModelReady = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden {
    return YES; //返回NO表示要显示，返回YES将hiden
}

- (void)createSubviews {
   
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    inputView = [[LoginInputView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    inputView.delegate = self;
    
    CGFloat last_height = inputView.bounds.size.height;
    inputView.frame = CGRectMake(0, height - last_height, width, last_height);
    
    [self.view addSubview:inputView];
   
//    title = [[UILabel alloc]init];
//    title.font = [UIFont systemFontOfSize:30.f];
//    title.text = @"咚哒";
//    CGSize title_size = [title.text sizeWithFont:title.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
//    [title sizeToFit];
    title = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    title.image = [UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"DongDaHeaderLogo"] ofType:@"png"]];
    title.center = CGPointMake(width / 2, 0.15 * height);
    
    [self.view addSubview:title];
}

- (void)dealloc {
    [GotyeOCAPI removeListener:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isValidPhoneNumber:(NSString*)phoneNo inArea:(NSString*)areaCode {
//    return phoneNo.length == 11;
    return YES;
}

- (BOOL)isValidPhoneCode:(NSString*)phoneCode {
    return phoneCode.length == 5;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginSegue"]) {
        _loginController = [segue destinationViewController];
//        ((LoginViewController*)((UINavigationController*)[segue destinationViewController]).childViewControllers[0]).lm = self.lm;
    } else if ([segue.identifier isEqualToString:@"areaCode"]) {
        NSLog(@"area code controller");
        ((ChooseAreaViewController*)segue.destinationViewController).delegate = self;
        // set protocol and set comfired country code
    } else if ([segue.identifier isEqualToString:@"UserPrivacy"]) {
        // do nothing ....
        
    } else if ([segue.identifier isEqualToString:@"loginSuccessSegue"]) {
        ((NicknameInputViewController*)segue.destinationViewController).login_attr = (NSDictionary*)sender;
        ((NicknameInputViewController*)segue.destinationViewController).lm = _lm;
        ((NicknameInputViewController*)segue.destinationViewController).isSNSLogIn = isSNSLogin;
    } else if ([segue.identifier isEqualToString:@"alreadyLogSegue"]) {
        ((AlreadLogedViewController*)segue.destinationViewController).login_attr = (NSDictionary*)sender;
        ((AlreadLogedViewController*)segue.destinationViewController).lm = _lm;
    } else {
        _contentController = [segue destinationViewController];
        ((TabBarController*)[segue destinationViewController]).lm = self.lm;
        ((TabBarController*)[segue destinationViewController]).mm = self.mm;
        _loginController = nil;
        _currentDispley = shareSide;
    }
}

- (void)SNSLogedIn:(id)sender {
    NSLog(@"SNS login success");
    if ([_lm isLoginedByUser]) {
        isSNSLogin = YES;
        [self performSegueWithIdentifier:@"loginSuccessSegue" sender:[_lm getCurrentUserAttr]];
    
    } else {
        // ERROR
        NSLog(@"something error with SNS login");
    }
}

- (void)userLogedIn:(id)sender {
    NSLog(@"login success");
    isSNSLogin = NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
    
//    if (_loginController) {
//        [_loginController dismissViewControllerAnimated:YES completion:^(void){
            if ([_lm isLoginedByUser]) {
                AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                if (!isQueryModelReady) [delegate createQueryModel];
                else [self queryDataIsReady:nil];
                [delegate registerDeviceTokenWithCurrentUser];
//                [GotyeOCAPI login:_lm.current_user_id password:nil];
            }
//        }];
//    }
}

- (void)userLogedOut:(id)sender {
    NSLog(@"user login out");
    [_lm signOutCurrentUser];
    [GotyeOCAPI logout];
    if (_contentController) {
        [_contentController dismissViewControllerAnimated:YES completion:nil];
        _contentController = nil;
    }
}

- (void)appIsReady:(id)sender {
    NSLog(@"application is ready");
    
    if ([_lm isLoginedByUser]) {
        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if (!isQueryModelReady) [delegate createQueryModel];
        else [self queryDataIsReady:nil];

        [delegate registerDeviceTokenWithCurrentUser];
        [_lm onlineCurrentUser];
//        [GotyeOCAPI login:_lm.current_user_id password:nil];
    }
}

- (void)queryDataIsReady:(id)sender {
    NSLog(@"queryDataIsReady");
    NSLog(@"the login user is : %@", _lm.current_user_id);
    NSLog(@"the login user token is : %@", _lm.current_auth_token);
   
    isQueryModelReady = YES;
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!isMessageModelReady) [delegate createMessageAndNotificationModel];
    else [self messageAndNotificationDataIsReady:nil];
}

- (void)messageAndNotificationDataIsReady:(id)sender {
    NSLog(@"message is ready");
    
    isMessageModelReady = YES;
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _mm = app.mm;
    
    if (inputView.frame.origin.y + inputView.frame.size.height != [UIScreen mainScreen].bounds.size.height) {
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat last_height = inputView.bounds.size.height;
        inputView.frame = CGRectMake(0, height - last_height, inputView.bounds.size.width, last_height);
    }
 
    if (![GotyeOCAPI isOnline]) {
        [GotyeOCAPI login:_lm.current_user_id password:nil];
    } else if ([GotyeOCAPI getLoginUser].name != _lm.current_user_id) {
        [GotyeOCAPI login:_lm.current_user_id password:nil];
    }
}

- (void)changingSide:(NSNotification*)sender {
    NSLog(@"changing Side");
   
    if (_currentDispley == shareSide) {
        [((TabBarController*)_contentController) showSecretSideOnController:[sender.userInfo objectForKey:@"parent"]];
    }
}

- (void)moveView:(float)move {
    static const CGFloat kAnimationDuration = 0.30; // in seconds
    CGPoint p_start = inputView.center;
    CGPoint p_end = CGPointMake(p_start.x, p_start.y + move);
    [INTUAnimationEngine animateWithDuration:kAnimationDuration
                                                          delay:0.0
                                                         easing:INTUEaseInOutQuadratic
                                                        options:INTUAnimationOptionNone
                                                     animations:^(CGFloat progress) {
                                                         inputView.center = INTUInterpolateCGPoint(p_start, p_end, progress);
                                                         
                                                         // NSLog(@"Progress: %.2f", progress);
                                                     }
                                                     completion:^(BOOL finished) {
                                                         // NOTE: When passing INTUAnimationOptionRepeat, this completion block is NOT executed at the end of each cycle. It will only run if the animation is canceled.
                                                         NSLog(@"%@", finished ? @"Animation Completed" : @"Animation Canceled");
//                                                         self.animationID = NSNotFound;
                                                     }];
}

#pragma mark -- pan gusture
- (void)handlePan:(UIPanGestureRecognizer*)gesture {
    NSLog(@"pan gesture");
    if (inputView.frame.origin.y + inputView.frame.size.height != [UIScreen mainScreen].bounds.size.height) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            point = [gesture translationInView:self.view];
            
        } else if (gesture.state == UIGestureRecognizerStateEnded) {
            CGPoint newPos = [gesture translationInView:self.view];
            
            if (newPos.y - point.y) {
                NSLog(@"down gesture");
                [inputView endEditing];
            }
            [self moveView:210];
        }
    }
}

#pragma mark -- LoinInputView Delegate
- (void)didSelectQQBtn {
    [_lm loginWithQQ];
}

- (void)didSelectWeiboBtn {
    [_lm loginWithWeibo];
}

- (void)didSelectWechatBtn {
    
}

- (void)didSelectAreaCodeBtn {
    [self performSegueWithIdentifier:@"areaCode" sender:nil];
}

- (void)didSelectConfirmBtn {
    NSString* phoneNo = [inputView getInputPhoneNumber];
    
    if ([self isValidPhoneNumber:phoneNo inArea:@"+86"] && [self.lm sendLoginRequestToPhone:phoneNo]) {
        [inputView sendConfirmCodeRequestSuccess];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"input wrong phone number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didSelectNextBtn {
    NSString* code = [inputView getInputConfirmCode];
    NSString* phoneNo = [inputView getInputPhoneNumber];
    
    if (![self isValidPhoneCode:code]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"input wrong phone number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    RegTmpToken* token = [RegTmpToken enumRegTokenINContext:self.lm.doc.managedObjectContext WithPhoneNo:phoneNo];
    
    if (token == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"input wrong phone number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    } else {
        NSDictionary* tmp =[[NSDictionary alloc]init];
        LoginModelConfirmResult reVal = [self.lm sendConfirrmCode:code ToPhone:phoneNo withToken:token.reg_token toResult:&tmp];
        if (reVal == LoginModelResultSuccess) {
            [self performSegueWithIdentifier:@"loginSuccessSegue" sender:tmp];
            NSLog(@"login success");
        } else if (reVal ==LoginModelResultOthersLogin) {
            [self performSegueWithIdentifier:@"alreadyLogSegue" sender:tmp];
            NSLog(@"already login by others");
        }
    }
}

- (void)didStartEditing {
    if (inputView.frame.origin.y + inputView.frame.size.height == [UIScreen mainScreen].bounds.size.height) {
        [self moveView:-210];
    }
}

- (void)didEndEditing {
    [self moveView:210];
}

- (void)didSelectUserPrivacyBtn {
    [self performSegueWithIdentifier:@"UserPrivacy" sender:nil];
}

#pragma mark -- choose area controller delegate
- (void)didSelectArea:(NSString*)code {
    [inputView setAreaCode:code];
}

#pragma mark -- Gotaye Delegate
/**
 * @brief 登录回调
 * @param code: 状态id
 * @param user: 当前登录用户
 */
-(void) onLogin:(GotyeStatusCode)code user:(GotyeOCUser*)user {
    NSLog(@"XMPP on Login");
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.im_user = user;
//    [GotyeOCAPI activeSession:[GotyeOCUser userWithName:@"alfred_test"]];
//    [app registerDeviceTokenWithCurrentUser];
//    if (!isQueryModelReady) [app createQueryModel];
//    else [self queryDataIsReady:nil];
//    [self performSegueWithIdentifier:@"contentSegue" sender:nil];
    if (_contentController == nil) {
        [self performSegueWithIdentifier:@"contentSegue" sender:nil];
    }
}

/**
 * @brief  正在重连回调
 * @param code: 状态id
 * @param user: 当前登录用户
 */
-(void) onReconnecting:(GotyeStatusCode)code user:(GotyeOCUser*)user {
    NSLog(@"XMPP on Reconnecting");
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.im_user = user;
   
//    [GotyeOCAPI activeSession:[GotyeOCUser userWithName:@"alfred_test"]];
    [GotyeOCAPI beginReceiveOfflineMessage];
}

/**
 * @brief  退出登录回调
 * @param code: 状态id
 */
-(void) onLogout:(GotyeStatusCode)code {
    NSLog(@"XMPP on Logout");
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.im_user = nil;
}

/**
 * @brief 接收消息回调
 * @param message: 接收到的消息对象
 * @param downloadMediaIfNeed: 是否自动下载
 */
-(void) onReceiveMessage:(GotyeOCMessage*)message downloadMediaIfNeed:(bool*)downloadMediaIfNeed {
    if (message.sender.type == GotyeChatTargetTypeRoom) {
        return;
    }
    
    if ([message.sender.name isEqualToString:@"alfred_test"]) {
        NSLog(@"this is a system notification");
        
        [_mm addNotification:[RemoteInstance searchDataFromData:[message.text dataUsingEncoding:NSUTF8StringEncoding]] withFinishBlock:^{
            [_contentController unReadMessageCountChanged:nil];
        }];
        
        [GotyeOCAPI markOneMessageAsRead:message isRead:YES];
//        GotyeOCUser* u = [GotyeOCUser userWithName:@"alfred_test"];
//        [GotyeOCAPI deleteMessage:u msg:message];
//        [GotyeOCAPI deleteSession:u alsoRemoveMessages:YES];
        
    } else {
        NSLog(@"this is a chat message");
       
        // TODO: add logic for chat message
        [_contentController unReadMessageCountChanged:nil];
    }
}

/**
 * @brief 获取历史/离线消息回调
 * @param code: 状态id
 * @param msglist: 消息列表
 * @param downloadMediaIfNeed: 是否需要下载
 */
-(void) onGetMessageList:(GotyeStatusCode)code totalCount:(unsigned)totalCount downloadMediaIfNeed:(bool*)downloadMediaIfNeed {
    NSLog(@"get message count : %d", totalCount);

    /**
     * for notification
     */
    GotyeOCUser* u = [GotyeOCUser userWithName:@"alfred_test"];
    NSArray* arr = [GotyeOCAPI getMessageList:u more:YES];
    for (int index = 0; index < arr.count; ++index) {
        GotyeOCMessage* m = [arr objectAtIndex:index];
        if (m.status == GotyeMessageStatusUnread) {
            
            [_mm addNotification:[RemoteInstance searchDataFromData:[m.text dataUsingEncoding:NSUTF8StringEncoding]] withFinishBlock:^{
//                [_contentController addOneNotification];
            }];
        
            [GotyeOCAPI markOneMessageAsRead:m isRead:YES];
        }
    }
//    [GotyeOCAPI deleteMessages:u msglist:arr];
//    [GotyeOCAPI deleteSession:u alsoRemoveMessages:YES];
    
    /**
     * for messages
     */
    [_contentController unReadMessageCountChanged:nil];
}

/**
 * @brief 发送消息回调
 * @param code: 状态id
 * @param message: 消息对象
 */
-(void) onSendMessage:(GotyeStatusCode)code message:(GotyeOCMessage*)message {
    NSLog(@"send message success: %@", message);
}
@end
