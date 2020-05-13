//
//  MemberListViewController.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/16.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HMRChatRoom/HMRChatRoom.h>


@class LivingRoomViewController;

@interface MemberListViewController : UIViewController
@property (nonatomic, strong) LivingRoomViewController *livingRoomViewController;


- (instancetype)initWithChatRoom:(HMRChatRoom *)chatRoom;

@end
