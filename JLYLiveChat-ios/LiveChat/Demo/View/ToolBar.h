//
//  ToolBar.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolBar;

@protocol ToolBarDelegate <NSObject>

@optional


- (void)toolBarDidTapOnCameraSwitchButton:(ToolBar *)toolBar;
- (void)toolBarDidTapOnVoiceButton:(ToolBar *)toolBar;
- (void)toolBarDidTapOnChatButton:(ToolBar *)toolBar;
- (void)toolBarDidTapOnFeedbackButton:(ToolBar *)toolBar;

@end

    

@interface ToolBar : UIView
@property (nonatomic, weak) id <ToolBarDelegate> delegate;

@property (nonatomic, readonly, strong) UIButton *cameraSwitchButton;
@property (nonatomic, readonly, strong) UIButton *voiceButton;
@property (nonatomic, assign) BOOL muted;  // 是否已静音/Whether it is muted



- (void)updateToolButtonsStatusWithLiveStatus:(BOOL)isLiving;


@end
