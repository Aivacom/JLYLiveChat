//
//  ChatMessageProtocol.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol ChatMessageProtocol <NSObject>

@property (nonatomic, readonly, copy) NSAttributedString *outputMessage;  // 最终在聊天室展示的消息内容/The content of the message finally displayed in the chat room
@property (nonatomic, readonly, assign) CGFloat cellHeight;     // 计算好的cell高度/Calculated cell height


@end

