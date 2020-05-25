*English Version: [English](README.md)*

## 概述
我们提供全面的用户接入文档，来方便用户实现音视频能力的快速接入，如果您想了解具体集成方法、接口说明、相关场景Demo，可点击如下链接了解：

> 集成SDK到APP，请参考：[SDK集成方法](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_android.html)

> API开发手册，请访问： [Android API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Android/v2.7.0/category.html)

> 相关Demo下载，请访问：[SDK及Demo下载](https://docs.aivacom.com/download)

## 使用 Thunderbolt 和 Hummer 流程

### ThunderBolt实现步骤
（1）首先创建一个`IThunderEngine`实例，并进行初始化操作。

```
        thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
```

（2）加入房间。token需要参考文档从业务服务器获取。

```
        //设置频道属性
        thunderEngine.setMediaMode(mediaMode);
        thunderEngine.setRoomMode(roomMode);
        //加入房间
        thunderEngine.joinRoom(token, channelName, uid);
```

（3）在进入房间成功后，根据业务判定自己是不是房主，如果不是，则订阅房主；如果是房主，可以音视频开播。

```	
//房主逻辑
        //开播 音频
        thunderEngine.stopLocalAudioStream(false);
        //设置视频模式
        thunderEngine.setVideoEncoderConfig();
        //设置本地视图缩放模式
        thunderEngine.setLocalCanvasScaleMode(THUNDER_RENDER_MODE_CLIP_TO_BOUNDS);
        //设置本地预览视图
        ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer, THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT, uid);
        thunderEngine.setLocalVideoCanvas(mPreviewView);
        //开启视频采集
        thunderEngine.enableLocalVideoCapture(true);
        //开启预览
        thunderEngine.startVideoPreview();
        //开播 视频
        thunderEngine.stopLocalVideoStream(false);
        //订阅观众（连麦）
        thunderEngine.addSubscribe(roomId, uid);

```

```
//观众逻辑
//订阅房主
        thunderEngine.addSubscribe(roomId, uid);
```

（4）在收到房主的音频、视频流回调通知（`onRemoteAudioStopped`、`onRemoteVideoStopped`）后订阅远端视频和音频。

```
        @Override
        public void onRemoteAudioStopped(String uid, boolean muted) {};
        @Override
        public void onRemoteVideoStopped(String uid, boolean muted) {};
```

（5）您还可以停止发送本地音视频流，这样远端用户将听不到或看不见你的声音或视频。

```
        thunderEngine.stopLocalAudioStream(false);
        thunderEngine.stopLocalVideoStream(false);
```

（6）切换摄像头

```
        thunderEngine.switchFrontCamera(bFront);
```

（7）退出房间。

```
        thunderEngine.leaveRoom();
```

### Hummer实现步骤

（1）初始化Hummer

```
        HMR.init(context, appId);
```

（2）登录SDK

```
        HMR.open(uid,region,tags,token,completion);
```

（3）添加监听

```
        //添加监听
        //添加消息监听
        HMR.getService(ChatService.class).addMessageListener();
        //添加聊天室成员监听
        HMR.getService(ChatRoomService.class).addMemberListener();
        //添加聊天室监听
        HMR.getService(ChatRoomService.class).addListener();
        //添加通道状态通知的监听器
        HMR.getService(ChannelStateService.class).addChannelStateListener();
```
```
        //移除监听
        //移除消息监听
        HMR.getService(ChatService.class).removeMessageListener();
        //移除聊天室成员监听
        HMR.getService(ChatRoomService.class).removeMemberListener();
        //移除聊天室监听
        HMR.getService(ChatRoomService.class).removeListener();
        //移除通道状态通知的监听器
        HMR.getService(ChannelStateService.class).removeChannelStateListener();
```
```
        //对应回调

        //MessageListener
        beforeSendingMessage(@NonNull Message message);
        afterSendingMessage(@NonNull Message message);
        beforeReceivingMessage(@NonNull Message message);
        afterReceivingMessage(@NonNull Message message);

        //MemberListener
        onMemberJoined(@NonNull ChatRoom chatRoom, @NonNull List<User> members);
        onMemberLeaved(@NonNull ChatRoom chatRoom,@NonNull List<User> members,int type,@NonNull String reason);
        onMemberCountChanged(@NonNull ChatRoom chatRoom, int count);
        onMemberKicked(@NonNull ChatRoom chatRoom,@NonNull User admin,@NonNull List<User> members,@NonNull String reason);
        onRoleAdded(@NonNull ChatRoom chatRoom,@NonNull String role,@NonNull User admin,@NonNull User fellow);
        onRoleRemoved(@NonNull ChatRoom chatRoom,@NonNull String role,@NonNull User admin,@NonNull User fellow);
        onMemberMuted(@NonNull ChatRoom chatRoom,@NonNull User operator,@NonNull Set<User> members,@Nullable String reason);
        onMemberUnmuted(@NonNull ChatRoom chatRoom,@NonNull User operator,@NonNull Set<User> members,@Nullable String reason);
        onUserInfoSet(@NonNull ChatRoom chatRoom,@NonNull User user,@NonNull Map<String, String> infoMap);
        onUserInfoDeleted(@NonNull ChatRoom chatRoom,@NonNull User user,@NonNull Map<String, String> infoMap);

        //ChatRoomListener
        onChatRoomDismissed(@NonNull ChatRoom chatRoom, @NonNull User member);
        onBasicInfoChanged(@NonNull ChatRoom chatRoom,@NonNull Map<ChatRoomInfo.BasicInfoType, String> propInfo);

        // ChannelStateListener
        onUpdateChannelState(ChannelState fromState, ChannelState toState)
```

（3）聊天室的一些操作

```
        //获取聊天室在线成员列表
        fetchMembers(@NonNull ChatRoom chatRoom,int num, int offset,@NonNull HMR.CompletionArg<List<User>> completion);
        //获取聊天室内的禁言列表
        fetchMutedUsers(@NonNull ChatRoom chatRoom,@NonNull HMR.CompletionArg<Set<User>> completion);
        //获取聊天室带有角色的成员列表
        fetchRoleMembers(@NonNull ChatRoom chatRoom,boolean online,@NonNull HMR.CompletionArg<Map<String, List<User>>> completion);
        //发送消息接口：支持发送公屏消息（只支持文本消息）、单播、广播。
        send(@NonNull Message message, @Nullable HMR.Completion completion);
        //将用户踢出聊天室
        kick(@NonNull ChatRoom chatRoom, @NonNull User member,@Nullable Map<EKickInfo, String> extraInfo,@NonNull HMR.Completion completion);
        //禁言聊天室内的成员
        muteMember(@NonNull ChatRoom chatRoom, @NonNull User member,@Nullable String reason, @NonNull HMR.Completion completion);
```

（4）退出登录SDK

```
        HMR.close();
```






































