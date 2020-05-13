//
//  ThunderManager.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/8/7.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "ThunderManager.h"
#import "Utils.h"
#import "CommonMacros.h"
#import "DataEnvironment.h"




@interface ThunderManager () <ThunderRtcLogDelegate>
@property (nonatomic, readwrite, strong) ThunderEngine *engine;                  // SDK引擎/SDK engine
@property (nonatomic, readwrite, strong) ThunderVideoCanvas *localVideoCanvas;   // 本地视频视图/Local video canvas
@property (nonatomic, readwrite, strong) ThunderVideoCanvas *remoteVideoCanvas;  // 远程视频视图/Remote video canvas
@property (nonatomic, readwrite, strong) NSString *logPath;                      // 日志路径/log file path
@property (nonatomic, readwrite, assign) ThunderPublishVideoMode publishMode;    // 视频编码类型/Video encoding type
@property (nonatomic, readwrite, copy) ThunderUserInfo *localUserInfo;    // 本地用户信息/Local user information
@property (nonatomic, readwrite, copy) ThunderUserInfo *remoteUserInfo;   // 远端用户信息/Remote user information
@property (nonatomic, readwrite, assign) BOOL isLocalUserLiving;                 // 是否本地用户在直播/Whether local users are live




@end

@implementation ThunderManager

+ (instancetype)sharedManager {
    static ThunderManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _publishMode = THUNDERPUBLISH_VIDEO_MODE_NORMAL;
}


#pragma mark - Public

- (void)setupEngineWithDelegate:(id<ThunderEventDelegate>)delegate {
    self.engine = [ThunderEngine createEngine:self.appId sceneId:0 delegate:delegate];
    
    // 设置区域：默认值（国内）
    // Setting area: default value (domestic)
    [_engine setArea:THUNDER_AREA_DEFAULT];
    
    // 处理App退出时未退出房间的异常
    // Handle the exception of not exiting the room when the app exits
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        // 不管在不在房间直接退出
        // Regardless of whether you exit the room
        [self.engine leaveRoom];
        
        // 销毁引擎
        // Destroy engine
        [ThunderEngine destroyEngine];
    }];
    
    
    // 设置SDK日志存储路径
    // Set SDK log storage path
    NSString* logPath = NSHomeDirectory();
    // 保持和Hummer在同一上传目录
    // Keep the same upload directory as Hummer
    self.logPath = [logPath stringByAppendingString:@"/Documents/yylogger/log/Thunder"];
    [_engine setLogFilePath:_logPath];
    
    // Debug模式下直接打印日志
    // Print logs directly in Debug mode
#ifdef DEBUG
//    [_engine setLogCallback:self];
#endif

}


- (void)destroyEngine {
    // 销毁引擎
    // Destroy engine
    [ThunderEngine destroyEngine];
}




- (void)joinRoom {
    // 设置房间属性。   如果不是指定纯音频模式的话，可以不设置，默认是音视频模式
    // // Set room properties. If you do not specify the pure audio mode, you can not set it, the default is the audio and video mode
    [_engine setMediaMode:THUNDER_CONFIG_NORMAL];     // 音视频模式：音视频模式/Audio and video mode: audio and video mode
    [_engine setRoomMode:THUNDER_ROOM_CONFIG_LIVE];   // 场景模式：直播/Scene mode: live broadcast
    
    // 设置音频属性。
    // Set audio properties.

    [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD
                 commutMode:THUNDER_COMMUT_MODE_HIGH
               scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
    
    // 加入房间
    // Join room
    [_engine joinRoom:self.token roomName:self.localUserInfo.roomId uid:self.localUserInfo.uid];
}

- (void)setupPublishMode {
    ThunderVideoEncoderConfiguration* videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    // 设置开播玩法为视频连麦开播
    // Set the start play method to start the video with wheat
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // 设置视频编码类型
    // Set video encoding type
    videoEncoderConfiguration.publishMode = _publishMode;
    
    // 每次进房间都需要再次设置，否则会使用默认配置
    // Each time you enter the room, you need to set it again, otherwise the default configuration will be used
    [_engine setVideoEncoderConfig:videoEncoderConfiguration];
}


- (void)leaveRoom {
    [_engine leaveRoom];
}

- (void)enableVideoLive {
    // 开启视频预览，在enableVideoEngine之前调用
    // Open video preview, call before enableVideoEngine
    [_engine startVideoPreview];

    // 开启本地视频流发送
    // Enable local video streaming
    [_engine stopLocalVideoStream:NO];
    
    // 打开音频采集，并开播到频道，音频流会自动打开，不需要再次调用stopLocalAudioStream
    // Open the audio collection, and start broadcasting to the channel, the audio stream will automatically open, no need to call stopLocalAudioStream again
    [_engine stopLocalAudioStream:NO];
    
    self.isLocalUserLiving = YES;
}



- (void)disableVideoLive {
    // 这里不能调disableVideoEngine，否则将导致订阅的用户直播看不到视频，调用enableLocalVideoCapture也将导致看不到画面
    // DisableVideoEngine cannot be adjusted here, otherwise it will cause the subscribers to subscribe to see no video in live broadcast, and calling enableLocalVideoCapture will also cause the screen not to be seen
    [_engine stopVideoPreview];
    [_engine stopLocalVideoStream:YES];

    
    // 这里不能调disableAudioEngine，否则将导致订阅的用户直播听不到音频
    // DisableAudioEngine cannot be adjusted here, otherwise it will cause the subscribed users to hear no audio in live broadcast
    [_engine stopLocalAudioStream:YES];

    
    self.isLocalUserLiving = NO;
}




- (ThunderVideoCanvas *)setupVideoCanvasForLocal:(BOOL)isLocalCanvas {

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
    
    return canvas;
}




#pragma mark - Subscribe

- (void)subscribeRemoteUser {
    // 订阅
    // subscription
    [_engine addSubscribe:self.remoteUserInfo.roomId uid:self.remoteUserInfo.uid];
}

- (void)unsubscribeRemoteUser {
    // 取消订阅
    // Cancal subscription
    [_engine removeSubscribe:self.remoteUserInfo.roomId uid:self.remoteUserInfo.uid];
}




#pragma mark - Operation


- (BOOL)switchFrontCamera:(BOOL)isFront {
    // 调用成功返回 0，失败返回 < 0
    // Successful call returns 0, failed returns <0
    return [_engine switchFrontCamera:isFront] == 0;
}




- (BOOL)disableLocalAudio:(BOOL)disabled {
    // 开关本地音频流
    // On or off local audio stream
    return [_engine stopLocalAudioStream:disabled] == 0;
    
}



- (void)updateToken {
    [_engine updateToken:self.token];
}


- (void)switchPublishMode:(ThunderPublishVideoMode)publishMode {
    self.publishMode = publishMode;
    [self setupPublishMode];
}





#pragma mark - UserInfo

- (void)updateLocalUserInfoWithUid:(NSString *)uid roomId:(NSString *)roomId {
    self.localUserInfo.uid = uid;
    self.localUserInfo.roomId = roomId;
}


- (void)updateRemoteUserInfoWithUid:(NSString *)uid roomId:(NSString *)roomId {
    self.remoteUserInfo.uid = uid;
    self.remoteUserInfo.roomId = roomId;
}



- (void)clearLiveStatus {
    self.isLocalUserLiving = NO;
    self.isRemoteUserLiving = NO;    
}




#pragma mark - ThunderRtcLogDelegate

- (void)onThunderRtcLogWithLevel:(ThunderRtcLogLevel)level message:(nonnull NSString*)msg {
    kLog(@"【RTC】level=%ld, %@", (long)level, msg);
}


#pragma mark - Get and Set

- (NSString *)appId {
    return [DataEnvironment sharedDataEnvironment].stringAppId;
}

- (ThunderVideoCanvas *)localVideoCanvas {
    if (_localVideoCanvas == nil) {
        _localVideoCanvas = [self videoCanvas];
    }
    
    return _localVideoCanvas;
}

- (ThunderVideoCanvas *)remoteVideoCanvas {
    if (_remoteVideoCanvas == nil) {
        _remoteVideoCanvas = [self videoCanvas];
    }
    
    return _remoteVideoCanvas;
}


- (ThunderVideoCanvas *)videoCanvas {
    // 创建视频视图
    // Create a video view
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    
    // 必须创建canvas时设置其view
    // The view must be set when the canvas is created
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    canvas.view = view;
    
    // 设置视频布局
    // Set video layout
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    
    return canvas;
}

- (ThunderUserInfo *)localUserInfo {
    if (_localUserInfo == nil) {
        _localUserInfo = [[ThunderUserInfo alloc] init];
    }
    return _localUserInfo;
}


- (ThunderUserInfo *)remoteUserInfo {
    if (_remoteUserInfo == nil) {
        _remoteUserInfo = [[ThunderUserInfo alloc] init];
    }
    return _remoteUserInfo;
}

- (NSString *)token {
    NSString *token = [[DataEnvironment sharedDataEnvironment] getTokenWithStingUid:self.localUserInfo.uid];
    return token;
}

- (BOOL)isLiving {
    return _isLocalUserLiving || _isRemoteUserLiving;
}

- (BOOL)isConnectedLiving {
    return _isLocalUserLiving && _isRemoteUserLiving;
}

- (void)setIsLocalUserLiving:(BOOL)isLocalUserLiving {
    _isLocalUserLiving = isLocalUserLiving;
    [self setIdleTimerStatus];
}

- (void)setIsRemoteUserOnline:(BOOL)isRemoteUserLiving {
    _isRemoteUserLiving = isRemoteUserLiving;
    [self setIdleTimerStatus];
}

- (void)setIdleTimerStatus {
    [UIApplication sharedApplication].idleTimerDisabled = self.isLiving;
}




@end
