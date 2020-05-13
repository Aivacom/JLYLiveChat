//
//  JoinRoomViewController.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "JoinRoomViewController.h"
#import "UIViewController+BaseViewController.h"
#import "CommonMacros.h"
#import "JoinOperationView.h"
#import "Masonry.h"
#import "Utils.h"
#import "HummerManager.h"
#import "MBProgressHUD+HUD.h"
#import "LivingRoomViewController.h"
#import <AFNetworking.h>



@interface JoinRoomViewController () <JoinOperationViewDelegate>
@property (nonatomic, strong) JoinOperationView *joinOperationView;


@end

@implementation JoinRoomViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"UID：%@", [HummerManager sharedManager].uid];
    [self setupBaseSetting];
    
    [self setupSubviews];
}


#pragma mark - Private

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(onRightBarButtonClick)];
    self.navigationItem.rightBarButtonItem.tintColor = kColorHex(@"#6485F9");
    
    self.joinOperationView = [[JoinOperationView alloc] init];
    _joinOperationView.placeholder = @"请输入房间号";
    _joinOperationView.buttonTitle = @"加入房间";
    _joinOperationView.delegate = self;
    
    [self.view addSubview:_joinOperationView];
    [_joinOperationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(160);
    }];
    
    
    UIButton *createRoomButton = [[UIButton alloc] init];
    createRoomButton.layer.cornerRadius = 6;
    createRoomButton.layer.masksToBounds = YES;
    createRoomButton.layer.borderWidth = 1;
    createRoomButton.layer.borderColor = kColorHex(@"#6485F9").CGColor;
    [createRoomButton setTitleColor:kColorHex(@"#6485F9") forState:UIControlStateNormal];
    [createRoomButton setTitle:@"创建房间" forState:UIControlStateNormal];
    [createRoomButton addTarget:self action:@selector(onCreateRoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:createRoomButton];
    [createRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-(kBottomOffset + 80));
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(45);
    }];
    
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.textColor = kColorHex(@"#999999");
    versionLabel.font = [UIFont systemFontOfSize:13];
    versionLabel.text = [NSString stringWithFormat:@"当前版本：V%@", [Utils appVersion]];
    
    [self.view addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-(kBottomOffset + 20));
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(13);
    }];
    
}

#pragma mark - Public



#pragma mark - Action
- (void)onRightBarButtonClick {
    
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD showToast:@"无法连接网络，请稍后再试"];
        return;
    };
    
    [[HummerManager sharedManager] logoutWithCompletionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"退出登录失败"];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)onCreateRoomButtonClick {
    [MBProgressHUD showActivityIndicator];
    
    [[HummerManager sharedManager] createChatRoomWithCompletionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"创建房间失败"];
        } else {
            [MBProgressHUD hideActivityIndicator];
            LivingRoomViewController *livingRoomViewController = [[LivingRoomViewController alloc] initWithChatRoom:chatRoom];
            [self.navigationController pushViewController:livingRoomViewController animated:YES];
        }
    }];
}

#pragma mark - Request


#pragma mark - JoinOperationViewDelegate

- (void)operationView:(JoinOperationView *)operationView didTapOnJoinButtonWithTextFieldText:(NSString *)text {
    [_joinOperationView resignTextFieldFirstResponder];
    
    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (AFNetworkReachabilityStatusUnknown == netStatus || AFNetworkReachabilityStatusNotReachable == netStatus) {
        [MBProgressHUD showToast:@"网络无法连接"];
        return;
    }
    
    [MBProgressHUD showActivityIndicator];
    
    [[HummerManager sharedManager] joinChatRoomWithRoomId:text completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        if (error) {
            if (error.code == 2004) {
                [MBProgressHUD showToast:@"加入房间失败，请确认房间号"];
            } else {
                [MBProgressHUD showToast:@"加入房间失败"];
            }
        } else {
            [MBProgressHUD hideActivityIndicator];
            LivingRoomViewController *livingRoomViewController = [[LivingRoomViewController alloc] initWithChatRoom:chatRoom];
            [self.navigationController pushViewController:livingRoomViewController animated:YES];
        }
    }];
}

#pragma mark - Get and Set


@end
