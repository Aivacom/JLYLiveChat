//
//  MemberListCell.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/16.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "MemberListCell.h"
#import "Masonry.h"
#import "UIImage+Additions.h"
#import "CommonMacros.h"
#import "User.h"


@interface MemberListCell ()
@property (nonatomic, readwrite, strong) User *user;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;




@end

@implementation MemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}


#pragma mark - Private

- (void)setupSubviews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.userIdLabel = [[UILabel alloc] init];
    _userIdLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    _userIdLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_userIdLabel];
    [_userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    
    self.rightButton = [self actionButton];
    [_rightButton addTarget:self action:@selector(onRightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_rightButton];
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-13);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(26);
    }];
    
    
    self.leftButton = [self actionButton];
    [_leftButton addTarget:self action:@selector(onLeftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_leftButton];
    [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightButton.mas_left).offset(-6);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(26);
    }];

    
}


- (UIButton *)actionButton {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.layer.cornerRadius = 13;
    button.layer.masksToBounds = YES;
    [button setTitleColor:kColorHex(@"#7C98F9") forState:UIControlStateNormal];
    UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#E0E7FE")];
    UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#C4D1FB")];
    
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    return button;
}



#pragma mark - Public
- (void)setupDataWithUser:(User *)user isRoomOwner:(BOOL)isRoomOwner {
    self.user = user;
    
    NSString *role = @"观众";
    if (_user.isRoomOwner) {
        role = @"房主";
    }
    
    if (isRoomOwner) {
        if (_user.isMe) {
            _userIdLabel.text = [NSString stringWithFormat:@"%@: %llu (我)", role, _user.hummerUser.ID];
            
            _leftButton.hidden = YES;
            _rightButton.hidden = NO;
            [_rightButton setTitle:@"销毁房间" forState:UIControlStateNormal];
        } else {
            _userIdLabel.text = [NSString stringWithFormat:@"%@: %llu", role, _user.hummerUser.ID];
            
            _leftButton.hidden = NO;
            _rightButton.hidden = NO;
            [_rightButton setTitle:@"踢出" forState:UIControlStateNormal];
        }
        
        [self updateMutedButtonStatus];
    } else {
        if (_user.isMe) {
            _userIdLabel.text = [NSString stringWithFormat:@"%@: %llu（我）", role, _user.hummerUser.ID];
        } else {
            _userIdLabel.text = [NSString stringWithFormat:@"%@: %llu", role, _user.hummerUser.ID];
        }
        
        _leftButton.hidden = YES;
        _rightButton.hidden = YES;
        
    }
    
    

}

- (void)updateUserMutedStatus:(BOOL)isMuted {
    _user.isMuted = isMuted;
    [self updateMutedButtonStatus];
}


- (void)updateMutedButtonStatus {
    if (_user.isMuted) {
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#6485F9")];
        UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#3A61ED")];
        [_leftButton setTitle:@"恢复发言" forState:UIControlStateNormal];
        
        [_leftButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_leftButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    } else {
        [_leftButton setTitleColor:kColorHex(@"#7C98F9") forState:UIControlStateNormal];
        UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#E0E7FE")];
        UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#C4D1FB")];
        [_leftButton setTitle:@"禁言" forState:UIControlStateNormal];
        
        [_leftButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_leftButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
}


#pragma mark - Action

- (void)onLeftButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(memberListCellDidTapOnMuteButton:)]) {
        [_delegate memberListCellDidTapOnMuteButton:self];
    }
}

- (void)onRightButtonClick {
    if (_user.isMe) {
        if (_delegate && [_delegate respondsToSelector:@selector(memberListCellDidTapOnCloseRoomButton:)]) {
            [_delegate memberListCellDidTapOnCloseRoomButton:self];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(memberListCellDidTapOnKickButton:)]) {
            [_delegate memberListCellDidTapOnKickButton:self];
        }
    }
    
}



@end
