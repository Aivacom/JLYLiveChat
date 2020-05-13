//
//  UserPickerData.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/9/28.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "UserPickerData.h"

@interface UserPickerData ()
@property (nonatomic, readwrite, copy) HMRUser *value;


@end

@implementation UserPickerData


- (instancetype)initWithValue:(HMRUser *)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
    
}


#pragma mark - Get

- (NSString *)title {
    return [NSString stringWithFormat:@"%llu", _value.ID];
}


@end
