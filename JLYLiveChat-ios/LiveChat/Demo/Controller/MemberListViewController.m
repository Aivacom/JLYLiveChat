//
//  MemberListViewController.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/16.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "MemberListViewController.h"
#import "UIViewController+BaseViewController.h"
#import "MemberListCell.h"
#import "CommonMacros.h"
#import "UIImage+Additions.h"
#import "Masonry.h"
#import "HummerManager.h"
#import "MBProgressHUD+HUD.h"
#import "HMRUser+Additions.h"
#import "FeedbackViewController.h"
#import "FeedbackManager.h"
#import "UIView+Additions.h"
#import "HMRChatRoom+Additions.h"
#import "User.h"
#import "ThunderManager.h"
#import "JoinRoomViewController.h"
#import "LivingRoomViewController+Hummer.h"




static NSString * const kMemberListCellReuseIdentifier = @"MemberListCell";


@interface MemberListViewController () <UITableViewDelegate, UITableViewDataSource, MemberListCellDelegate>
@property (nonatomic, strong) UITableView *membersTableView;
@property (nonatomic, strong) NSMutableArray<User *> *memberList;
@property (nonatomic, strong) HMRChatRoom *chatRoom;
@property (nonatomic, strong) UIView *pullView;




@end

@implementation MemberListViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"成员列表";
    [self setupCommonSetting];
    [self setBackBarButtonItemAction:@selector(onBackBarButtonClick:)];
    
    [self setupSubviews];
    
    [self requestData];
}


#pragma mark - Private

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor blackColor];
        
    self.membersTableView = [[UITableView alloc] init];
    _membersTableView.backgroundColor = [UIColor whiteColor];
    _membersTableView.delegate = self;
    _membersTableView.dataSource = self;
    _membersTableView.separatorColor = kColorHex(@"#E6E6E6");
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
    tableHeaderView.backgroundColor = kColorHex(@"#EDEFF4");
    _membersTableView.tableHeaderView = tableHeaderView;
    _membersTableView.tableFooterView = [[UIView alloc] init];
    [_membersTableView registerClass:[MemberListCell class] forCellReuseIdentifier:kMemberListCellReuseIdentifier];
    
    [self.view addSubview:_membersTableView];
    [_membersTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(kBottomOffset);
    }];
    
    self.pullView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 0)];
    _pullView.backgroundColor = kColorHex(@"#EDEFF4");
    
    [self.view addSubview:_pullView];
}

#pragma mark - Public

- (instancetype)initWithChatRoom:(HMRChatRoom *)chatRoom {
    self = [super init];
    if (self) {
        _chatRoom = chatRoom;
    }
    return self;
}




#pragma mark - Action
- (void)onBackBarButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}



#pragma mark - Request

- (void)requestData {
    [MBProgressHUD showActivityIndicator];
    
    [[HummerManager sharedManager] fetchMembersWithChatRoom:_chatRoom completionHandler:^(NSArray<HMRUser *> *members, NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"获取成员列表失败"];
        } else {
            [MBProgressHUD hideActivityIndicator];
            self.memberList = [members mutableCopy];
            [self.membersTableView reloadData];
        }
    }];
}


#pragma mark - MemberListCellDelegate

- (void)memberListCellDidTapOnMuteButton:(MemberListCell *)cell {
    if (cell.user.isMuted) {
        [MBProgressHUD showActivityIndicator];
        // 恢复禁言某个用户
        // Resume ban on a user
        [[HMRChatRoomService instance] unmuteMember:cell.user.hummerUser inChatRoom:_chatRoom reason:@"房主解除禁言" completionHandler:^(NSError *error) {
            if (error) {
                [MBProgressHUD showToast:@"恢复发言失败"];
            } else {
                [MBProgressHUD hideActivityIndicator];
                [cell updateUserMutedStatus:NO];
            }
        }];
    } else {
        [MBProgressHUD showActivityIndicator];
        // 禁言某个用户
        // Ban a user
        [[HMRChatRoomService instance] muteMember:cell.user.hummerUser inChatRoom:_chatRoom reason:@"房主禁言" completionHandler:^(NSError *error) {
            if (error) {
                [MBProgressHUD showToast:@"禁言失败"];
            } else {
                [MBProgressHUD hideActivityIndicator];
                [cell updateUserMutedStatus:YES];
            }
        }];
    }
    
}

- (void)memberListCellDidTapOnKickButton:(MemberListCell *)cell {
    [MBProgressHUD showActivityIndicator];
    [[HMRChatRoomService instance] kickMember:cell.user.hummerUser fromChatRoom:_chatRoom extraInfo:@{HMRKickReasonExtraKey:@"房主踢出"} completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"踢出房间失败"];
        } else {
            [MBProgressHUD hideActivityIndicator];

            NSUInteger index = [self.memberList indexOfObject:cell.user];
            [self.memberList removeObject:cell.user];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            if (@available(iOS 11.0, *)) {
                [self.membersTableView performBatchUpdates:^{
                    [self.membersTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                [self.membersTableView beginUpdates];
                [self.membersTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.membersTableView endUpdates];
            }
        }
    }];
}

- (void)memberListCellDidTapOnCloseRoomButton:(MemberListCell *)cell {
    if ([ThunderManager sharedManager].isLocalUserLiving) {
        [MBProgressHUD showToast:@"请关闭直播再销毁房间"];
        return;
    }
    
    [MBProgressHUD showActivityIndicator];
    // 关闭聊天室
    // Close chat room
    [[HMRChatRoomService instance] dismissChatRoom:_chatRoom completionHandler:^(NSError *error) {
        if (error) {
            [MBProgressHUD showToast:@"销毁房间失败"];
        } else {
            [MBProgressHUD hideActivityIndicator];
            
            
            // 房主的销毁房间直接在请求回调里处理
            // The owner's destruction of the room is handled directly in the request callback
            
            // 移除通知
            // Remove notification
            [self.livingRoomViewController hummer_removeDependentObserver];
            
            // 退出房间，退出房间后订阅和直播都失效了
            // After exiting the room, the subscription and live broadcast are invalid after exiting the room
            [self.livingRoomViewController.thunderManager leaveRoom];
            
            [self.livingRoomViewController hummer_popToJoinRoomViewController];
        }
    }];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _memberList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = _memberList[indexPath.row];
    
    MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberListCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setupDataWithUser:user isRoomOwner:[_chatRoom sy_roomOwnerIsMe]];
    return cell;
}




#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < -kNavBarHeight){
        _pullView.height  = 0 - scrollView.contentOffset.y - kNavBarHeight;
    }else{
        _pullView.height  = 0;
    }
}


@end
