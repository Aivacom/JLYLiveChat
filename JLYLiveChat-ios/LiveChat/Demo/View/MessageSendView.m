//
//  MessageSendView.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/12.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "MessageSendView.h"
#import "Masonry.h"
#import "UITextView+PlaceHolder.h"
#import "CommonMacros.h"
#import "UIView+Additions.h"



static const CGFloat kTextViewMaxHeight = 90;
static const CGFloat kTextViewMinHeight = 21;


@interface MessageSendView () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;


@end

@implementation MessageSendView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Private

- (void)setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    
    UIView *inputContainerView = [[UIView alloc] init];
    inputContainerView.layer.cornerRadius = 8;
    inputContainerView.layer.masksToBounds = YES;
    inputContainerView.layer.borderWidth = 0.5;
    inputContainerView.layer.borderColor = kColorHex(@"#E6E6E6").CGColor;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(tapOnInputContainerView)];
    [inputContainerView addGestureRecognizer:tapGestureRecognizer];
    
    [self addSubview:inputContainerView];
    [inputContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-8);
        make.top.mas_equalTo(8);
    }];

    self.textView = [[UITextView alloc] init];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.textColor = [UIColor darkTextColor];
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.enablesReturnKeyAutomatically = YES;
    _textView.placeholder = @"请输入消息";
    _textView.placeholderColor = kColorHex(@"#CCCCCC");
    _textView.delegate = self;
    _textView.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 10);
    
    [inputContainerView addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.bottom.mas_equalTo(-7);
        make.left.right.mas_equalTo(inputContainerView);
    }];
}

#pragma mark - Public

- (void)textViewBecomeFirstResponder {
    [_textView becomeFirstResponder];
}

- (void)clearContent {
    _textView.text = nil;
    [self textViewDidChange:_textView];
}



#pragma mark - Action


- (void)tapOnInputContainerView {
    [_textView becomeFirstResponder];
}



#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        if (_delegate && [_delegate respondsToSelector:@selector(messageSendView:shouldSendMessage:)]) {
            [_delegate messageSendView:self shouldSendMessage:textView.text];
        }
        return NO;
    }
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    
    CGSize size = [textView sizeThatFits:CGSizeMake(kScreenWidth - 10 - 10, 21)];
    CGFloat textViewHeight;
    textView.scrollEnabled = NO;

    if (size.height > kTextViewMinHeight && size.height < kTextViewMaxHeight) {
        textViewHeight = size.height;
    } else if (size.height <= kTextViewMinHeight) {
        textViewHeight = kTextViewMinHeight;
    } else {
        textViewHeight = kTextViewMaxHeight;
        textView.scrollEnabled = YES;
    }

    
    CGFloat height = textViewHeight + 8 + 8 + 8 + 7;
    CGFloat changedHeight = textViewHeight - textView.height;

    
    if (self.height != height) {
        [UIView animateWithDuration:0.6f animations:^{
            self.frame = CGRectMake(self.left, self.top - changedHeight, self.width, height);
        }];
    }
}


#pragma mark - Get

- (BOOL)isTextViewFirstResponder {
    return _textView.isFirstResponder;
}


@end
