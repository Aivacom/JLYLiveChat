//
//  LivingRoomViewController+Hummer.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingRoomViewController+Hummer.h"
#import "CommonMacros.h"
#import "MBProgressHUD+HUD.h"
#import "UIViewController+AlertController.h"

#import "ChatMessage.h"
#import "SystemMessage.h"

#import "LivingOperationView.h"
#import "MessageSendView.h"

#import "HummerManager.h"
#import "HMRUser+Additions.h"
#import "ThunderManager.h"
#import "LivingRoomViewController+Thunder.h"

#import "JoinRoomViewController.h"




static dispatch_semaphore_t _semaphore;

@implementation LivingRoomViewController (Hummer)



#pragma mark - Life cycle

- (void)hummer_viewDidLoad {
    // 进来获取禁言状态
    // Come in and get the mute status
    [[HMRChatRoomService instance] fetchMutedUsers:self.chatRoom completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.sy_isMe) {
                self.isForbiddenToSpeak = YES;
                *stop = YES;
            }
        }];
    }];
    
    // 获取聊天室角色成员，其他界面展示和逻辑都依赖是否为房主
    // Get members of the chat room role, other interface display and logic depend on whether you are the host
    [MBProgressHUD showActivityIndicator];
    [[HMRChatRoomService instance] fetchRoleMembers:self.chatRoom onlineOnly:NO completionHandler:^(NSDictionary<NSString *,NSSet<HMRUser *> *> * _Nullable roleToMembers, NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD showToast:@"获取房主信息失败"];
        } else {
            [MBProgressHUD hideActivityIndicator];
            NSSet *ownerRoles = roleToMembers[HMROwnerRole];
            // 设置房主
            // Set up a homeowner
            self.chatRoom.sy_roomOwner = ownerRoles.allObjects.firstObject;
            
            // 开始初始化
            // Start initialization
            [self setup];
        }
    }];
    
}

- (void)hummer_setup {
    
    [self addDependentObserver];
    
    // 用于控制消息插入
    // Used to control message insertion
    _semaphore = dispatch_semaphore_create(1);
    
    
    // App退出时退出聊天室
    // Exit the chat room when the app quits
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        // 离开聊天室
        // Leave chat room
        [[HMRChatRoomService instance] leaveChatRoom:self.chatRoom completionHandler:^(NSError *error) {
            if (error) {
                kLog(@"Leave chat room error: %@", error);
            }
        }];
    }];
}

#pragma mark - Private

- (void)addDependentObserver {
    // 添加需要观察的事件
    // Add events to be observed
    // 添加消息通道相关的监听（收发消息等通知回调）
    // Add monitoring related to the message channel (notification callback for sending and receiving messages)
    [[HMRChatService instance] addMessageObserver:self forTarget:self.chatRoom];
    // 添加聊天室成员回调监听（用户加入和退出聊天室，被禁言和恢复禁言，被踢出等回调）
    // Add chat room member callback monitoring (users join and exit the chat room, banned and reinstated, kicked out and other callbacks)
    [[HMRChatRoomService instance] addMemberObserver:self];
    // 添加聊天室回调监听（聊天室被关闭等回调）
    // Add chat room callback monitoring (callback when the chat room is closed)
    [[HMRChatRoomService instance] addChatRoomObserver:self];
}


#pragma mark - Public


- (void)hummer_removeDependentObserver {
    // 移除需要观察的事件
    // Remove events that need to be observed
    [[HMRChatRoomService instance] removeChatRoomObserver:self];
    [[HMRChatService instance] removeMessageObserver:self forTarget:self.chatRoom];
    [[HMRChatRoomService instance] removeMemberObserver:self];
}


- (void)hummer_applySubscribeUser:(HMRUser *)user {
    // 发送开播申请单播
    // Send start broadcast application unicast
    [MBProgressHUD showActivityIndicator];
    // 设置申请订阅等待超时时间，30S后如还未收到观众处理结果，隐藏loading
    // Set the timeout period for applying for subscriptions. If the processing result of the audience has not been received after 30S, hide the loading
    [self performSelector:@selector(subscriptionApplyTimeoutHandle) withObject:nil afterDelay:30];
    [self.hummerManager sendSignalMessage:SignalContentApply receiver:user chatRoom:self.chatRoom completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"申请订阅观众失败"];
        }
    }];
}

- (void)subscriptionApplyTimeoutHandle {
    [MBProgressHUD hideActivityIndicator];
}



- (void)hummer_sendMessage:(NSString *)message {
    
    if (self.isForbiddenToSpeak) {
        [MBProgressHUD showToast:@"你已被禁言"];
        return;
    }

    HMRMessage *hmrMessage = [HMRMessage messageWithContent:[HMRTextContent contentWithText:message]
                                                    receiver:self.chatRoom];
    // 发送消息
    // Send a message
    [[HMRChatService instance] sendMessage:hmrMessage completionHandler:^(NSError *error) {
        if (error) {
            // 在聊天室中发送文本，如果 error.code 为 HMRForbiddenErrorCode 则表示被禁言
            // Send text in the chat room, if error.code is HMRForbiddenErrorCode, it means banned
            if (error.code == HMRForbiddenErrorCode) {
                self.isForbiddenToSpeak = YES;
                [MBProgressHUD showToast:@"你已被禁言"];
            } else {
                kLog(@"sendMessage:%@ failed, reason:%@", message, error.localizedDescription);
            }
        } else {
            self.isForbiddenToSpeak = NO;
        }
    }];
    
    
    // 放在sendMessage后面执行保证chatMessage.message的sender有值
    // Put it after sendMessage to ensure that the sender of chatMessage.message has value
    // 插入新消息
    // insert new message
    ChatMessage *chatMessage = [ChatMessage chatMessageWithMessage:hmrMessage];
    [self insertNewMessage:chatMessage];
    [self.messageSendView clearContent];

}

- (void)insertNewMessage:(id <ChatMessageProtocol>)chatMessage {
    // 加锁，必须等上一条插入后再执行新的消息插入
    // add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    // 添加需要发送的消息到列表
    // Add the message to be sent to the list
    [self.messageList addObject:chatMessage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageList.count - 1 inSection:0];
    
    if (@available(iOS 11.0, *)) {
        [self.messageTableView performBatchUpdates:^{
            [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.messageTableView beginUpdates];
        [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.messageTableView endUpdates];
    }
    
    // 滚动到底部
    // Scroll to the bottom
    [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    dispatch_semaphore_signal(_semaphore);
}



- (void)hummer_popToJoinRoomViewController {
    // 清除所有状态记录
    // Clear all status records
    [self.thunderManager clearLiveStatus];
    
    [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[JoinRoomViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];
}


#pragma mark - hummer_
- (void)hummer_operationViewDidTapOnsubscribeButton:(LivingOperationView *)operationView {
    if (operationView.hasSubscribed) {
        // 发送取消观众直播单播
        // Send cancel audience live unicast
        [MBProgressHUD showActivityIndicator];
        [self.hummerManager sendSignalMessage:SignalContentCancel receiver:self.subscribedUser chatRoom:self.chatRoom completionHandler:^(NSError *error) {
            if (error) {
                [MBProgressHUD showToast:@"取消订阅失败"];
            } else {
                [MBProgressHUD hideActivityIndicator];

                // 取消订阅操作
                // Unsubscribe
                [self thunder_unsubscribeRemoteUser];
                
                self.thunderManager.isRemoteUserLiving = NO;
                [self thunder_adjustCanvasView];

            }
        }];
    } else {
        // 弹出时点击无效
        // Invalid click on popup
        if(!self.livingOperationView.isPickerVisible) {
            [self subscribeAudience];
        }
    }
}

- (void)subscribeAudience {
    [MBProgressHUD showActivityIndicator];
    [self.hummerManager fetchAudienceMembersWithChatRoom:self.chatRoom completionHandler:^(NSArray<UserPickerData *> *members, NSError *error) {
        if (error) {
            if (!self.audienceMembers) {
                [MBProgressHUD showToast:@"获取观众列表失败"];
                return;
            }
        } else {
            [MBProgressHUD hideActivityIndicator];
            self.audienceMembers = members;
            [self.livingOperationView updatePickerDataSource:self.audienceMembers];
        }
        
        if (self.audienceMembers.count) {
            [self.livingOperationView showPicker];
        } else {
            [MBProgressHUD showToast:@"房间内暂无其他人"];
        }
    }];
}


#pragma mark - HMRMessageObserver（聊天消息通道相关事件的监听者接口/Listener interface for chat message channel related events）

/**
 即将发送聊天消息前会收到该事件的回调通知/You will receive a callback notification of the event before sending a chat message
 @param message 即将要发送的聊天消息/Upcoming chat message
 */
- (void)willSendMessage:(HMRMessage *)message {
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
    
    kLog(@"willSendMessage:%@", message);
}


/**
 发送完成聊天消息后会收到该事件的回调通知/After sending the chat message, you will receive a callback notification of the event
 
 @param message 发送完成的聊天消息/Send completed chat message
 */
- (void)didSendMessage:(HMRMessage *)message {
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
    
    kLog(@"didSendMessage:%@", message);
}


/**
 收到该消息会收到该事件的回调通知/Upon receiving this message, you will receive a callback notification of the event
 
 @param message 收到的聊天消息/Chat messages received
 */
- (void)didReceiveMessage:(HMRMessage *)message {
    // 不是该聊天室的消息不接收
    // Not receiving messages from this chat room
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
    
    // 单播
    // Unicast
    if ([message.content isKindOfClass:HMRSignalContent.class]) {
        [self handleSignalMessage:message];
    } else if ([message.content isKindOfClass:HMRTextContent.class]) {
        // 插入接收的消息
        // Insert received message
        [self insertNewMessage:[ChatMessage chatMessageWithMessage:message]];
    }
}

- (void)handleSignalMessage:(HMRMessage *)message {
    HMRSignalContent *signalContent = (HMRSignalContent *)message.content;
    NSString *messageContent = signalContent.content;
    HMRUser *sender = message.sender;

    if ([messageContent isEqualToString:SignalContentApply]) { // 针对观众/For audience
        UIAlertController *alertController = [self popupAlertViewWithTitle:nil message:@"房主邀请你开播" handler:^(UIAlertAction *action, NSUInteger index) {
            
            NSString *resultMessage = SignalContentRefuse;
            if (index == 0) {
                resultMessage = SignalContentAccept;
                
                // 开启直播
                // Start live streaming
                [self thunder_enableVideoLive];
            }
            
            // 发送观众确认结果单播
            // Send viewer confirmation result unicast
            [self.hummerManager sendSignalMessage:resultMessage receiver:sender chatRoom:self.chatRoom completionHandler:^(NSError *error) {
                if (error) {
                    kLog(@"sendSignalMessage:%@ failed, reason:%@", resultMessage, error.localizedDescription);
                }
            }];
        } cancelActionTitle:@"拒绝" confirmActionTitle:@"同意"];
        
        if (@available(iOS 13.0, *)) {
            alertController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        
    } else if ([messageContent isEqualToString:SignalContentAccept]) { // 针对房主/For homeowners
        // 隐藏loading
        // hide loading
        [MBProgressHUD hideActivityIndicator];
        // 取消申请订阅超时操作
        // Cancel subscription timeout operation
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(subscriptionApplyTimeoutHandle) object:nil];
        
        [self.livingOperationView updatesubscribeStatus:YES];
        self.subscribedUser = sender;
        
        // 订阅观众
        // Subscribe viewers
        [self.thunderManager subscribeRemoteUser];
        
    } else if ([messageContent isEqualToString:SignalContentRefuse]) { // 针对房主/For homeowners
        // 取消申请订阅超时操作
        // Cancel subscription timeout operation
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(subscriptionApplyTimeoutHandle) object:nil];
        
        [MBProgressHUD showToast:[NSString stringWithFormat:@"%llu拒绝开播", sender.ID]];
    } else if ([messageContent isEqualToString:SignalContentCancel]) { // 针对观众/For audience
        [MBProgressHUD showToast:@"房主已取消连麦"];
        
        // 退出直播
        // Exit live
        [self thunder_disableVideoLive];
    }
}





#pragma mark - HMRChatRoomObserve（聊天室相关的监听事件/Monitoring events related to chat rooms）

/**
 当聊天室被解散时发生的回调通知/Callback notification that occurs when the chat room is disbanded
 
 @param chatRoom 被解散的聊天室的标识/Logo of disbanded chat room
 @param operatorUser 解散聊天室的管理员/Dismiss the chat room administrator
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didDismissByOperator:(HMRUser *)operatorUser {
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    // 房主的销毁房间直接在请求回调里处理
    // The owner's destruction of the room is handled directly in the request callback
    if (![self.chatRoom sy_roomOwnerIsMe]) {
        // 移除通知
        // Remove notification
        [self hummer_removeDependentObserver];
        
        // 退出房间，退出房间后订阅和直播都失效了
        // After exiting the room, the subscription and live broadcast are invalid after exiting the room
        [self.thunderManager leaveRoom];

        // 解决意见反馈present出来后，弹窗无法展示的问题
        // Solve the problem that the pop-up window cannot be displayed after the feedback is presented
        UIViewController *VC = self;
        if (self.presentedViewController) {
            VC = self.presentedViewController;
        }
        UIAlertController *alertController = [VC popupAlertViewWithTitle:nil message:@"房主已销毁房间" handler:^(UIAlertAction *action, NSUInteger index) {
            [self hummer_popToJoinRoomViewController];
        } cancelActionTitle:nil confirmActionTitle:@"我知道了"];
        
        if (@available(iOS 13.0, *)) {
            alertController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
    }
}




#pragma mark - HMRChatRoomMemberObserve（聊天室成员相关变化的监听事件/Monitoring events related to changes in chat room members）

/**
 当有成员进入聊天室时的回调/Callback when a member enters the chat room
 
 @param chatRoom 聊天室标识/Chat room logo
 @param members 进入聊天室的成员/Members entering the chat room
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didJoinMembers:(NSSet<HMRUser *> *)members {
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    __block BOOL needUpdateAudienceMembersData = NO;
    // 插入成员进行聊天室系统消息
    // Insert members for chat room system messages
    [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
        // 自己不提示
        // Don't prompt yourself
        if (!user.sy_isMe) {
            needUpdateAudienceMembersData = YES;
            SystemMessage *systemMessage = [SystemMessage messageWithUser:user messageType:SystemMessageTypeUserJoinRoom];
            [self insertNewMessage:systemMessage];
        }
    }];
    
    // 如果picker弹出，可实时更新数据
    // If picker pops up, data can be updated in real time
    if (self.livingOperationView.isPickerVisible && needUpdateAudienceMembersData) {
        [self updateAudienceMembersData];
    }
}


/**
 * 当有成员离开聊天室时的回调/Callback when a member leaves the chat room
 * @param chatRoom 聊天室标识/Chat room logo
 * @param members 离开聊天室的成员/Members leaving the chat room
 * @param reason 离开聊天室的原因/Reasons to leave the chat room
 * @param type 离开聊天室的操作类型/Types of operations leaving the chat room
        0 - LEAVING
        1 - DISCONNECTED
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didLeaveMembers:(NSSet<HMRUser *> *)members reason:(NSString *)reason leavingType:(NSInteger)type {
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    __block BOOL needUpdateAudienceMembersData = NO;
    
    [members enumerateObjectsUsingBlock:^(HMRUser *user,BOOL *stop) {
        if (user.sy_isMe) {
            //断网重新连接
//            [[SYHummerManager sharedManager] joinChatRoomWithRoomId:@(chatRoom.ID).stringValue completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
//                if (error) {
//                    NSLog(@"重新加入房间失败了");
//                } else {
//                    NSLog(@"重新加入房间完成了");
//                }
//            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[HummerManager sharedManager] joinChatRoomWithRoomId:@(chatRoom.ID).stringValue completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
                    if (error) {
                        NSLog(@"重新加入房间失败了");
                    } else {
                        NSLog(@"重新加入房间完成了");
                    }
                }];
            });
        
        }
    }];
    
    
    // 插入成员退出聊天室系统消息
    // Insert a message that the member exits the chat room system
    [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
        // 自己不提示
        // Don't prompt yourself
        if (!user.sy_isMe) {
            needUpdateAudienceMembersData = YES;

            SystemMessage *systemMessage = [SystemMessage messageWithUser:user messageType:SystemMessageTypeUserLeaveRoom];
            [self insertNewMessage:systemMessage];
        }
    }];
    
    // 如果picker弹出，可实时更新数据
    // If picker pops up, data can be updated in real time
    if (self.livingOperationView.isPickerVisible && needUpdateAudienceMembersData) {
        [self updateAudienceMembersData];
    }
}


- (void)updateAudienceMembersData {
    [self.hummerManager fetchAudienceMembersWithChatRoom:self.chatRoom completionHandler:^(NSArray<UserPickerData *> *members, NSError *error) {
        if (error == nil) {
            self.audienceMembers = members;
            [self.livingOperationView updatePickerDataSource:self.audienceMembers];
        }
    }];
}

/**
 当聊天室成员被踢出聊天室时的回调/Callback when a chat room member is kicked out of the chat room

 @param chatRoom 聊天室标识/Chat room logo
 @param members 被踢出频道的成员/Members kicked out of the channel
 @param operatorUser 执行踢出操作的管理员/Administrator performing kickout
 @param reason 被踢出频道的原因/The reason for being kicked out of the channel
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didKickMembers:(NSSet<HMRUser *> *)members byOperator:(HMRUser *)operatorUser reason:(NSString *)reason {
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
        // 自己不提示
        // Don't prompt yourself
        if (user.sy_isMe) {
            // 移除监听
            // Remove monitor
            [self hummer_removeDependentObserver];
            
            // 退出房间，退出房间后订阅和直播都失效了
            // After exiting the room, the subscription and live broadcast are invalid after exiting the room
            [self.thunderManager leaveRoom];
            
            // 解决意见反馈present出来后，弹窗无法展示的问题
            // Solve the problem that the pop-up window cannot be displayed after the feedback is presented
            UIViewController *VC = self;
            if (self.presentedViewController) {
                VC = self.presentedViewController;
            }
            
            NSString *message = @"你已被踢出房间";
            // 同一用户登录不同客户端进入同一聊天室的情况，如果需要回调didKickMembers需要后端进行配置
            // When the same user logs into different clients and enters the same chat room, if you need to call back didKickMembers, you need to configure the backend
            if (operatorUser.sy_isMe) {
                message = @"你已在其他端进入房间，本地默认退出该房间";
                
                // 离开聊天室
                // Leave chat room
                [[HMRChatRoomService instance] leaveChatRoom:self.chatRoom completionHandler:^(NSError *error) {
                    if (error) {
                        kLog(@"Leave chat room error: %@", error);
                    }
                }];
            }
            
            
            UIAlertController *alertController = [VC popupAlertViewWithTitle:nil message:message handler:^(UIAlertAction *action, NSUInteger index) {
                [self hummer_popToJoinRoomViewController];
            } cancelActionTitle:nil confirmActionTitle:@"我知道了"];
            
            if (@available(iOS 13.0, *)) {
                alertController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
            
        } else {
            // 插入踢出消息
            // Insert kick message
            SystemMessage *systemMessage = [SystemMessage messageWithUser:user messageType:SystemMessageTypeUserKickedOutOfTheRoom];
            [self insertNewMessage:systemMessage];
        }
    }];
    
}


/**
 当聊天室成员被禁言时的回调/Callback when chat room members are banned
 
 @param chatRoom 聊天室标识/Chat room logo
 @param members 被禁言的成员/Banned member
 @param operatorUser 禁言的管理员/Forbidden Administrator
 @param reason 原因/Reason
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didMuteMembers:(NSSet<HMRUser *> *)members byOperator:(HMRUser *)operatorUser reason:(NSString *)reason {
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
        if (user.sy_isMe) {
            self.isForbiddenToSpeak = YES;
        }
        
        // 插入禁言消息
        // Insert mute message
        SystemMessage *systemMessage = [SystemMessage messageWithUser:user messageType:SystemMessageTypeUserForbiddenToSpeak];
        [self insertNewMessage:systemMessage];
    }];
}


/**
 当聊天室成员被解除禁言时的回调/Callback when chat room members are lifted
 
 @param chatRoom 聊天室标识/Chat room sign
 @param members 被解除禁言的成员/The member who was lifted
 @param operatorUser 解除禁言的管理员/Unbanned Administrator
 @param reason 原因/Reason
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didUnmuteMembers:(NSSet<HMRUser *> *)members byOperator:(HMRUser *)operatorUser reason:(NSString *)reason {
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
        if (user.sy_isMe) {
            self.isForbiddenToSpeak = NO;
        }
        
        // 插入禁言消息
        // Insert mute message
        SystemMessage *systemMessage = [SystemMessage messageWithUser:user messageType:SystemMessageTypeUserResumeToSpeak];
        [self insertNewMessage:systemMessage];
    }];
}

#pragma mark - Get and Set


@end
