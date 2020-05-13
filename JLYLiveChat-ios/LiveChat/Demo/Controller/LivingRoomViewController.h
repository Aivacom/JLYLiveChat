//
//  LivingRoomViewController.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/9/24.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HMRChatRoom/HMRChatRoom.h>
#import "ChatMessageProtocol.h"

@class LivingOperationView;
@class ToolBar;
@class MessageSendView;
@class CanvasView;
@class ThunderManager;
@class HummerManager;


@interface LivingRoomViewController : UIViewController
@property (nonatomic, strong) HMRChatRoom *chatRoom;
@property (nonatomic, strong) LivingOperationView *livingOperationView;
@property (nonatomic, strong) ToolBar *toolBar;
@property (nonatomic, strong) MessageSendView *messageSendView;
@property (nonatomic, strong) CanvasView *localCanvasView;
@property (nonatomic, strong) CanvasView *remoteCanvasView;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) NSMutableArray<id <ChatMessageProtocol>> *messageList;

- (instancetype)initWithChatRoom:(HMRChatRoom *)chatRoom;


- (void)setup;

- (ThunderManager *)thunderManager;
- (HummerManager *)hummerManager;


@end
