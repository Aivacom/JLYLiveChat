//
//  MessageCell.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/11.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "MessageCell.h"
#import "Masonry.h"
#import "CommonMacros.h"
#import "CopyActionLabel.h"


@interface MessageCell ()
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) CopyActionLabel *messageLabel;




@end

@implementation MessageCell

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
    self.backgroundColor = [UIColor clearColor];
        
    self.messageLabel = [[CopyActionLabel alloc] init];
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.contentView addSubview:_messageLabel];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(kScreenWidth * (2/3.0f));
    }];
}


#pragma mark - Public
- (void)setupDataWithChatMessage:(id <ChatMessageProtocol>)message {
    _messageLabel.attributedText = message.outputMessage;

}


#pragma mark - Get





@end
