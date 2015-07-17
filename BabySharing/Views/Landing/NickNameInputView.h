//
//  NickNameInputView.h
//  BabySharing
//
//  Created by Alfred Yang on 17/07/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NickNameInputViewDelegate <NSObject>

- (void)didStartInputName;
- (void)didEndInputName;

- (void)didStartInputTags;

@end

@interface NickNameInputView : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id<NickNameInputViewDelegate> delegate;

- (id)init;
- (CGSize)getPreferredBounds;

- (void)resetTags:(NSString*)tags;

- (NSString*)getInputName;
- (NSString*)getInputTags;
@end
