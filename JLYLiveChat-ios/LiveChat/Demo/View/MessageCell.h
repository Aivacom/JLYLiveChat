//
//  MessageCell.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/11.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageProtocol.h"

@interface MessageCell : UITableViewCell


- (void)setupDataWithChatMessage:(id <ChatMessageProtocol>)message;


@end
