//
//  SystemMessage.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ChatMessageProtocol.h"
#import "HMRUser.h"
#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, SystemMessageType) {
    SystemMessageTypeUserJoinRoom = 0,
    SystemMessageTypeUserLeaveRoom,
    SystemMessageTypeUserKickedOutOfTheRoom,
    SystemMessageTypeUserForbiddenToSpeak,
    SystemMessageTypeUserResumeToSpeak
};

@interface SystemMessage : NSObject <ChatMessageProtocol>
@property (nonatomic, readonly, strong) HMRUser *user;   // 消息关联用户/Message associated users
@property (nonatomic, readonly, assign) SystemMessageType messageType;     // 系统消息类型/System message type


+ (instancetype)messageWithUser:(HMRUser *)user messageType:(SystemMessageType)messageType;
- (instancetype)initWithUser:(HMRUser *)user messageType:(SystemMessageType)messageType;


@end
