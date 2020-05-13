//
//  HMRChatRoom+Additions.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/17.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "HMRChatRoom+Additions.h"
#include <objc/message.h>


static char const * const kRoomOwnerKey = "kRoomOwnerKey";


@implementation HMRChatRoom (Additions)

- (HMRUser *)sy_roomOwner {
    return objc_getAssociatedObject(self, kRoomOwnerKey);
}

- (void)setSy_roomOwner:(HMRUser *)roomOwner {
    objc_setAssociatedObject(self, kRoomOwnerKey, roomOwner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sy_roomOwnerIsMe {
    return [HMRUser getMe].ID == self.sy_roomOwner.ID;
}


@end
