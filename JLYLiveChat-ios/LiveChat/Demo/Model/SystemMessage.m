//
//  SystemMessage.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "SystemMessage.h"
#import "CommonMacros.h"

@interface SystemMessage ()
@property (nonatomic, readwrite, strong) HMRUser *user;
@property (nonatomic, readwrite, assign) SystemMessageType messageType;
@property (nonatomic, readwrite, assign) CGFloat cellHeight;


@end

@implementation SystemMessage


+ (instancetype)messageWithUser:(HMRUser *)user messageType:(SystemMessageType)messageType {
    return [[self alloc] initWithUser:user messageType:messageType];
}

- (instancetype)initWithUser:(HMRUser *)user messageType:(SystemMessageType)messageType {
    self = [super init];
    if (self) {
        _user = user;
        _messageType = messageType;
    }
    return self;
}


#pragma mark - Get

- (CGFloat)cellHeight {
    return 26;
}



- (NSAttributedString *)outputMessage {
    NSString *message = @"";
    switch (_messageType) {
            case SystemMessageTypeUserJoinRoom:
            message = [NSString stringWithFormat:@"%llu进入房间", _user.ID];
            break;
            case SystemMessageTypeUserLeaveRoom:
            message = [NSString stringWithFormat:@"%llu退出房间", _user.ID];
            break;
            case SystemMessageTypeUserKickedOutOfTheRoom:
            message = [NSString stringWithFormat:@"%llu被踢出房间", _user.ID];
            break;
            case SystemMessageTypeUserForbiddenToSpeak:
            message = [NSString stringWithFormat:@"%llu被禁言", _user.ID];
            break;
            case SystemMessageTypeUserResumeToSpeak:
            message = [NSString stringWithFormat:@"%llu恢复发言", _user.ID];
            break;
    }
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:message];
    [attributedString setAttributes:@{NSForegroundColorAttributeName:kColorHex(@"#F5A623")} range:NSMakeRange(0, message.length)];

    return attributedString;
}




@end
