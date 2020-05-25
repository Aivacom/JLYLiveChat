Use ThunderBolt and Hummer :: ChatRoom SDK to implement chat room functions
======================================

中文版本：[简体中文](README.zh.md)

<br />

Overview
-------------------------------------------------------------
- This article mainly introduces how to use ThunderBolt and Hummer :: ChatRoom iOS SDK to implement the chat room function. Based on this scenario, the implementation steps will be briefly explained.

We provide comprehensive user access documentation so that users can quickly access audio and video capabilities.If you want to know the specific integration method, interface description, and related scenario Demo, you can click the following link to learn:

> Integrate SDK to APP, please click:[SDK integration instructions](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_android.html)

> API development manual, please click: [Android API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Android/v2.7.0/category.html)

> For related Demo download, please click: [SDK and Demo Download](https://docs.aivacom.com/download)

<br />
   
Reference API
-------------------------------------------------------------

### Method interface

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

### Delegate

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

ThunderBolt implementation steps
-------------------------------------------------------------
（1）First initialize the SDK and create a global instance of `ThunderEngine`

```objective-c

    self.engine = [ThunderEngine createEngine:kThunderAppId sceneId:0 delegate:delegate];

```  

（2）Initialize some global configuration

```objective-c

    // Setting area: default value (domestic)
    [_engine setArea:THUNDER_AREA_DEFAULT];

```

（3）To join a room, you need to configure the room properties as needed before joining the room

```objective-c

    // Set room properties.
    [_engine setMediaMode:THUNDER_CONFIG_NORMAL];    
    [_engine setRoomMode:THUNDER_ROOM_CONFIG_LIVE];  

    // Set audio properties.
    [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD 
                 commutMode:THUNDER_COMMUT_MODE_HIGH            
               scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];     


    // Join room
    [_engine joinRoom:_token roomName:roomId uid:self.localUid];

```

（4）After receiving the successful callback to join the room (`onJoinRoomSuccess: withUid: elapsed:`), you can set the start broadcast position and publish the local audio and video streams

```objective-c

    ThunderVideoEncoderConfiguration* videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    // Set the start play method to start the video with wheat
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // Set video encoding type
    videoEncoderConfiguration.publishMode = _publishMode;

    // Each time you enter the room, you need to set it again, otherwise the default configuration will be used
    [_engine setVideoEncoderConfig:videoEncoderConfiguration];

    // Open video preview
    [_engine startVideoPreview];
    
    // Enable local video streaming
    [_engine stopLocalVideoStream:NO];
    
    // Turn on local audio streaming
    [_engine stopLocalAudioStream:NO];

```


（5）Create a local or remote video canvas

```objective-c

    ThunderVideoCanvas *canvas = nil;
    if (isLocalCanvas) {
        // Set local user id
        [self.localVideoCanvas setUid:self.localUserInfo.uid];
        
        // Set local view
        [_engine setLocalVideoCanvas:self.localVideoCanvas];
        
        // Set the local view display mode
        [_engine setLocalCanvasScaleMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
        
        canvas = self.localVideoCanvas;
        
    } else {
        // Set the remote user id
        [self.remoteVideoCanvas setUid:self.remoteUserInfo.uid];
        
        // Set remote canvas
        [_engine setRemoteVideoCanvas:self.remoteVideoCanvas];
        
        // Set the remote canvas display mode
        [_engine setRemoteCanvasScaleMode:self.remoteUserInfo.uid mode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
        
        canvas = self.remoteVideoCanvas;
    }

```

（6）You can also switch front and rear cameras

```objective-c

    //  Successful call returns 0, failed returns <0
    [_engine switchFrontCamera:isFront];

```

（8）Can turn off local audio and video streaming

```objective-c

    [_engine stopVideoPreview];
    [_engine stopLocalVideoStream:YES];

    [_engine stopLocalAudioStream:YES];

```

（9）Leave Room

```objective-c

    [_engine leaveRoom];

```

（10）Finally, upon receiving the notification that the program wants to exit, destroy the `ThunderEngine` instance and do some exception handling

```objective-c

    // Prevent users from staying in the room for a while after logging out
    [self.engine leaveRoom];

    // Destroy engine
    [ThunderEngine destroyEngine];

```

Hummer :: ChatRoom implementation steps
-------------------------------------------------------------

（1）Initialize SDK

```objective-c

    // 1. Create a Hummer channel
    HMRServiceChannel *channel = [[HMRServiceChannel alloc] initWithMode:[HMRServiceChannelAutonomousMode modeWithTokenType:HMRTokenTypeThird]];
    
    // 2. Register for the Hummer channel
    [Hummer registerChannel:channel completionHandler:^(NSError *error) {
        
    }];
    
    // 3. Initialize the Hummer SDK
    [Hummer startSDKWithAppId:UInt64AppId];

```

（2）Login SDK

```objective-c

    [Hummer openWithUid:uid.longLongValue environment:@"china/private/share" msgFetchStrategy:HMRContinuously tags:nil token:token completionHandler:^(NSError *error) {
    
    }];

```

（3）Create chat room

```objective-c

    // Create chat room information
    HMRChatRoomInfo *chatRoomInfo = [HMRChatRoomInfo chatRoomInfoWithName:roomName description:roomName bulletin:nil appExtra:nil];
    
    // Create chat room
    [[HMRChatRoomService instance] createChatRoom:chatRoomInfo completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        if (error) {

    }];

```

（4）Join chat room

```objective-c

    HMRChatRoom *chatRoom = [HMRChatRoom chatRoomWithID:roomId.longLongValue];
    [[HMRChatRoomService instance] joinChatRoom:chatRoom extraProps:nil completionHandler:^(NSError *error) {
        
    }];

```
（5）Get a list of chat room members

```objective-c

    // Get a list of chat room members
    [[HMRChatRoomService instance] fetchMembers:chatRoom offset:0 num:100 completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {

    }];

```

（6）Get a list of bans in the chat room

```objective-c

    // Get a list of bans in the chat room
    [[HMRChatRoomService instance] fetchMutedUsers:chatRoom completionHandler:^(NSSet<HMRUser *> *mutedMembers, NSError * _Nullable mutedError) {
        
    }];

```

（7）Send unicast message

```objective-c

    // Send unicast message
    [self.hummerManager sendSignalMessage:SignalContentCancel receiver:self.subscribedUser chatRoom:self.chatRoom completionHandler:^(NSError *error) {
            
    }];

```

（8）Send broadcast message

```objective-c

    HMRMessage *hmrMessage = [HMRMessage messageWithContent:[HMRTextContent contentWithText:message]
                                                    receiver:self.chatRoom];
    // Send broadcast message
    [[HMRChatService instance] sendMessage:hmrMessage completionHandler:^(NSError *error) {
        
    }];

```

（9）Leave chat room

```objective-c

    // Leave chat room
    [[HMRChatRoomService instance] leaveChatRoom:_chatRoom completionHandler:^(NSError *error) {
        
    }];

```

（10）Sign out

```objective-c

    // sign out
    [Hummer closeWithCompletionHandler:^(NSError *error) {
        
    }];

```


