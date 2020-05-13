//
//  LoginViewController.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/9.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+BaseViewController.h"
#import "CommonMacros.h"
#import "JoinOperationView.h"
#import "Masonry.h"
#import "Utils.h"
#import "JoinRoomViewController.h"
#import "HummerManager.h"
#import "MBProgressHUD+HUD.h"




@interface LoginViewController () <JoinOperationViewDelegate>
@property (nonatomic, strong) JoinOperationView *joinOperationView;



@end

@implementation LoginViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBaseSetting];
    [self setupNavigationBarWithBarTintColor:[UIColor whiteColor] titleColor:kColorHex(@"#333333") titleFont:[UIFont boldSystemFontOfSize:17] eliminateSeparatorLine:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    if (@available(iOS 13.0, *)) {
        [self.navigationController setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }

    // Initialize Hummer SDK
    [[HummerManager sharedManager] setupHummerSDK];
    
    [self setupSubviews];
    
    [self autoLogin];
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}



#pragma mark - Private

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.joinOperationView = [[JoinOperationView alloc] init];
    _joinOperationView.maxInputLength = 6;
    _joinOperationView.placeholder = @"请输入UID";
    _joinOperationView.buttonTitle = @"登录";
    _joinOperationView.delegate = self;
    _joinOperationView.textFieldText = [HummerManager sharedManager].uid;
    
    if (_joinOperationView.textFieldText.length == 0) {
        [_joinOperationView textFieldBecomeFirstResponder];
    }
    
    [self.view addSubview:_joinOperationView];
    [_joinOperationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(160);
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


- (void)autoLogin {
    if ([HummerManager sharedManager].isLoggedIn) {
        self.joinOperationView.hidden = YES;
        [MBProgressHUD showActivityIndicator];
        [[HummerManager sharedManager] loginWithUid:[HummerManager sharedManager].uid completionHandler:^(NSError *error) {
            if (error) {
                [MBProgressHUD showToast:@"自动登录失败，请稍后自行登录"];
                [HummerManager sharedManager].isLoggedIn = NO;
            } else {
                [MBProgressHUD hideActivityIndicator];
                JoinRoomViewController *joinRoomViewController = [[JoinRoomViewController alloc] init];
                [self.navigationController pushViewController:joinRoomViewController animated:NO];
            }
            
            self.joinOperationView.hidden = NO;
        }];
    }
}



#pragma mark - JoinOperationViewDelegate

- (void)operationView:(JoinOperationView *)operationView didTapOnJoinButtonWithTextFieldText:(NSString *)text {
    [_joinOperationView resignTextFieldFirstResponder];
    
    [MBProgressHUD showActivityIndicator];
    [[HummerManager sharedManager] loginWithUid:text completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"登录失败"];
        } else {
            [MBProgressHUD showToast:@"登录成功"];
            JoinRoomViewController *joinRoomViewController = [[JoinRoomViewController alloc] init];
            [self.navigationController pushViewController:joinRoomViewController animated:YES];
        }
    }];
}


#pragma mark - Get and Set


@end
