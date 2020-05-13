//
//  HMRChatRoom+Additions.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/17.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <HMRChatRoom/HMRChatRoom.h>
#import <HMRCore/HMRUser.h>


@interface HMRChatRoom (Additions)

@property (nonatomic, strong) HMRUser *sy_roomOwner;        // 房主/homeowner

- (BOOL)sy_roomOwnerIsMe;


@end
