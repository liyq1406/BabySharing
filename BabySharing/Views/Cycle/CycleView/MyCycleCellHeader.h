//
//  MyCycleCellHeader.h
//  BabySharing
//
//  Created by Alfred Yang on 12/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCycleCellHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString* role_tag;

- (void)viewLayoutSubviews;

+ (CGFloat)preferHeight;
@end
