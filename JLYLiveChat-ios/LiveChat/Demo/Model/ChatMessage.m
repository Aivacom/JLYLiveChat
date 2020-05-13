//
//  ChatMessage.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "ChatMessage.h"
#import "HMRTextContent.h"
#import "HMRUser.h"
#import "CommonMacros.h"


static NSString * const kFlowerFormat = @"[/flower]";


@interface ChatMessage ()
@property (nonatomic, readwrite, strong) HMRMessage *message;
@property (nonatomic, readwrite, assign) CGFloat cellHeight;
@end

@implementation ChatMessage


+ (instancetype)chatMessageWithMessage:(HMRMessage *)message {
    return [[self alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(HMRMessage *)message {
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}

#pragma mark - Get

- (CGFloat)cellHeight {
    if (_cellHeight > 0) {
        return _cellHeight;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.attributedText = self.outputMessage;
    label.numberOfLines = 0;
    
    CGSize messageLabelSize = [label sizeThatFits:CGSizeMake(kScreenWidth * (2/3.0f), kScreenHeight)];
    
    _cellHeight = messageLabelSize.height + 12;
    
    return _cellHeight;
}





#pragma mark - Get


- (NSAttributedString *)outputMessage {
    
    NSString *userName = [NSString stringWithFormat:@"%llu:", self.message.sender.ID];
    HMRTextContent *content = (HMRTextContent *)self.message.content;
    NSString *contentText = content.text;
    
    NSString *message = [NSString stringWithFormat:@"%@  %@", userName, contentText];
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange userNameRange = [message rangeOfString:userName];
    UIColor *userNameColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [attributedString setAttributes:@{NSForegroundColorAttributeName:userNameColor} range:userNameRange];
    
    NSRange contentRange = [message rangeOfString:contentText];
    UIColor *contentColor = [UIColor blackColor];
    [attributedString setAttributes:@{NSForegroundColorAttributeName:contentColor} range:contentRange];
    
    return attributedString;
}



@end
