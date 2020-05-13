//
//  LivingOperationView.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/9/24.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMRChatRoom+Additions.h"
#import "PickerDataProtocal.h"


@class LivingOperationView;

@protocol LivingOperationViewDelegate <NSObject>

@optional

- (void)operationViewDidTapOnPublishModeButton:(LivingOperationView *)operationView;
- (void)operationViewDidTapOnLiveButton:(LivingOperationView *)operationView;
- (void)operationViewDidTapOnMemberButton:(LivingOperationView *)operationView;
- (void)operationViewDidTapOnCloseRoomButton:(LivingOperationView *)operationView;
- (void)operationViewDidTapOnsubscribeButton:(LivingOperationView *)operationView;

- (void)operationView:(LivingOperationView *)operationView didSelectedUser:(HMRUser *)user;




@end

@interface LivingOperationView : UIView

- (instancetype)initWithChatRoom:(HMRChatRoom *)chatRoom;
@property (nonatomic, weak) id <LivingOperationViewDelegate> delegate;
@property (nonatomic, readonly, strong) UIButton *publishModeButton;
@property (nonatomic, readonly, assign) BOOL hasSubscribed;       // 是否已订阅某个观众/Whether you have subscribed to an audience
@property (nonatomic, readonly, assign) BOOL isPickerVisible;     // picker是否弹出/whether the picker pops up




- (void)setPublishModeTitle:(NSString *)title;
- (void)updateLiveStatus:(BOOL)isLiving;
- (void)updatesubscribeStatus:(BOOL)subscribed;


- (void)updatePickerDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource;
- (void)showPicker;



@end
