//
//  HummerManager.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/11.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <HMRCore/HMRCore.h>
#import <HMRChatRoom/HMRChatRoom.h>
#import "User.h"
#import "UserPickerData.h"



typedef void (^FetchMembersCompletionHandler) (NSArray<User *> *members, NSError *error);
typedef void (^FetchAudienceMembersCompletionHandler) (NSArray<UserPickerData *> *members, NSError *error);


extern NSString * const SignalContentApply;       // 申请开播/Apply broadcast
extern NSString * const SignalContentAccept;      // 接收开播/Receive broadcast
extern NSString * const SignalContentRefuse;      // 拒绝开播/Refuse broadcast
extern NSString * const SignalContentCancel;      // 取消开播/Cancle broadcast



@interface HummerManager : NSObject

@property (nonatomic, readonly, copy) NSString *uid;  // 用户Uid/ user id
@property (nonatomic, assign) BOOL isLoggedIn;  // 是否已登录/Is logged in



+ (instancetype)sharedManager;

// 初始化SDK
// Initialize SDK
- (void)setupHummerSDK;

// 登录
// login
- (void)loginWithUid:(NSString *)uid completionHandler:(HMRCompletionHandler)completionHandler;
// 退出
// quit
- (void)logoutWithCompletionHandler:(HMRCompletionHandler)completionHandler;

// 创建聊天室
// Create chatroom
- (void)createChatRoomWithCompletionHandler:(HMRChatRoomCompletionHandler)completionHandler;
// 加入聊天室
// join chatroom
- (void)joinChatRoomWithRoomId:(NSString *)roomId completionHandler:(HMRChatRoomCompletionHandler)completionHandler;


// 获取观众列表
// Get audience list
- (void)fetchAudienceMembersWithChatRoom:(HMRChatRoom *)chatRoom completionHandler:(FetchAudienceMembersCompletionHandler)completionHandler;

// 获取带有禁言状态的成员列表
// Get a list of members with mute status
- (void)fetchMembersWithChatRoom:(HMRChatRoom *)chatRoom completionHandler:(FetchMembersCompletionHandler)completionHandler;

// 发送单播消息
// Send unicast message
- (void)sendSignalMessage:(NSString *)message receiver:(HMRUser *)receiver chatRoom:(HMRChatRoom *)chatRoom completionHandler:(HMRCompletionHandler)completionHandler;


@end
