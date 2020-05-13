//
//  UserPickerData.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/9/28.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "PickerDataProtocal.h"
#import "HMRUser.h"

@interface UserPickerData : NSObject <PickerDataProtocal>

@property (nonatomic, readonly, copy) HMRUser *value;

- (instancetype)initWithValue:(HMRUser *)value;


@end
