//
//  JoinOperationView.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "JoinOperationView.h"
#import "Masonry.h"
#import "TextField.h"
#import "CommonMacros.h"
#import "UIImage+Additions.h"



@interface JoinOperationView () <UITextFieldDelegate>
@property (nonatomic, strong) TextField *textField;
@property (nonatomic, strong) UIButton *joinButton;

@end

@implementation JoinOperationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Private

- (void)setupSubviews {    
    self.textField = [[TextField alloc] init];
    _textField.layer.cornerRadius = 4;
    _textField.layer.masksToBounds = YES;
    _textField.layer.borderWidth = 1;
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.textColor = [UIColor blackColor];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.canPaste = NO;
    [_textField addTarget:self action:@selector(textFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
    
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
    
    [self addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(36);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(44);
    }];
    
    
    self.joinButton = [[UIButton alloc] init];
    _joinButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#6485F9")];
    UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#3A61ED")];
    UIImage *disabledImage = [UIImage imageWithColor:kColorHex(@"#DBDBDB")];
    _joinButton.layer.masksToBounds = YES;
    _joinButton.layer.cornerRadius = 6;
    
    [_joinButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_joinButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [_joinButton setBackgroundImage:disabledImage forState:UIControlStateDisabled];

    
    [_joinButton addTarget:self action:@selector(onJoinButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_joinButton];
    [_joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(45);
    }];
    
    [self updateJoinButtonStatus];
}

- (void)updateJoinButtonStatus {
    _joinButton.enabled = _textField.text.length > 0 && ![_textField.text hasPrefix:@"0"];
    
    if (_joinButton.enabled) {
        _textField.layer.borderColor = kColorHex(@"#6485F9 ").CGColor;
    } else {
        _textField.layer.borderColor = kColorHex(@"#E6E6E6").CGColor;
    }
}


#pragma mark - Action

- (void)onJoinButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationView:didTapOnJoinButtonWithTextFieldText:)]) {
        [_delegate operationView:self didTapOnJoinButtonWithTextFieldText:_textField.text ];
    }
}


#pragma mark - Public

- (void)textFieldBecomeFirstResponder {
    [_textField becomeFirstResponder];
}

- (void)resignTextFieldFirstResponder {
    [_textField resignFirstResponder];
}




#pragma mark - UIControlEventEditingChanged

- (void)textFieldDidChangedEditing:(UITextField *)textField {
    [self updateJoinButtonStatus];
}

#pragma mark - Get and Set

- (void)setMaxInputLength:(NSUInteger)maxInputLength {
    _textField.maxInputLength = maxInputLength;
}

- (NSUInteger)maxInputLength {
    return _textField.maxInputLength;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _textField.placeholder = placeholder;
}

- (NSString *)placeholder {
    return _textField.placeholder;
}

- (void)setTextFieldText:(NSString *)textFieldText {
    _textField.text = textFieldText;
    [self updateJoinButtonStatus];
}

- (NSString *)textFieldText {
    return _textField.text;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [_joinButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (NSString *)buttonTitle {
    return [_joinButton titleForState:UIControlStateNormal];
}



@end
