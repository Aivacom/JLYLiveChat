//
//  CanvasView.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/8/22.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "CanvasView.h"
#import "Masonry.h"
#import "CommonMacros.h"


@interface CanvasView ()
@property (nonatomic, strong) UILabel *uidLabel;
@property (nonatomic, strong) UILabel *signalLabel;
@property (nonatomic, strong) ThunderVideoCanvas *canvas;
@property (nonatomic, strong) UIView *videoCanvasView;
@property (nonatomic, readwrite, assign) BOOL hasSetupVideoCanvasView;




@end

@implementation CanvasView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Private

- (void)setupSubviews {
    
    self.backgroundColor = kColorHex(@"#EDEFF5");
    self.clipsToBounds = YES;
    
    self.uidLabel = [[UILabel alloc] init];
    _uidLabel.textColor = [UIColor whiteColor];
    _uidLabel.font = [UIFont systemFontOfSize:14];
    
    [self addSubview:_uidLabel];
    [_uidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
    }];
    
    self.signalLabel = [[UILabel alloc] init];
    _signalLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _signalLabel.layer.cornerRadius = 10.0f;
    _signalLabel.clipsToBounds = YES;
    _signalLabel.textColor = [UIColor whiteColor];
    _signalLabel.font = [UIFont systemFontOfSize:10];
    _signalLabel.textAlignment = NSTextAlignmentCenter;
    _signalLabel.text = @"网络信号较弱";
    _signalLabel.hidden = YES;
    
    [self addSubview:_signalLabel];
    [_signalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(20);
    }];
}

#pragma mark - Public

- (void)setUid:(NSString *)uid {
    _uidLabel.text = uid;
}

- (void)hideUid:(BOOL)hidden {
    _uidLabel.hidden = hidden;
}

- (void)setupWithVideoCanvasView:(UIView *)view {
    self.videoCanvasView = view;
    [self insertSubview:_videoCanvasView belowSubview:_uidLabel];
    [_videoCanvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    self.hasSetupVideoCanvasView = YES;
}

- (void)updateLiveStatus:(BOOL)isLiving {
    _videoCanvasView.backgroundColor = isLiving?[UIColor blackColor]:kColorHex(@"#EDEFF5");
    self.backgroundColor = isLiving?[UIColor whiteColor]:kColorHex(@"#EDEFF5");
    if (!isLiving) {
        _uidLabel.text = @"";
    }
}




- (void)setTxQuality:(ThunderLiveRtcNetworkQuality)txQuality {
    _signalLabel.hidden = txQuality != THUNDER_SDK_NETWORK_QUALITY_VBAD;
}

@end
