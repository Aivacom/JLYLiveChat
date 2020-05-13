//
//  ThunderManager.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/8/7.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ThunderEngine.h"
#import "ThunderUserInfo.h"


@interface ThunderManager : NSObject
@property (nonatomic, readonly, strong) ThunderEngine *engine;                  // SDK引擎/SDK engine
@property (nonatomic, readonly, strong) ThunderVideoCanvas *localVideoCanvas;   // 本地视频视图/Local video canvas
@property (nonatomic, readonly, strong) ThunderVideoCanvas *remoteVideoCanvas;  // 远程视频视图/Remote video canvas
@property (nonatomic, readonly, strong) NSString *logPath;                      // 日志路径/log file path
@property (nonatomic, readonly, assign) ThunderPublishVideoMode publishMode;    // 视频编码类型/Video encoding type

@property (nonatomic, readonly, copy) ThunderUserInfo *localUserInfo;         // 本地用户信息/Local user information
@property (nonatomic, readonly, copy) ThunderUserInfo *remoteUserInfo;        // 远端用户信息/Remote user information

@property (nonatomic, readonly, assign) BOOL isLocalUserLiving;                 // 是否本地用户在直播/Whether local users are live
@property (nonatomic, assign) BOOL isRemoteUserLiving;                          // 是否订阅的用户在直播（对于观众，自动订阅房主，房主为远端用户；对于房主，手动订阅观众，观众为远端用户）/Whether the user who subscribes is live broadcast (for the viewer, the homeowner is automatically subscribed, the homeowner is the remote user; for the homeowner, the viewer is manually subscribed, the viewer is the remote user)
@property (nonatomic, readonly, assign) BOOL isLiving;                          // 是否正在直播，isLocalUserLiving和isRemoteUserLiving任何一个值为YES，该值为YES/Whether it is live broadcast, isLocalUserLiving and isRemoteUserLiving are either YES, the value is YES
@property (nonatomic, readonly, assign) BOOL isConnectedLiving;                 // 是否在连麦直播，isLocalUserLiving和isRemoteUserLiving值均为YES/Whether live broadcast in Lianmai, isLocalUserLiving and isRemoteUserLiving values are YES








+ (instancetype)sharedManager;

// 初始化SDK
// Initialize SDK
- (void)setupEngineWithDelegate:(id<ThunderEventDelegate>)delegate;

// 销毁SDK
// Destroy the SDK
- (void)destroyEngine;

// 加入房间
// Join room
- (void)joinRoom;

// 设置视频配置
// Set video configuration
- (void)setupPublishMode;

// 退出房间
// Exit the room
- (void)leaveRoom;

// 开启直播
// Start live
- (void)enableVideoLive;

// 关闭直播
// End live
- (void)disableVideoLive;

// 创建或更新视频视图
// Create or update video view
- (ThunderVideoCanvas *)setupVideoCanvasForLocal:(BOOL)isLocalCanvas;


// 订阅远端用户（对于房主，远端用户为观众，对于观众，远端用户为房主）
// Subscribe to remote users (for homeowners, the remote user is the viewer, for viewers, the remote user is the host)
- (void)subscribeRemoteUser;

// 取消订阅
// unsubscribe
- (void)unsubscribeRemoteUser;


// 切换摄像头
// Switch camera
- (BOOL)switchFrontCamera:(BOOL)isFront;

// 关闭本地音频流推送
// On or off local audio streaming
- (BOOL)disableLocalAudio:(BOOL)disabled;

// 更新token
// Update token
- (void)updateToken;

// 切换视频编码类型
// Switch video encoding type
- (void)switchPublishMode:(ThunderPublishVideoMode)publishMode;


// 更新本地用户信息
// Update local user information
- (void)updateLocalUserInfoWithUid:(NSString *)uid roomId:(NSString *)roomId;

// 更新远端用户信息
// Update remote user information
- (void)updateRemoteUserInfoWithUid:(NSString *)uid roomId:(NSString *)roomId;


// 清除各个状态记录
// Clear all status records
- (void)clearLiveStatus;


@end
