//
//  MessageSendView.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/12.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageSendView;

@protocol MessageSendViewDelegate <NSObject>

@optional

- (void)messageSendView:(MessageSendView *)messageSendView shouldSendMessage:(NSString *)message;

@end

@interface MessageSendView : UIView

@property (nonatomic, weak) id <MessageSendViewDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL isTextViewFirstResponder;


- (void)textViewBecomeFirstResponder;
- (void)clearContent;


@end
