//
//  QueryCell.h
//  YYBabyAndMother
//
//  Created by Alfred Yang on 9/01/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDefine.h"

@protocol QueryCellActionProtocol <NSObject>
- (void)didSelectLikeBtn:(id)content;
- (void)didSelectShareBtn:(id)content;
- (void)didSelectCommentsBtn:(id)content;
@end

@class AVPlayer;
@class MoviePlayTrait;

@interface QueryCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *sharingScoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ownerImg;
@property (weak, nonatomic) IBOutlet UILabel *timeNumber;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIView *tagsLabelView;
@property (weak, nonatomic) IBOutlet UIButton *commentsBtn;

@property (nonatomic) PostPreViewType type;
@property (nonatomic, strong) NSURL* movieURL;
@property (nonatomic, strong) AVPlayer* player;

@property (weak, nonatomic) id<QueryCellActionProtocol> delegate;
@property (weak, nonatomic) id content;

#pragma mark -- constractor

#pragma mark -- layout
+ (CGFloat)preferredHeight;
- (void)movieContentWithURL:(NSURL*)url withTriat:(MoviePlayTrait*)trait;
- (void)playMovie;
- (void)stopMovie;
@end