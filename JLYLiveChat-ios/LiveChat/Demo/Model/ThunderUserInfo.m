//
//  ThunderUserInfo.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/9.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "ThunderUserInfo.h"

@interface ThunderUserInfo ()
@end

@implementation ThunderUserInfo

- (instancetype)initWithUid:(NSString *)uid roomId:(NSString *)roomId {
    self = [super init];
    if (self) {
        _uid = [uid copy];
        _roomId= [roomId copy];
    }
    return self;
}

@end
