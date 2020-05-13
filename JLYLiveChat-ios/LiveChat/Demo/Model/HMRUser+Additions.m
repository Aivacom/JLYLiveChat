//
//  HMRUser+Additions.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/16.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "HMRUser+Additions.h"
#include <objc/message.h>


@implementation HMRUser (Additions)

- (BOOL)sy_isMe {
    return self.ID == [HMRUser getMe].ID;
}

@end
