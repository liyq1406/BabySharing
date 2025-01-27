//
//  PostGridCell.m
//  YYBabyAndMother
//
//  Created by Alfred Yang on 2/01/2015.
//  Copyright (c) 2015 YY. All rights reserved.
//

#import "AlbumGridCell.h"
#import "RemoteInstance.h"
#import "TmpFileStorageModel.h"

#define LAYER_WIDTH 20

@implementation AlbumGridCell

@synthesize row = _row;
@synthesize col = _col;
@synthesize viewSelected = _viewSelected;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setCellViewSelected:(BOOL)select {
    if (select == NO) {
        [selectLayer removeFromSuperlayer];
    } else {
        if (selectLayer == nil) {
            selectLayer = [CALayer layer];
            CGFloat width = self.frame.size.width;
            CGFloat height = self.frame.size.height;
            selectLayer.frame = CGRectMake(width - LAYER_WIDTH, height - LAYER_WIDTH, LAYER_WIDTH, LAYER_WIDTH);
        
            NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
            NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
            
            NSString* filepath = [resourceBundle pathForResource:@"Tick" ofType:@"png"];
            selectLayer.contents = (id)[UIImage imageNamed:filepath].CGImage;
        }
        [self.layer addSublayer:selectLayer];
    }
    _viewSelected = select;
}

- (void)setMovieDurationLayer:(NSNumber*)duration {
    if (durationLayer == nil) {
        durationLayer = [CATextLayer layer];
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        durationLayer.fontSize = 10.0;
        durationLayer.frame = CGRectMake(0, height - LAYER_WIDTH, width, LAYER_WIDTH);
        durationLayer.backgroundColor = [UIColor blackColor].CGColor;
        durationLayer.foregroundColor = [UIColor whiteColor].CGColor;

        durationLayer.string= [self seconds2Time:duration];
    }
    [self.layer addSublayer:durationLayer];
}

- (NSString*)seconds2Time:(NSNumber*)duration {
    int secends = duration.intValue;
    int hours = secends / 3600;
    int minutes = (secends - hours * 3600) / 60;
    secends = secends - hours * 3600 - minutes * 60;
   
    return [NSString stringWithFormat:@"%2d:%2d:%2d", hours, minutes, secends];
}

- (void)setShowingPhotoWithName:(NSString*)photo_name {
    NSString * bundlePath = [[ NSBundle mainBundle] pathForResource: @"YYBoundle" ofType :@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString * filePath = [resourceBundle pathForResource:[NSString stringWithFormat:@"User"] ofType:@"png"];
    
    UIImage* userImg = [TmpFileStorageModel enumImageWithName:photo_name withDownLoadFinishBolck:^(BOOL success, UIImage *user_img) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self) {
                    self.image = user_img;
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
    [self setImage:userImg];
}
@end
