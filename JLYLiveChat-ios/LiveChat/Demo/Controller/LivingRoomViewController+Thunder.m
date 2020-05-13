//
//  LivingRoomViewController+Thunder.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingRoomViewController+Thunder.h"
#import "Masonry.h"
#import "Utils.h"
#import "CommonMacros.h"
#import "MBProgressHUD+HUD.h"
#import "UIView+Additions.h"
#import "UIViewController+AlertController.h"

#import "LivingOperationView.h"
#import "CanvasView.h"
#import "ToolBar.h"

#import "ThunderManager.h"


@implementation LivingRoomViewController (Thunder)

#pragma mark - Life cycle

- (void)thunder_setup {
    self.isUseFrontCamera = YES;

    // 初始化Thunder SDK
    // Initialize Thunder SDK
    [self.thunderManager setupEngineWithDelegate:self];
    
    
    // 初始化本地用户Thunder信息
    // Initialize local user Thunder information
    NSString *localUid = [NSString stringWithFormat:@"%llu", [HMRUser getMe].ID];
    // 各平台约定好的规则：信令房间号+用户ID
    // Rules agreed by each platform: signaling room number + user ID
    NSString *localRoomId = [NSString stringWithFormat:@"%llu%@", self.chatRoom.ID, localUid];
    [self.thunderManager updateLocalUserInfoWithUid:localUid roomId:localRoomId];
    
    // 自动加入房间
    // Automatically join the room
    [self thunder_joinRoom];
    
}


#pragma mark - Public

- (void)thunder_joinRoom {
    
    // 进入房间
    // Enter the room
    [MBProgressHUD showActivityIndicator];
    [self.thunderManager joinRoom];
    
    // 设置进房间超时时间，30S后如还未收到进房间回调，隐藏loading
    // Set the timeout period for entering the room. If the callback for entering the room has not been received after 30S, hide the loading
    [self performSelector:@selector(joinRoomTimeoutHandle) withObject:nil afterDelay:30];
}

- (void)joinRoomTimeoutHandle {
    [MBProgressHUD hideActivityIndicator];
}






// 开播
// Start broadcasting
- (void)thunder_enableVideoLive {
    // 请求权限
    // Request permission
    [Utils requestMediaAccessInViewController:self completionHandler:^(BOOL isAvailable) {
        if (isAvailable) {
            [self thunder_enableVideoLiveHandle];
        }
    }];
}


- (void)thunder_enableVideoLiveHandle {
    // 开播
    // Start broadcasting
    [self.thunderManager enableVideoLive];
    
    
    // 创建或更新本地视频视图
    // Create or update a local video view
    ThunderVideoCanvas *localCanvas = [self.thunderManager setupVideoCanvasForLocal:YES];
    if (!self.localCanvasView.hasSetupVideoCanvasView) {
        [self.localCanvasView setupWithVideoCanvasView:localCanvas.view];
    }
    
    [self.localCanvasView setUid:self.thunderManager.localUserInfo.uid];
    
    [self.livingOperationView updateLiveStatus:YES];
    [self.toolBar updateToolButtonsStatusWithLiveStatus:YES];
    
    // 调整直播视图
    // Adjust live view
    [self thunder_adjustCanvasView];
}

// 关播
// Off broadcast
- (void)thunder_disableVideoLive {
    // 关闭直播
    // Close live broadcast
    [self.thunderManager disableVideoLive];
    
    
    [self.livingOperationView updateLiveStatus:NO];
    [self.toolBar updateToolButtonsStatusWithLiveStatus:NO];
    
    // 调整直播视图显示
    // Adjust live view display
    [self thunder_adjustCanvasView];
    

    
    // 恢复使用前置摄像头
    // Return to front camera
    [self.thunderManager switchFrontCamera:YES];
    
    // 恢复静音图标状态
    // Restore mute icon status
    self.toolBar.muted = NO;
}



- (void)thunder_unsubscribeRemoteUser {
    // 退订用户
    // Unsubscribe users
    [self.thunderManager unsubscribeRemoteUser];
    self.thunderManager.isRemoteUserLiving = NO;
    
    // 房主需要恢复订阅按钮
    // Homeowner needs to resume subscription button
    if ([self.chatRoom sy_roomOwnerIsMe]) {
        [self.livingOperationView updatesubscribeStatus:NO];
    }
}


// 调整直播视图展示样式，房主视图永远在左边
// Adjust the live view display style, the homeowner view is always on the left
- (void)thunder_adjustCanvasView {
    [self.localCanvasView updateLiveStatus:self.thunderManager.isLocalUserLiving];
    [self.remoteCanvasView updateLiveStatus:self.thunderManager.isRemoteUserLiving];
    
    if (self.thunderManager.isLiving) {
        self.localCanvasView.hidden = !self.thunderManager.isLocalUserLiving;
        self.remoteCanvasView.hidden = !self.thunderManager.isRemoteUserLiving;
    } else {
        self.localCanvasView.hidden = NO;
        self.remoteCanvasView.hidden = NO;
                
        [self.localCanvasView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view);
            make.right.mas_equalTo(self.view);
        }];
        [self.remoteCanvasView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view);
            make.right.mas_equalTo(self.view);
        }];
    }
    
    
    if (self.thunderManager.isConnectedLiving) {
        [self.localCanvasView mas_updateConstraints:^(MASConstraintMaker *make) {
            if ([self.chatRoom sy_roomOwnerIsMe]) {
                make.left.mas_equalTo(self.view);
                make.right.mas_equalTo(-(1/2.0f)*kScreenWidth);
            } else {
                make.left.mas_equalTo((1/2.0f)*kScreenWidth);
                make.right.mas_equalTo(self.view);
            }
        }];
        
        [self.remoteCanvasView mas_updateConstraints:^(MASConstraintMaker *make) {
            if ([self.chatRoom sy_roomOwnerIsMe]) {
                make.left.mas_equalTo((1/2.0f)*kScreenWidth);
                make.right.mas_equalTo(self.view);
            } else {
                make.left.mas_equalTo(self.view);
                make.right.mas_equalTo(-(1/2.0f)*kScreenWidth);
            }
        }];
    } else {
        if (self.thunderManager.isLocalUserLiving) {
            [self.localCanvasView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view);
                make.right.mas_equalTo(self.view);
            }];
        }
        
        if (self.thunderManager.isRemoteUserLiving) {
            [self.remoteCanvasView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.view);
                make.right.mas_equalTo(self.view);
            }];
        }
    }
}



#pragma mark - thunder_

- (void)thunder_operationViewDidTapOnPublishModeButton:(LivingOperationView *)operationView {
    UIAlertController *alertController = [self actionSheetWithTitle:nil message:nil handler:^(UIAlertAction *action, NSUInteger index) {
        if (index != 3) {
            [self.livingOperationView setPublishModeTitle:action.title];
            
            ThunderPublishVideoMode publishMode = [self publishModeForTitle:action.title];
            if (self.thunderManager.publishMode != publishMode) {
                [self.thunderManager switchPublishMode:publishMode];
            }
            
        }
    } otherActionTitles:@"流畅", @"标清", @"高清", nil];
    
    if (@available(iOS 13.0, *)) {
        alertController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    // 对iPad做处理
    // Handle iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
        popPresenter.sourceView = operationView.publishModeButton;
        popPresenter.sourceRect = CGRectMake(operationView.publishModeButton.width - 19, operationView.publishModeButton.height/2.0f + 10, 0, 0);
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)thunder_operationViewDidTapOnLiveButton:(LivingOperationView *)operationView {
    if (self.thunderManager.isLocalUserLiving) {
        [self thunder_disableVideoLive];
    } else {
        [self thunder_enableVideoLive];
    }
}


- (void)thunder_toolBarDidTapOnCameraSwitchButton:(ToolBar *)toolBar {
    if ([self.thunderManager switchFrontCamera:!self.isUseFrontCamera]) {
        self.isUseFrontCamera = !self.isUseFrontCamera;
    } else {
        [MBProgressHUD showToast:@"切换摄像头失败，请稍后重试"];
    }
}

- (void)thunder_toolBarDidTapOnVoiceButton:(ToolBar *)toolBar {
    if ([self.thunderManager disableLocalAudio:!self.toolBar.muted]) {
        self.toolBar.muted = !self.toolBar.muted;
    } else {
        [MBProgressHUD showToast:@"静音失败，请稍后重试"];
    }
}




#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#pragma mark - ThunderEventDelegate

/*!
 @brief 进入房间回调/Enter room callback
 @param room 房间名/Room name
 @param uid 用户id/User id
 @elapsed 未实现/none
 */
- (void)thunderEngine: (ThunderEngine* _Nonnull)engine onJoinRoomSuccess:(nonnull NSString* )room withUid:(nonnull NSString*)uid elapsed:(NSInteger)elapsed {
    [MBProgressHUD hideActivityIndicator];
    // 取消超时操作
    // Cancel timeout operation
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(joinRoomTimeoutHandle) object:nil];
    
    // 设置视频编码配置
    // Set video encoding configuration
    [self.thunderManager setupPublishMode];
    
    // 如果是观众，远端用户则是房主，自动订阅房主
    // If it is an audience, the remote user is the homeowner and automatically subscribes to the homeowner
    if (![self.chatRoom sy_roomOwnerIsMe]) {
        // 初始化远端用户Thunder信息
        // Initialize Thunder information for remote users
        NSString *remoteUid = [NSString stringWithFormat:@"%llu", self.chatRoom.sy_roomOwner.ID];
        // 各平台约定好的规则：信令房间号+用户ID
        // Rules agreed by each platform: signaling room number + user ID
        NSString *remoteRoomId = [NSString stringWithFormat:@"%llu%@", self.chatRoom.ID, remoteUid];
        [self.thunderManager updateRemoteUserInfoWithUid:remoteUid roomId:remoteRoomId];
        
        // 自动订阅房主
        // Automatic subscription to homeowners
        [self.thunderManager subscribeRemoteUser];
    }
}

/*!
 @brief 离开房间/Leave room
 */
- (void)thunderEngine: (ThunderEngine* _Nonnull)engine onLeaveRoomWithStats:(ThunderRtcRoomStats* _Nonnull)stats {
    
}



/*!
 @brief sdk鉴权结果/sdk Authentication result
 @param sdkAuthResult 参见ThunderRtcSdkAuthResult/See ThunderRtcSdkAuthResult
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine sdkAuthResult:(ThunderRtcSdkAuthResult)sdkAuthResult {
    
}



/*!
 @brief 某个Uid用户的音频流状态变化回调/A user's audio stream status change callback
 @param stopped 流是否已经断开（YES:断开 NO:连接）/Whether the stream has been disconnected (YES: disconnected NO: connected)
 @param uid 对应的uid/User id
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRemoteAudioStopped:(BOOL)stopped byUid:(nonnull NSString *)uid {
    
}


/*!
 @brief 某个Uid用户的视频流状态变化回调/Callback of a Uid user's video stream status change
 @param stopped 流是否已经断开（YES:断开 NO:连接）/Whether the stream has been disconnected (YES: disconnected NO: connected)
 @param uid 对应的uid/user id
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRemoteVideoStopped:(BOOL)stopped byUid:(nonnull NSString *)uid {
    
    // 如果不是订阅用户则忽略掉/Ignore if it is not a subscriber
    if (![self.thunderManager.remoteUserInfo.uid isEqualToString:uid]) {
        return;
    }
    
    if (stopped) {
        // 观众收到房主关闭直播时，房主收到观众关闭直播时
        //When the audience receives the host to close the live broadcast
        self.thunderManager.isRemoteUserLiving = NO;
        [self thunder_adjustCanvasView];
        
        // 如果是房主，收到观众退出房间（主动关闭直播和被踢出的情况）消息后取消该用户的订阅
        //If it is the host, cancel the user's subscription after receiving the message that the audience quit the room (actively close the live broadcast and kicked out)
        if ([self.chatRoom sy_roomOwnerIsMe]) {
            [self thunder_unsubscribeRemoteUser];
        }

    } else {
        self.thunderManager.isRemoteUserLiving = YES;
        
        // 创建或更新远程视频视图
        // Create or update a remote video view
        ThunderVideoCanvas *remoteCanvas = [self.thunderManager setupVideoCanvasForLocal:NO];
        
        if (!self.remoteCanvasView.hasSetupVideoCanvasView) {
            [self.remoteCanvasView setupWithVideoCanvasView:remoteCanvas.view];
        }
        
        [self.remoteCanvasView setUid:uid];
        
        // 调整直播视图
        // Adjust live view
        [self thunder_adjustCanvasView];
    }
    
}





/*!
 @brief 鉴权服务即将过期回调/Authentication service is about to expire callback
 @param token 即将服务失效的Token/Token that is about to expire
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onTokenWillExpire:(nonnull NSString*)token {
    kLog(@"Token will expire");
    [self.thunderManager updateToken];
}

/*!
 @brief 鉴权过期回调/Authentication expired callback
 */
- (void)thunderEngineTokenRequest:(ThunderEngine * _Nonnull)engine {
    kLog(@"Token expired");
    
    // 如果onTokenWillExpire更新失败补救请求一次token
    // If onTokenWillExpire update fails, remedial request a token
    [self.thunderManager updateToken];
}




/*!
 @brief 网路上下行质量报告回调/Callback for network upstream and downstream quality reports
 @param uid 表示该回调报告的是持有该id的用户的网络质量，当uid为0时，返回的是本地用户的网络质量/Indicates that the callback reports the network quality of the user holding the id. When uid is 0, the network quality of the local user is returned
 @param txQuality 该用户的上行网络质量，参见ThunderLiveRtcNetworkQuality/The user's upstream network quality, see ThunderLiveRtcNetworkQuality
 @param rxQuality 该用户的下行网络质量，参见ThunderLiveRtcNetworkQuality/The user's downlink network quality, see ThunderLiveRtcNetworkQuality
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onNetworkQuality:(nonnull NSString*)uid txQuality:(ThunderLiveRtcNetworkQuality)txQuality rxQuality:(ThunderLiveRtcNetworkQuality)rxQuality {

    if ([uid isEqualToString:@"0"]) {
        [self.localCanvasView setTxQuality:txQuality];
    } else if ([uid isEqualToString:self.thunderManager.remoteUserInfo.uid]) {
        [self.remoteCanvasView setTxQuality:txQuality];
    }
}

#pragma clang diagnostic pop



#pragma mark - Get and Set

- (ThunderPublishVideoMode)publishModeForTitle:(NSString *)title {
    if ([title isEqualToString:@"流畅"]) {
        return THUNDERPUBLISH_VIDEO_MODE_FLUENCY;
    } else if ([title isEqualToString:@"标清"]) {
        return THUNDERPUBLISH_VIDEO_MODE_NORMAL;
    } else if ([title isEqualToString:@"高清"]) {
        return THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY;
    }
    return THUNDERPUBLISH_VIDEO_MODE_DEFAULT;
}


- (NSString *)thunder_titleForPublishMode:(ThunderPublishVideoMode)publishMode {
    if (publishMode == THUNDERPUBLISH_VIDEO_MODE_FLUENCY) {
        return @"流畅";
    } else if (publishMode == THUNDERPUBLISH_VIDEO_MODE_NORMAL) {
        return @"标清";
    } else if (publishMode == THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY) {
        return @"高清";
    }
    return @"";
}




@end
