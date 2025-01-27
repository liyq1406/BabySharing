//
//  ProfileOverView.m
//  BabySharing
//
//  Created by Alfred Yang on 1/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import "ProfileOthersOverView.h"
#import "TmpFileStorageModel.h"

@interface ProfileOthersOverView ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

//@property (weak, nonatomic) IBOutlet UIView *countContainer;
@property (weak, nonatomic) IBOutlet UILabel *shareCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cycleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *followBtn;
//@property (weak, nonatomic) IBOutlet UIButton *roleTagBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;


//@property (weak, nonatomic) IBOutlet UIView *buttomContainer;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
//@property (weak, nonatomic) IBOutlet UILabel *personalSignLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *seg;
@end

@implementation ProfileOthersOverView

@synthesize imgView = _imgView;

//@synthesize countContainer = _countContainer;
@synthesize shareCountLabel = _shareCountLabel;
@synthesize cycleCountLabel = _cycleCountLabel;
@synthesize friendsCountLabel = _friendsCountLabel;

@synthesize followBtn = _followBtn;
//@synthesize roleTagBtn = _roleTagBtn;
@synthesize chatBtn = _chatBtn;

//@synthesize buttomContainer = _buttomContainer;
@synthesize locationLabel = _locationLabel;
//@synthesize personalSignLabel = _personalSignLabel;
@synthesize nameLabel = _nameLabel;

@synthesize seg = _seg;

@synthesize deleagate = _deleagate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
//    _roleTagBtn.layer.borderColor = [UIColor blueColor].CGColor;
//    _roleTagBtn.layer.borderWidth = 1.f;
//    _roleTagBtn.layer.cornerRadius = 8.f;
//    _roleTagBtn.clipsToBounds = YES;

//    _followBtn.layer.borderWidth = 1.f;
    _followBtn.layer.cornerRadius = 25.f;
    _followBtn.clipsToBounds = YES;
    [_followBtn setBackgroundColor:[UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f]];
    [_followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_followBtn addTarget:_deleagate action:@selector(followBtnSelected) forControlEvents:UIControlEventTouchDown];
    
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    _seg.backgroundColor = [UIColor whiteColor];
    [_seg setImage:[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Grid"] ofType:@"png"]] forSegmentAtIndex:0];
    [_seg setImage:[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Tag"] ofType:@"png"]] forSegmentAtIndex:1];
    [_seg setImage:[UIImage imageNamed:[resourceBundle pathForResource:[NSString stringWithFormat:@"Location"] ofType:@"png"]] forSegmentAtIndex:2];
    
    _chatBtn.layer.cornerRadius = 25.f;
    _chatBtn.clipsToBounds = YES;
    [_chatBtn setBackgroundColor:[UIColor colorWithRed:0.3126 green:0.7529 blue:0.6941 alpha:1.f]];
    [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chatBtn addTarget:_deleagate action:@selector(chatBtnSelected) forControlEvents:UIControlEventTouchDown];

    [_seg addTarget:_deleagate action:@selector(segControlValueChangedWithSelectedIndex:) forControlEvents:UIControlEventValueChanged];
    
    _imgView.layer.cornerRadius = 50.f;
    _imgView.clipsToBounds = YES;
}

- (void)setOwnerPhoto:(NSString*)photo_name {
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString * filePath = [resourceBundle pathForResource:[NSString stringWithFormat:@"User"] ofType:@"png"];
    
    UIImage* userImg = [TmpFileStorageModel enumImageWithName:photo_name withDownLoadFinishBolck:^(BOOL success, UIImage *user_img) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self) {
                    self.imgView.image = user_img;
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
    [self.imgView setImage:userImg];
}

- (void)setShareCount:(NSInteger)count {
    NSString* tmp = [NSString stringWithFormat:@"%ld", (long)count];
    _shareCountLabel.text = tmp;
}

- (void)setCycleCount:(NSInteger)count {
    NSString* tmp = [NSString stringWithFormat:@"%ld", (long)count];
    _cycleCountLabel.text = tmp;
}

- (void)setFriendsCount:(NSInteger)count {
    NSString* tmp = [NSString stringWithFormat:@"%ld", (long)count];
    _friendsCountLabel.text = tmp;
}

- (void)setLoation:(NSString*)location {
    _locationLabel.text = location;
}

- (void)setPersonalSign:(NSString*)sign_content {
//    _personalSignLabel.text = sign_content;
}

- (void)setRelations:(NSString*)relations {
    [_followBtn setTitle:relations forState:UIControlStateNormal];
}

- (void)setRoleTag:(NSString*)role_tag {
//    [_roleTagBtn setTitle:role_tag forState:UIControlStateNormal];
}

- (void)setPersonalNickName:(NSString*)nickName {
    _nameLabel.text = nickName;
    [_nameLabel sizeToFit];
}

+ (CGFloat)preferredHeight {
    return 225;
}
@end
