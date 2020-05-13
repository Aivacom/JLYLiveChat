//
//  LivingOperationView.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/9/24.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingOperationView.h"
#import "Masonry.h"
#import "CommonMacros.h"
#import "UIImage+Additions.h"
#import "PickerView.h"
#import "InputAccessoryView.h"
#import "UserPickerData.h"



@interface LivingOperationView () <InputAccessoryViewDelegate>
@property (nonatomic, strong) HMRChatRoom *chatRoom;
@property (nonatomic, readwrite, strong) UIButton *publishModeButton;
@property (nonatomic, strong) UIButton *liveButton;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UITextField *subscribeTextField;
@property (nonatomic, strong) PickerView *pickerView;
@property (nonatomic, strong) InputAccessoryView *inputAccessoryView;
@property (nonatomic, strong) id pickerSelectedResultValue;
@property (nonatomic, readwrite, assign) BOOL hasSubscribed;





@end

@implementation LivingOperationView

#pragma mark - Init

- (instancetype)initWithChatRoom:(HMRChatRoom *)chatRoom {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 108)];
    if (self) {
        _chatRoom = chatRoom;
        [self setupSubviews];
    }
    return self;
}




#pragma mark - Private

- (void)setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *roomIdLable = [[UILabel alloc] init];
    roomIdLable.font = [UIFont boldSystemFontOfSize:16];
    roomIdLable.textColor = [UIColor blackColor];
    roomIdLable.text = [NSString stringWithFormat:@"房间号：%llu", _chatRoom.ID];
    
    [self addSubview:roomIdLable];
    [roomIdLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.left.mas_equalTo(12);
        make.height.mas_equalTo(22);
    }];
    
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setImage:kImageNamed(@"nav_btn_close_w") forState:UIControlStateNormal];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [closeButton addTarget:self action:@selector(onCloseRoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(6);
        make.width.height.mas_equalTo(44);
    }];
    
    
    UIButton *memberButton = [[UIButton alloc] init];
    memberButton.layer.cornerRadius = 12;
    memberButton.layer.masksToBounds = YES;
    [memberButton setImage:kImageNamed(@"ic_user_online") forState:UIControlStateNormal];
    memberButton.imageEdgeInsets = UIEdgeInsetsMake(6, 7, 6, 35);
    memberButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [memberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [memberButton setTitle:@"成员" forState:UIControlStateNormal];
    
    UIImage *memberNormalImage = [UIImage imageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.1]];
    UIImage *memberHighlightedImage = [UIImage imageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    [memberButton setBackgroundImage:memberNormalImage forState:UIControlStateNormal];
    [memberButton setBackgroundImage:memberHighlightedImage forState:UIControlStateHighlighted];
    
    [memberButton addTarget:self action:@selector(onMemberButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:memberButton];
    [memberButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(closeButton.mas_left).offset(-6);
        make.centerY.mas_equalTo(closeButton);
        make.width.mas_equalTo(54);
        make.height.mas_equalTo(24);
    }];
    
    
    self.publishModeButton = [self selectButton];
    [_publishModeButton addTarget:self action:@selector(onPublishModeButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_publishModeButton];
    [_publishModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(roomIdLable.mas_bottom).offset(17);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(32);
    }];
    
    
    
    self.liveButton = [[UIButton alloc] init];
    _liveButton.layer.cornerRadius = 3;
    _liveButton.layer.masksToBounds = YES;
    _liveButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [_liveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *liveNormalImage = [UIImage imageWithColor:kColorHex(@"#6485F9")];
    UIImage *liveHighlightedImage = [UIImage imageWithColor:kColorHex(@"#3A61ED")];
    [_liveButton setBackgroundImage:liveNormalImage forState:UIControlStateNormal];
    [_liveButton setBackgroundImage:liveHighlightedImage forState:UIControlStateHighlighted];
    
    [_liveButton addTarget:self action:@selector(onLiveButtonClick) forControlEvents:UIControlEventTouchUpInside];

    
    [self addSubview:_liveButton];
    [_liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.publishModeButton.mas_right).offset(8);
        make.centerY.mas_equalTo(self.publishModeButton);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(32);
    }];
    
    
    
    if ([_chatRoom sy_roomOwnerIsMe]) {
        self.subscribeButton = [self selectButton];
        [_subscribeButton setTitle:@"订阅" forState:UIControlStateNormal];
        [_subscribeButton addTarget:self action:@selector(onsubscribeButtonClick) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_subscribeButton];
        [_subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.centerY.mas_equalTo(self.publishModeButton);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(32);
        }];
        
        self.subscribeTextField = [[UITextField alloc] init];
        [self addSubview:_subscribeTextField];
        _subscribeTextField.hidden = YES;
        
        
        self.pickerView = [PickerView pickerViewWithDataSource:nil];
        _subscribeTextField.inputView = _pickerView;
        
        self.inputAccessoryView = [[InputAccessoryView alloc] init];
        _inputAccessoryView.delegate = self;
        _subscribeTextField.inputAccessoryView = _inputAccessoryView;
        
    }
    
    [self updateLiveStatus:NO];
}


- (UIButton *)selectButton {
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:kColorHex(@"#7C98F9") forState:UIControlStateNormal];
    UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#E0E7FE")];
    UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#C4D1FB")];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];

    [button setImage:kImageNamed(@"ic_pull_arrow") forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(12, 56, 12, 12);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    return button;
}


#pragma mark - Public


- (void)setPublishModeTitle:(NSString *)title {
    [_publishModeButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateLiveStatus:(BOOL)isLiving {
    if (isLiving) {
        [_liveButton setTitle:@"关闭直播" forState:UIControlStateNormal];
    } else {
        [_liveButton setTitle:@"开始直播" forState:UIControlStateNormal];
    }
    
    if (![_chatRoom sy_roomOwnerIsMe]) {
        _publishModeButton.hidden = !isLiving;
        _liveButton.hidden = !isLiving;
    }
}

- (void)updatesubscribeStatus:(BOOL)subscribed {
    _hasSubscribed = subscribed;
    if (_hasSubscribed) {
        [_subscribeButton setTitle:@"取消订阅" forState:UIControlStateNormal];
        [_subscribeButton setImage:nil forState:UIControlStateNormal];
        _subscribeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _subscribeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        [_subscribeButton setTitle:@"订阅" forState:UIControlStateNormal];
        [_subscribeButton setImage:kImageNamed(@"ic_pull_arrow") forState:UIControlStateNormal];
        _subscribeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 56, 12, 12);
        _subscribeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    }
}



- (void)updatePickerDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource {
    [_pickerView updateDataSource:dataSource];
    if (_pickerSelectedResultValue) {
        [_pickerView setSelectedRowWithValue:_pickerSelectedResultValue];
    }
}

- (void)showPicker {
    [_subscribeTextField becomeFirstResponder];
}


#pragma mark - Action

- (void)onCloseRoomButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationViewDidTapOnCloseRoomButton:)]) {
        [_delegate operationViewDidTapOnCloseRoomButton:self];
    }
}


- (void)onMemberButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationViewDidTapOnMemberButton:)]) {
        [_delegate operationViewDidTapOnMemberButton:self];
    }
}

- (void)onPublishModeButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationViewDidTapOnPublishModeButton:)]) {
        [_delegate operationViewDidTapOnPublishModeButton:self];
    }
}

- (void)onLiveButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationViewDidTapOnLiveButton:)]) {
        [_delegate operationViewDidTapOnLiveButton:self];
    }
}

- (void)onsubscribeButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationViewDidTapOnsubscribeButton:)]) {
        [_delegate operationViewDidTapOnsubscribeButton:self];
    }
}


#pragma mark - SYInputAccessoryViewDelegate

- (void)inputAccessoryViewDidTapOnCancelButton:(InputAccessoryView *)inputAccessoryView {
    [_subscribeTextField resignFirstResponder];
    if (_pickerSelectedResultValue) {
        [_pickerView setSelectedRowWithValue:_pickerSelectedResultValue];
    }
}

- (void)inputAccessoryViewDidTapOnConfirmButton:(InputAccessoryView *)inputAccessoryView {
    [_subscribeTextField resignFirstResponder];
    
    HMRUser *user = (HMRUser *)_pickerView.selectedResultValue;
    if (user && _delegate && [_delegate respondsToSelector:@selector(operationView:didSelectedUser:)]) {
        self.pickerSelectedResultValue = user;
        
        [_delegate operationView:self didSelectedUser:user];
    }
}

#pragma mark - Get

- (BOOL)isPickerVisible {
    return _subscribeTextField.isFirstResponder;
}





@end
