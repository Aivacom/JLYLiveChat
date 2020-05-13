//
//  CanvasView.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/8/22.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThunderEngine.h"


@interface CanvasView : UIView

@property (nonatomic, readonly, assign) BOOL hasSetupVideoCanvasView;



- (void)setUid:(NSString *)uid;
- (void)hideUid:(BOOL)hidden;

// 执行一次
// Execute once
- (void)setupWithVideoCanvasView:(UIView *)view;

- (void)updateLiveStatus:(BOOL)isLiving;

- (void)setTxQuality:(ThunderLiveRtcNetworkQuality)txQuality;




@end
