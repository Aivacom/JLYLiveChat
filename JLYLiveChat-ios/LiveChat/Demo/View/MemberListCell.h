//
//  MemberListCell.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/16.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class MemberListCell;

@protocol MemberListCellDelegate <NSObject>

@optional

- (void)memberListCellDidTapOnMuteButton:(MemberListCell *)cell;
- (void)memberListCellDidTapOnKickButton:(MemberListCell *)cell;
- (void)memberListCellDidTapOnCloseRoomButton:(MemberListCell *)cell;


@end



@interface MemberListCell : UITableViewCell
@property (nonatomic, weak) id <MemberListCellDelegate> delegate;
@property (nonatomic, readonly, strong) User *user;




- (void)setupDataWithUser:(User *)user isRoomOwner:(BOOL)isRoomOwner;

- (void)updateUserMutedStatus:(BOOL)isMuted;


@end
