//
//  LivingRoomViewController+Hummer.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingRoomViewController.h"

@interface LivingRoomViewController () <HMRMessageObserver, HMRChatRoomMemberObserver, HMRChatRoomObserver>
@property (nonatomic, strong) NSArray *audienceMembers;
@property (nonatomic, assign) BOOL isForbiddenToSpeak;    // 是否被禁言/Whether to be banned
@property (nonatomic, strong) HMRUser *subscribedUser;    // 已订阅的用户/Subscribed users

@end


@interface LivingRoomViewController (Hummer)

- (void)hummer_viewDidLoad;
- (void)hummer_setup;

// 申请订阅观众
// Subscribe to viewers
- (void)hummer_applySubscribeUser:(HMRUser *)user;

// 发送消息
// Send a message
- (void)hummer_sendMessage:(NSString *)message;

// 移除相关hummer监听
// Remove related hummer monitoring
- (void)hummer_removeDependentObserver;

- (void)hummer_popToJoinRoomViewController;

- (void)hummer_operationViewDidTapOnsubscribeButton:(LivingOperationView *)operationView;


@end
