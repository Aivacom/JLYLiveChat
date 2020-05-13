//
//  ChatMessage.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "HMRMessage.h"
#import "ChatMessageProtocol.h"


@interface ChatMessage : NSObject <ChatMessageProtocol>
@property (nonatomic, readonly, strong) HMRMessage *message;  


+ (instancetype)chatMessageWithMessage:(HMRMessage *)message;
- (instancetype)initWithMessage:(HMRMessage *)message;






@end
