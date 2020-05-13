//
//  LivingRoomViewController+Thunder.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingRoomViewController.h"
#import "ThunderManager.h"



@interface LivingRoomViewController () <ThunderEventDelegate>
@property (nonatomic, assign) BOOL isUseFrontCamera;    // 是否使用的前置摄像头

@end


@interface LivingRoomViewController (Thunder)

- (void)thunder_setup;

// 加入Thunder房间
// Join the Thunder room
- (void)thunder_joinRoom;

// 开播
// Start broadcasting
- (void)thunder_enableVideoLive;
// 停播
// Stop broadcasting
- (void)thunder_disableVideoLive;

// 取消订阅远程用户
// Unsubscribe a remote user
- (void)thunder_unsubscribeRemoteUser;

// 调整直播视图
// Adjust live view
- (void)thunder_adjustCanvasView;


- (NSString *)thunder_titleForPublishMode:(ThunderPublishVideoMode)publishMode;


- (void)thunder_operationViewDidTapOnPublishModeButton:(LivingOperationView *)operationView;
- (void)thunder_operationViewDidTapOnLiveButton:(LivingOperationView *)operationView;

- (void)thunder_toolBarDidTapOnCameraSwitchButton:(ToolBar *)toolBar;
- (void)thunder_toolBarDidTapOnVoiceButton:(ToolBar *)toolBar;


@end
