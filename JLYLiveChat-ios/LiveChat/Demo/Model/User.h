//
//  User.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/19.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HMRUser.h"

@interface User : NSObject
@property (nonatomic, readonly, strong) HMRUser *hummerUser;     // 对应SDK的User/Corresponding SDK User
@property (nonatomic, assign) BOOL isMuted;                      // 是否是我的消息/Is it my message
@property (nonatomic, assign) BOOL isRoomOwner;                  // 是否是房主/Is it the homeowner
@property (nonatomic, readonly, assign) BOOL isMe;               // 是否是自己/Is it yourself

- (instancetype)initWithHummerUser:(HMRUser *)hummerUser;


@end
