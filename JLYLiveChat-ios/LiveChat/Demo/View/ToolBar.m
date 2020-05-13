//
//  ToolBar.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "ToolBar.h"
#import "Masonry.h"
#import "CommonMacros.h"



@interface ToolBar ()
@property (nonatomic, readwrite, strong) UIButton *cameraSwitchButton;
@property (nonatomic, readwrite, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *chatButton;

@end

@implementation ToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Private

- (void)setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    // 功能按钮
    // Function button
    self.cameraSwitchButton = [[UIButton alloc] init];
    [_cameraSwitchButton setBackgroundImage:kImageNamed(@"toolbar_btn_camera_switch") forState:UIControlStateNormal];
    [_cameraSwitchButton setBackgroundImage:kImageNamed(@"toolbar_btn_camera_switch_tap") forState:UIControlStateHighlighted];
    [_cameraSwitchButton setBackgroundImage:kImageNamed(@"toolbar_btn_camera_switch_tap") forState:UIControlStateDisabled];
    
    [_cameraSwitchButton addTarget:self action:@selector(onCameraSwitchButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_cameraSwitchButton];
    [_cameraSwitchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
    }];
    
    
    self.voiceButton = [[UIButton alloc] init];
    [self updateVoiceButtonStatus:NO];
    
    [_voiceButton addTarget:self action:@selector(onVoiceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_voiceButton];
    [_voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.mas_equalTo(self.cameraSwitchButton.mas_right).offset(12);
        make.bottom.mas_equalTo(-12);
    }];
    
    
    self.chatButton = [[UIButton alloc] init];
    [_chatButton setBackgroundImage:kImageNamed(@"toolbar_btn_chat") forState:UIControlStateNormal];
    [_chatButton setBackgroundImage:kImageNamed(@"toolbar_btn_chat") forState:UIControlStateHighlighted];
    
    [_chatButton addTarget:self action:@selector(onChatButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_chatButton];
    [_chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.mas_equalTo(self.voiceButton.mas_right).offset(12);
        make.bottom.mas_equalTo(-12);
    }];
    
    
    
    UIButton *feedbackButton = [[UIButton alloc] init];
    [feedbackButton setBackgroundImage:kImageNamed(@"toolbar_btn_report") forState:UIControlStateNormal];
    [feedbackButton setBackgroundImage:kImageNamed(@"toolbar_btn_report_tap") forState:UIControlStateHighlighted];
    
    
    [feedbackButton addTarget:self action:@selector(onFeedbackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:feedbackButton];
    [feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(-12);
        make.bottom.mas_equalTo(-12);
    }];
    
    
    [self updateToolButtonsStatusWithLiveStatus:NO];
}


#pragma mark - Action

- (void)onCameraSwitchButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnCameraSwitchButton:)]) {
        [_delegate toolBarDidTapOnCameraSwitchButton:self];
    }
}

- (void)onVoiceButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnVoiceButton:)]) {
        [_delegate toolBarDidTapOnVoiceButton:self];
    }
}

- (void)onChatButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnChatButton:)]) {
        [_delegate toolBarDidTapOnChatButton:self];
    }
}


- (void)onFeedbackButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnFeedbackButton:)]) {
        [_delegate toolBarDidTapOnFeedbackButton:self];
    }
}


#pragma mark - Public

- (void)updateToolButtonsStatusWithLiveStatus:(BOOL)isLiving {
    _cameraSwitchButton.hidden = !isLiving;
    _voiceButton.hidden = !isLiving;
    
    [_chatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.bottom.mas_equalTo(-12);

        if (isLiving) {
            make.left.mas_equalTo(self.voiceButton.mas_right).offset(12);
        } else {
            make.left.mas_equalTo(self.cameraSwitchButton);
        }
    }];
}



- (void)updateVoiceButtonStatus:(BOOL)muted {
    NSString *normalImage = @"toolbar_btn_voice";
    NSString *highlightedImage = @"toolbar_btn_voice_tap";
    NSString *disabledImage = @"toolbar_btn_voice_tap";
    if (muted) {
        normalImage = @"toolbar_btn_voice_mute";
        highlightedImage = @"toolbar_btn_voice_mute_tap";
        disabledImage = @"toolbar_btn_voice_mute_tap";
    }
    
    [_voiceButton setBackgroundImage:kImageNamed(normalImage) forState:UIControlStateNormal];
    [_voiceButton setBackgroundImage:kImageNamed(highlightedImage) forState:UIControlStateHighlighted];
    [_voiceButton setBackgroundImage:kImageNamed(disabledImage) forState:UIControlStateDisabled];
}

#pragma mark - Public

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    [self updateVoiceButtonStatus:_muted];
}


@end
