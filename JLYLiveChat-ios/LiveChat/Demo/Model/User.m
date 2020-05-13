//
//  User.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/19.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "User.h"
#import "HMRUser+Additions.h"

@interface User ()
@property (nonatomic, readwrite, strong) HMRUser *hummerUser;


@end

@implementation User


- (instancetype)initWithHummerUser:(HMRUser *)hummerUser {
    self = [super init];
    if (self) {
        _hummerUser = hummerUser;
    }
    return self;
}




#pragma mark - Get

- (BOOL)isMe {
    return _hummerUser.sy_isMe;
}

@end
