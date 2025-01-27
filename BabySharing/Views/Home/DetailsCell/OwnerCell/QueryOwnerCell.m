//
//  QueryOwnerCell.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 12/01/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "QueryOwnerCell.h"
#import "TmpFileStorageModel.h"
#import "DongDaFollowBtn.h"

#define HEADER_HEIGHT       44

#define MARGIN              8

#define USER_IMG_WIDTH      40
#define USER_IMG_HEIGHT     USER_IMG_WIDTH

#define ROLE_TAG_WIDTH      80
#define ROLE_TAG_HEIGHT     25

@interface QueryOwnerCell () <DongDaFollowBtnDelegate>

@end

@implementation QueryOwnerCell

@synthesize userImg = _userImg;
@synthesize userRoleTagBtn = _userRoleTagBtn;
@synthesize userNameLabel = _userNameLabel;
@synthesize followBtn = _followBtn;
@synthesize tagLabel = _tagLabel;

@synthesize owner_id = _owner_id;
@synthesize delegate = _delegate;

- (void)setUpSubviews {
    if (!_userImg) {
        _userImg = [[UIImageView alloc]init];
        [self addSubview:_userImg];
    }
    
    if (!_userRoleTagBtn) {
//        _userRoleTagBtn = [[UIButton alloc]init];
//        [self addSubview:_userRoleTagBtn];
    }
    
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]init];
        [self addSubview:_userNameLabel];
    }
    
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc]init];
        [self addSubview:_tagLabel];
    }
    
    if (!_followBtn) {
//        _followBtn = [[UIButton alloc]init];
        _followBtn = [[DongDaFollowBtn alloc]init];
        [self addSubview:_followBtn];
    }
    
    self.backgroundColor = [UIColor colorWithRed:0.4 green:0.7686 blue:0.7294 alpha:1.f];
}

- (void)awakeFromNib {
    [self setUpSubviews];
    
    CGFloat offset = MARGIN * 2;
    
    _userImg.bounds = CGRectMake(0, 0, USER_IMG_WIDTH, USER_IMG_HEIGHT);
    _userImg.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 44);
    _userImg.layer.cornerRadius = USER_IMG_WIDTH / 2;
    _userImg.layer.borderColor = [UIColor redColor].CGColor;
    _userImg.layer.borderWidth = 2.f;
    _userImg.clipsToBounds = YES;
//
//    offset += USER_IMG_WIDTH + MARGIN;
    
    UIFont* font = [UIFont systemFontOfSize:14.f];
    _userNameLabel.font = font;
    CGSize user_name_size = [@"渊渊渊渊渊渊" sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
//    _userNameLabel.frame = CGRectMake(offset, _userImg.frame.origin.y - MARGIN / 2, user_name_size.width, user_name_size.height);
    _userNameLabel.frame = CGRectMake(offset, 8, user_name_size.width, user_name_size.height);
    
    font = [UIFont systemFontOfSize:11.f];
    _tagLabel.font = font;
    CGSize location_size = [@"杨杨杨杨杨杨杨杨杨杨杨" sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
    _tagLabel.frame = CGRectMake(offset, _userNameLabel.frame.origin.y + user_name_size.height + MARGIN / 2, location_size.width, location_size.height);
    
    
    offset += user_name_size.width + MARGIN;
    _userRoleTagBtn.font = font;
    _userRoleTagBtn.frame = CGRectMake(offset, _userNameLabel.frame.origin.y, ROLE_TAG_WIDTH, ROLE_TAG_HEIGHT);
    _userRoleTagBtn.layer.borderColor = [UIColor blueColor].CGColor;
    _userRoleTagBtn.layer.borderWidth = 1.f;
    _userRoleTagBtn.layer.cornerRadius = MARGIN;
    _userRoleTagBtn.clipsToBounds = YES;
    _userRoleTagBtn.backgroundColor = [UIColor whiteColor];
    [_userRoleTagBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
//    _followBtn.bounds = CGRectMake(0, 0, 60, 60);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    font = [UIFont systemFontOfSize:13.f];
//    _followBtn.font = font;
//    CGSize follow_size = [@"杨杨杨杨杨" sizeWithFont:font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
//    _followBtn.bounds = CGRectMake(0, 0, follow_size.width, follow_size.height);
    _followBtn.center = CGPointMake(width - MARGIN * 4, HEADER_HEIGHT / 2);
    _followBtn.delegate = self;
//    [_followBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    _followBtn.layer.borderColor = [UIColor blueColor].CGColor;
//    _followBtn.layer.borderWidth = 1.f;
//    _followBtn.layer.cornerRadius = 4.f;
//    _followBtn.clipsToBounds = YES;
//    [_followBtn addTarget:self action:@selector(followBtnSelected) forControlEvents:UIControlEventTouchDown];
}

+ (CGFloat)preferHeight {
    return 44;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didSelectImageOrName:(UITapGestureRecognizer*)sender {
    [_delegate didSelectDetialOwnerNameOrImage:_owner_id];
}

- (void)setUserPhoto:(NSString*)photo_name {
    
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString * filePath = [resourceBundle pathForResource:[NSString stringWithFormat:@"User"] ofType:@"png"];
    
    UIImage* userImg = [TmpFileStorageModel enumImageWithName:photo_name withDownLoadFinishBolck:^(BOOL success, UIImage *user_img) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self) {
                    self.userImg.image = user_img;
                    NSLog(@"owner img download success");
                }
            });
        } else {
            NSLog(@"down load owner image %@ failed", photo_name);
        }
    }];
    
    if (userImg == nil) {
        userImg = [UIImage imageNamed:filePath];
    }
    [self.userImg setImage:userImg];
}

- (void)setUserName:(NSString*)name {
    _userNameLabel.text = name;
    [_userNameLabel sizeToFit];
}

- (void)setTagText:(NSString*)location {
    _tagLabel.text = location;
    [_tagLabel sizeToFit];
}

- (void)setRoleTag:(NSString *)role_tag {
    [_userRoleTagBtn setTitle:role_tag forState:UIControlStateNormal];
}

- (void)followBtnSelected {
    [_delegate didSelectDetialFollowOwner:self];
}

- (void)setConnections:(UserPostOwnerConnections)relations {
//    switch (relations) {
//        case UserPostOwnerConnectionsSamePerson:
////            [_followBtn setTitle:@"我发的" forState:UIControlStateNormal];
//            break;
//        case UserPostOwnerConnectionsNone:
//        case UserPostOwnerConnectionsFollowed:
////            [_followBtn setTitle:@"+关注" forState:UIControlStateNormal];
//            break;
//        case UserPostOwnerConnectionsFollowing:
//        case UserPostOwnerConnectionsFriends:
////            [_followBtn setTitle:@"取消关注" forState:UIControlStateNormal];
//            break;
//        default:
//            break;
//    }
////    [_followBtn sizeToFit];
    _followBtn.relations = relations;
}

- (void)btnSelected {
    [_delegate didSelectDetialFollowOwner:self];
}
@end
