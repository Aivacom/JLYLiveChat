//
//  LivingRoomViewController.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/9/24.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingRoomViewController.h"
#import "Masonry.h"
#import "CommonMacros.h"
#import "MBProgressHUD+HUD.h"
#import "IQKeyboardManager.h"
#import "UIViewController+BaseViewController.h"

#import "HummerManager.h"
#import "ThunderManager.h"

#import "LivingOperationView.h"
#import "CanvasView.h"
#import "ToolBar.h"
#import "MessageSendView.h"
#import "MessageCell.h"

#import "FeedbackViewController.h"
#import "MemberListViewController.h"

#import "LivingRoomViewController+Thunder.h"
#import "LivingRoomViewController+Hummer.h"



static NSString * const kFeedbackAppId = @"JLYLiveChat-ios"; // 对接反馈系统AppID/Docking feedback system AppID

static NSString * const kMessageCellReuseIdentifier = @"MessageCell";


@interface LivingRoomViewController () <UITableViewDelegate, UITableViewDataSource, LivingOperationViewDelegate, ToolBarDelegate, MessageSendViewDelegate>




@end

@implementation LivingRoomViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBaseSetting];
    
    [self hummer_viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.presentedViewController) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}

- (void)setup {
    self.messageList = [[NSMutableArray alloc] init];
    
    [self setupSubviews];
    [self fitKeyboard];
    
    // Thunder相关初始化
    // Thunder related initialization
    [self thunder_setup];
    
    // Hummer相关初始化
    // Hummer related initialization
    [self hummer_setup];
}


- (void)dealloc {
    
}


#pragma mark - Private


- (void)setupSubviews {
    // 顶部操作区
    // Top operating area
    self.livingOperationView = [[LivingOperationView alloc] initWithChatRoom:_chatRoom];
    _livingOperationView.delegate = self;
    
    [self.view addSubview:_livingOperationView];
    
    [_livingOperationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(108);
    }];
    
    NSString *title = [self thunder_titleForPublishMode:self.thunderManager.publishMode];
    [self.livingOperationView setPublishModeTitle:title];
    
    
    
    // 直播视图
    // Live view
    self.localCanvasView = [[CanvasView alloc] init];
    
    [self.view addSubview:_localCanvasView];
    [_localCanvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.livingOperationView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo((3/4.0f)*kScreenWidth);
    }];
    
    self.remoteCanvasView = [[CanvasView alloc] init];
    
    [self.view addSubview:_remoteCanvasView];
    [_remoteCanvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.livingOperationView.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo((3/4.0f)*kScreenWidth);
    }];
    
    
    
    // 消息视图
    // Message view
    self.messageTableView = [[UITableView alloc] initWithFrame:self.normalMessageTableViewFrame];
    _messageTableView.backgroundColor = [UIColor clearColor];
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messageTableView.contentInset = UIEdgeInsetsMake(10, 0, 27, 0);
    [self.view addSubview:_messageTableView];
    _messageTableView.tableFooterView = [[UIView alloc] init];
    [_messageTableView registerClass:[MessageCell class] forCellReuseIdentifier:kMessageCellReuseIdentifier];
    
    
    // 底部工具栏
    // Bottom toolbar
    self.toolBar = [[ToolBar alloc] init];
    _toolBar.delegate = self;
    
    [self.view addSubview:_toolBar];
    
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(60);
        make.bottom.mas_equalTo(-kBottomOffset);
    }];
    
    
    CGFloat height = kScreenHeight - kBottomOffset - 52;
    
    self.messageSendView = [[MessageSendView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 52)];
    _messageSendView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _messageSendView.delegate = self;
    _messageSendView.hidden = YES;
    
    [self.view addSubview:_messageSendView];

}

- (CGRect)normalMessageTableViewFrame {
    CGFloat tableViewY = kStatusBarHeight + 108 + (3/4.0f)*kScreenWidth;
    CGFloat tableViewHeight = kScreenHeight - tableViewY - 52 - kBottomOffset;
    return CGRectMake(0, tableViewY, kScreenWidth, tableViewHeight);
}


- (void)fitKeyboard {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (!self.messageSendView.isTextViewFirstResponder) {
            return;
        }
        
        CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        CGFloat canvasViewHeight = (3/4.0f)*kScreenWidth;
        CGFloat canvasViewY = kStatusBarHeight + 108;

        CGFloat offset = keyboardFrame.origin.y - 52 - canvasViewY;
        if (offset > canvasViewHeight) {
            offset = 0;
        } else {
            offset = canvasViewHeight - offset;
        }
        
        self.messageTableView.contentInset = UIEdgeInsetsMake(10, 0, 27 + offset, 0);
        
        self.messageSendView.hidden = NO;
        // 避免文字重叠
        // Avoid overlapping text
        [self.localCanvasView hideUid:YES];
        [self.remoteCanvasView hideUid:YES];

        [UIView animateWithDuration:duration animations:^{
            CGFloat height = kScreenHeight - keyboardFrame.size.height - 52;
            self.messageSendView.frame = CGRectMake(0, height, kScreenWidth, 52);
            self.messageTableView.frame = CGRectMake(0, canvasViewY, kScreenWidth, canvasViewHeight);
            self.messageTableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
            
            if (self.messageList.count > 0) {
                [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
        }];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (!self.messageSendView.isTextViewFirstResponder) {
            return;
        }
        NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        self.messageTableView.contentInset = UIEdgeInsetsMake(10, 0, 27, 0);

        self.messageSendView.hidden = YES;
        // 避免文字重叠
        // Avoid overlapping text
        [self.localCanvasView hideUid:NO];
        [self.remoteCanvasView hideUid:NO];
        
        [UIView animateWithDuration:duration animations:^{
            CGFloat height = kScreenHeight - kBottomOffset - 52;
            self.messageSendView.frame = CGRectMake(0, height, kScreenWidth, 52);
            self.messageTableView.frame = self.normalMessageTableViewFrame;
            self.messageTableView.backgroundColor = [UIColor clearColor];
            
            if (self.messageList.count > 0) {
                 [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
             }
        }];
    }];
}




#pragma mark - Public

- (instancetype)initWithChatRoom:(HMRChatRoom *)chatRoom {
    self = [super init];
    if (self) {
        _chatRoom = chatRoom;
    }
    return self;
}




#pragma mark - LivingOperationViewDelegate

- (void)operationViewDidTapOnPublishModeButton:(LivingOperationView *)operationView {
    [self thunder_operationViewDidTapOnPublishModeButton:operationView];
}

- (void)operationViewDidTapOnLiveButton:(LivingOperationView *)operationView {
    [self thunder_operationViewDidTapOnLiveButton:operationView];
}


- (void)operationViewDidTapOnMemberButton:(LivingOperationView *)operationView {
    MemberListViewController *memberListViewController = [[MemberListViewController alloc] initWithChatRoom:_chatRoom];
    memberListViewController.livingRoomViewController = self;
    [self.navigationController pushViewController:memberListViewController animated:YES];
}

- (void)operationViewDidTapOnCloseRoomButton:(LivingOperationView *)operationView {
    if (self.thunderManager.isLocalUserLiving) {
        [MBProgressHUD showToast:@"请关闭直播再退出房间"];
        return;
    }
    
        
    [self hummer_removeDependentObserver];
    
    // 退出房间，退出房间后订阅和直播都失效了
    // After exiting the room, the subscription and live broadcast are invalid after exiting the room
    [self.thunderManager leaveRoom];
    
    // 离开聊天室
    // Leave chat room
    [[HMRChatRoomService instance] leaveChatRoom:_chatRoom completionHandler:^(NSError *error) {
        if (error) {
            kLog(@"Leave chat room error: %@", error);
        }
    }];
    
    // 清除所有状态记录
    // Clear all status records
    [self.thunderManager clearLiveStatus];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)operationViewDidTapOnsubscribeButton:(LivingOperationView *)operationView {
    [self hummer_operationViewDidTapOnsubscribeButton:operationView];
}



- (void)operationView:(LivingOperationView *)operationView didSelectedUser:(HMRUser *)user {
    [self hummer_applySubscribeUser:user];
    
    // 初始化远端用户Thunder信息
    // Initialize Thunder information for remote users
    NSString *remoteUid = [NSString stringWithFormat:@"%llu", user.ID];
    // 各平台约定好的规则：信令房间号+用户ID
    // Rules agreed by each platform: signaling room number + user ID
    NSString *remoteRoomId = [NSString stringWithFormat:@"%llu%@", _chatRoom.ID, remoteUid];
    // 更新远端用户信息
    // Update remote user information
    [self.thunderManager updateRemoteUserInfoWithUid:remoteUid roomId:remoteRoomId];
}


#pragma mark - ToolBarDelegate

- (void)toolBarDidTapOnCameraSwitchButton:(ToolBar *)toolBar {
    [self thunder_toolBarDidTapOnCameraSwitchButton:toolBar];
}

- (void)toolBarDidTapOnVoiceButton:(ToolBar *)toolBar {
    [self thunder_toolBarDidTapOnVoiceButton:toolBar];
}

- (void)toolBarDidTapOnChatButton:(ToolBar *)toolBar {
    [_messageSendView textViewBecomeFirstResponder];
}



- (void)toolBarDidTapOnFeedbackButton:(ToolBar *)toolBar {
    [self onFeedbackButtonClick];
}


#pragma mark - MessageSendViewDelegate
- (void)messageSendView:(MessageSendView *)messageSendView shouldSendMessage:(NSString *)message {
    // SDK最长支持1200个字符
    // SDK supports up to 1200 characters
    if (message.length > 1200) {
        [MBProgressHUD showToast:@"输入字数已达上限"];
        return;
    }
    
    [self hummer_sendMessage:message];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <ChatMessageProtocol> message = _messageList[indexPath.row];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellReuseIdentifier forIndexPath:indexPath];
    [cell setupDataWithChatMessage:message];
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <ChatMessageProtocol> message = _messageList[indexPath.row];
    return message.cellHeight;
}






#pragma mark - Feedback
- (void)onFeedbackButtonClick {
    [self setupFeedbackManagerOnce];
    
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithUid:self.thunderManager.localUserInfo.uid];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)setupFeedbackManagerOnce {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FeedbackManager sharedManager].appId = kFeedbackAppId;
        [FeedbackManager sharedManager].appSceneName = @"livechat";
        [FeedbackManager sharedManager].functionDesc = @"1、实现聊天室视频连麦 \n2、支持禁言、踢出、关闭房间等功能  \n3、支持观众聊天、刷礼物互动";
        NSString* logPath = NSHomeDirectory();
        // ⁨Documents⁩ ▸ ⁨yylogger⁩ ▸ ⁨log⁩ ▸ ⁨Hummer⁩
        // /Documents/yylogger/log/Thunder
        logPath = [logPath stringByAppendingString:@"/Documents/yylogger"];
        [FeedbackManager sharedManager].logFilePath = logPath;
    });
}



#pragma mark - Get and Set

- (ThunderManager *)thunderManager {
    return [ThunderManager sharedManager];
}

- (HummerManager *)hummerManager {
    return [HummerManager sharedManager];
}


@end
