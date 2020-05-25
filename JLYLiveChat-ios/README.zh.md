使用 ThunderBolt 和 Hummer::ChatRoom SDK 实现聊天室功能
======================================

English Version： [English](README.md)

<br />

概述
-------------------------------------------------------------
本文主要介绍如何使用 ThunderBolt 和 Hummer::ChatRoom iOS版本SDK实现聊天室功能，基于该场景，将对实现步骤做简要说明。

我们提供全面的用户接入文档，来方便用户实现音视频能力的快速接入，如果您想了解具体集成方法、接口说明、相关场景Demo，可点击如下链接了解：

> 集成SDK到APP，请参考：[SDK集成方法](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_ios.html)

> API开发手册，请访问： [IOS API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/iOS/v2.7.0/category.html)

> 相关Demo下载，请访问：[SDK及Demo下载](https://docs.aivacom.com/download)

<br />
   
引用API
-------------------------------------------------------------

### 方法接口

#### ThunderBolt

* `createEngine:sceneId:delegate:`
* `setArea:`

<br />

* `setMediaMode:`
* `setRoomMode:`
* `setAudioConfig:commutMode:scenarioMode:`
* `joinRoom:roomName:uid:`  
* `setVideoEncoderConfig:`

<br />

* `startVideoPreview`

<br />

* `setLocalVideoCanvas:`
* `setLocalCanvasScaleMode:`
* `setRemoteVideoCanvas:`
* `setRemoteCanvasScaleMode:mode:`   

<br />

* `switchFrontCamera:`   
* `updateToken:`   

<br />

* `leaveRoom`   

<br />

* `destroyEngine`   

<br />

#### Hummer::ChatRoom

* `initWithMode`   
* `registerChannel`   
* `startSDKWithAppId`  

<br />

* `openWithUid`  
* `createChatRoom`  
* `joinChatRoom`  

<br />

* `fetchMembers`  
 * `fetchMutedUsers`  
 
 <br />
 
* `sendSignalMessage`  
* `sendMessage`  

<br />

* `leaveChatRoom` 
* `closeWithCompletionHandler`  

<br />
<br />

### 代理方法

#### ThunderBolt
* `thunderEngine:onJoinRoomSuccess:withUid:elapsed:`
* `thunderEngine:onLeaveRoomWithStats:`
* `thunderEngine:sdkAuthResult:`
* `thunderEngine:onRemoteAudioStopped:byUid:`
* `thunderEngine:onRemoteVideoStopped:byUid:`
* `thunderEngine:onRoomStats:`
* `thunderEngine:onTokenWillExpire:`
* `thunderEngineTokenRequest:`

#### Hummer::ChatRoom
* `willSendMessage:`
* `didSendMessage:`
* `didReceiveMessage:`
* `chatRoom:didDismissByOperator:`
* `chatRoom:didJoinMembers:`
* `chatRoom:didLeaveMembers:reason:leavingType:`
* `chatRoom:didKickMembers:byOperator:reason:`
* `chatRoom:didMuteMembers:byOperator:reason`
* `chatRoom:didUnmuteMembers:byOperator:reason`

<br />
<br />

ThunderBolt实现步骤
-------------------------------------------------------------
（1）首先初始化SDK并创建一个`ThunderEngine`全局实例

```objective-c

    self.engine = [ThunderEngine createEngine:kThunderAppId sceneId:0 delegate:delegate];

```  

（2）初始化一些全局配置

```objective-c

    // 设置区域：默认值（国内）
    [_engine setArea:THUNDER_AREA_DEFAULT];

```

（3）加入房间，需在加入房间前根据需要配置房间属性等

```objective-c

    // 设置房间属性。   如果不是指定纯音频模式的话，可以不设置，默认是音视频模式
    [_engine setMediaMode:THUNDER_CONFIG_NORMAL];     // 音视频模式：音视频模式；
    [_engine setRoomMode:THUNDER_ROOM_CONFIG_LIVE];   // 场景模式：直播

    // 设置音频属性。
    [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD // 采样率，码率，编码模式和声道数：44.1 KHz采样率，音乐编码, 双声道，编码码率约 40；
                 commutMode:THUNDER_COMMUT_MODE_HIGH            // 交互模式：强交互模式
               scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];     // 场景模式：默认


    // 加入房间
    [_engine joinRoom:_token roomName:roomId uid:self.localUid];

```

（4）在收到加入房间成功回调后（`onJoinRoomSuccess:withUid:elapsed:`），可以设置开播档位，发布本地音、视频流

```objective-c

    ThunderVideoEncoderConfiguration* videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    // 设置开播玩法为视频连麦开播
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // 设置视频编码类型
    videoEncoderConfiguration.publishMode = _publishMode;

    // 每次进房间都需要再次设置，否则会使用默认配置
    [_engine setVideoEncoderConfig:videoEncoderConfiguration];

    // 开启视频预览
    [_engine startVideoPreview];
    
    // 开启本地视频流发送
    [_engine stopLocalVideoStream:NO];
    
    // 开启本地音频流发送
    [_engine stopLocalAudioStream:NO];

```


（5）创建本地或者远端直播视图

```objective-c

    ThunderVideoCanvas *canvas = nil;
    if (isLocalCanvas) {
        // 设置本地用户uid
        // Set local user id
        [self.localVideoCanvas setUid:self.localUserInfo.uid];
        
        // 设置本地视图
        // Set local view
        [_engine setLocalVideoCanvas:self.localVideoCanvas];
        // 设置本地视图显示模式
        // Set the local view display mode
        [_engine setLocalCanvasScaleMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
        
        canvas = self.localVideoCanvas;
        
    } else {
        // 设置远端用户uid
        // Set the remote user id
        [self.remoteVideoCanvas setUid:self.remoteUserInfo.uid];
        
        // 设置远端视图
        // Set remote canvas
        [_engine setRemoteVideoCanvas:self.remoteVideoCanvas];
        // 设置远端视图显示模式
        // Set the remote canvas display mode
        [_engine setRemoteCanvasScaleMode:self.remoteUserInfo.uid mode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
        
        canvas = self.remoteVideoCanvas;
    }

```

（6）您还可以切换前后置摄像头

```objective-c

    //  调用成功返回 0，失败返回 < 0
    [_engine switchFrontCamera:isFront];

```

（8）可以关闭本地音，视频流

```objective-c

    // 这里不能调disableVideoEngine，否则将导致订阅的用户直播看不到视频，调用enableLocalVideoCapture也将导致看不到画面
    [_engine stopVideoPreview];
    [_engine stopLocalVideoStream:YES];

    
    // 这里不能调disableAudioEngine，否则将导致订阅的用户直播听不到音频
    [_engine stopLocalAudioStream:YES];

```

（9）连麦结束后离开房间

```objective-c

    [_engine leaveRoom];

```

（10）最后在收到程序要退出的通知时销毁`ThunderEngine`实例并做一些异常处理

```objective-c

    // 防止退出后，用户还停留在房间一段时间
    [self.engine leaveRoom];

    // 销毁引擎
    [ThunderEngine destroyEngine];

```

Hummer::ChatRoom实现步骤
-------------------------------------------------------------

（1）初始化SDK

```objective-c

    // 1. 创建 Hummer 通道
    HMRServiceChannel *channel = [[HMRServiceChannel alloc] initWithMode:[HMRServiceChannelAutonomousMode modeWithTokenType:HMRTokenTypeThird]];
    // 2. 注册 Hummer 通道
    [Hummer registerChannel:channel completionHandler:^(NSError *error) {
        
    }];
    // 3. 初始化 Hummer SDK
    [Hummer startSDKWithAppId:UInt64AppId];

```

（2）登录SDK

```objective-c

    [Hummer openWithUid:uid.longLongValue environment:@"china/private/share" msgFetchStrategy:HMRContinuously tags:nil token:token completionHandler:^(NSError *error) {
    
    }];

```

（3）创建聊天室

```objective-c

    // 创建聊天室信息
    HMRChatRoomInfo *chatRoomInfo = [HMRChatRoomInfo chatRoomInfoWithName:roomName description:roomName bulletin:nil appExtra:nil];
    // 创建聊天室
    [[HMRChatRoomService instance] createChatRoom:chatRoomInfo completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        if (error) {

    }];

```

（4）加入聊天室

```objective-c

    HMRChatRoom *chatRoom = [HMRChatRoom chatRoomWithID:roomId.longLongValue];
    [[HMRChatRoomService instance] joinChatRoom:chatRoom extraProps:nil completionHandler:^(NSError *error) {
        
    }];

```
（5）获取聊天室成员列表

```objective-c

    // 获取聊天室成员列表
    [[HMRChatRoomService instance] fetchMembers:chatRoom offset:0 num:100 completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {

    }];

```

（6）获取聊天室内的禁言列表

```objective-c

    // 获取聊天室内的禁言列表
    [[HMRChatRoomService instance] fetchMutedUsers:chatRoom completionHandler:^(NSSet<HMRUser *> *mutedMembers, NSError * _Nullable mutedError) {
        
    }];

```

（7）发送单播消息

```objective-c

    // 发送消息
    [self.hummerManager sendSignalMessage:SignalContentCancel receiver:self.subscribedUser chatRoom:self.chatRoom completionHandler:^(NSError *error) {
            
    }];

```

（8）发送广播消息

```objective-c

    HMRMessage *hmrMessage = [HMRMessage messageWithContent:[HMRTextContent contentWithText:message]
                                                    receiver:self.chatRoom];
    // 发送消息
    [[HMRChatService instance] sendMessage:hmrMessage completionHandler:^(NSError *error) {
        
    }];

```

（9）离开聊天室

```objective-c

    // 离开聊天室
    [[HMRChatRoomService instance] leaveChatRoom:_chatRoom completionHandler:^(NSError *error) {
        
    }];

```

（10）退出SDK

```objective-c

    // 退出登录
    [Hummer closeWithCompletionHandler:^(NSError *error) {
        
    }];

```


