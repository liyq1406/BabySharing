//
//  PersonalCentreOthersDelegate.h
//  BabySharing
//
//  Created by Alfred Yang on 7/08/2015.
//  Copyright (c) 2015 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OwnerQueryModel.h"
#import "AlbumTableCell.h"
#import "PersonalCenterProtocol.h"
#import "ProfileViewDelegate.h"

@interface PersonalCentreOthersDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, AlbumTableCellDelegate, PersonalCenterCallBack>
@property (nonatomic, weak) id<PersonalCenterProtocol, ProfileViewDelegate> delegate;
@end
