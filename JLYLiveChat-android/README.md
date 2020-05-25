## Use the process of Thunderbolt and Hummer

*中文版本: [简体中文](README.zh.md)*

We provide comprehensive user access documentation so that users can quickly access audio and video capabilities.If you want to know the specific integration method, interface description, and related scenario Demo, you can click the following link to learn:

> Integrate SDK to APP, please click:[SDK integration instructions](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_android.html)

> API development manual, please click: [Android API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Android/v2.7.0/category.html)

> For related Demo download, please click: [SDK and Demo Download](https://docs.aivacom.com/download)

### The implementation steps of ThunderBolt
（1）First create an instance of 'IThunderEngine' and initialize it.

```
        thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
```

（2）Join the room. Token requires a reference document to be obtained from the business server.

```
        //Set channel properties
        thunderEngine.setMediaMode(mediaMode);
        thunderEngine.setRoomMode(roomMode);
        //Join the room
        thunderEngine.joinRoom(token, channelName, uid);
```

（3）After entering the room successfully, determine whether he is the owner according to the business, if not,
then subscribe to the owner; If you're a homeowner, you can push audio and video.

```	
//owner step
        //Enabling sending of local audio.
        thunderEngine.stopLocalAudioStream(false);
        //Set video encoder’s property.
        thunderEngine.setVideoEncoderConfig();
        //Set local view display mode.
        thunderEngine.setLocalCanvasScaleMode(THUNDER_RENDER_MODE_CLIP_TO_BOUNDS);
        //Set local view.
        ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer, THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT, uid);
        thunderEngine.setLocalVideoCanvas(mPreviewView);
        //Enable local video capture.
        thunderEngine.enableLocalVideoCapture(true);
        //Enable video preview.
        thunderEngine.startVideoPreview();
        //Enable sending of local video stream.
        thunderEngine.stopLocalVideoStream(false);
        //Subscribe across the room.
        thunderEngine.addSubscribe(roomId, uid);

```

```
//The audience step
        //Subscribe across the room.
        thunderEngine.addSubscribe(roomId, uid);
```

（4）Subscribe to remote video and audio after receiving the homeowner's audio and video stream callback notifications.

```
        @Override
        public void onRemoteAudioStopped(String uid, boolean muted) {};
        @Override
        public void onRemoteVideoStopped(String uid, boolean muted) {};
```

（5）You can also stop sending local audio and video streams so that remote users will not be able to hear or see your voice or video.

```
        thunderEngine.stopLocalAudioStream(false);
        thunderEngine.stopLocalVideoStream(false);
```

（6）Switch camera

```
        thunderEngine.switchFrontCamera(bFront);
```

（7）leave the room.

```
        thunderEngine.leaveRoom();
```

### The implementation steps of Hummer

（1）Initialize SDK

```
        HMR.init(context, appId);
```

（2）Log in to SDK

```
        HMR.open(uid,region,tags,token,completion);
```

（3）add Listener

```
        //add Listener
        //Add a message listener
        HMR.getService(ChatService.class).addMessageListener();
        //Add a chatroom member listener
        HMR.getService(ChatRoomService.class).addMemberListener();
        //Add a chatroom listener
        HMR.getService(ChatRoomService.class).addListener();
        //Add a channel state listener
        HMR.getService(ChannelStateService.class).addChannelStateListener();
```
```
        //remove Listener
        //Remove a message listener
        HMR.getService(ChatService.class).removeMessageListener();
        //Remove a chatroom member listener
        HMR.getService(ChatRoomService.class).removeMemberListener();
        //Remove a chatroom listener
        HMR.getService(ChatRoomService.class).removeListener();
        //Remove a channel state listener
        HMR.getService(ChannelStateService.class).removeChannelStateListener();
```
```
        //callback
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

（3）Some operations in the chat room

```
        //Fetch a chatroom member list
        fetchMembers(@NonNull ChatRoom chatRoom,int num, int offset,@NonNull HMR.CompletionArg<List<User>> completion);
        //Fetch a muting list
        fetchMutedUsers(@NonNull ChatRoom chatRoom,@NonNull HMR.CompletionArg<Set<User>> completion);
        //Fetch a role list
        fetchRoleMembers(@NonNull ChatRoom chatRoom,boolean online,@NonNull HMR.CompletionArg<Map<String, List<User>>> completion);
        //A message sending interface: supports sending a public screen message (only a text message is supported), unicast and broadcast.
        send(@NonNull Message message, @Nullable HMR.Completion completion);
        //Kick users out of the chatroom
        kick(@NonNull ChatRoom chatRoom, @NonNull User member,@Nullable Map<EKickInfo, String> extraInfo,@NonNull HMR.Completion completion);
        //Mute members in a chatroom
        muteMember(@NonNull ChatRoom chatRoom, @NonNull User member,@Nullable String reason, @NonNull HMR.Completion completion);
```

（4）Log out SDK

```
        HMR.close();
```






































