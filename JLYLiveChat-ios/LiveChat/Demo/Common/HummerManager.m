//
//  HummerManager.m
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/11.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "HummerManager.h"
#import "CommonMacros.h"
#import "Utils.h"
#import "HMRUser+Additions.h"
#import "HMRChatRoom+Additions.h"
#import "DataEnvironment.h"
#import "HMRSignalContent.h"




static NSString * const kUserDefaultsKeyUid = @"kUserDefaultsKeyUid";
static NSString * const kUserDefaultsKeyIsLoggedIn = @"kUserDefaultsKeyIsLoggedIn";


NSString * const SignalContentApply = @"live_connect_apply";
NSString * const SignalContentAccept = @"live_connect_accept";
NSString * const SignalContentRefuse = @"live_connect_refuse";
NSString * const SignalContentCancel = @"live_connect_cancel";



@interface HummerManager ()
@property (nonatomic, strong) NSMutableDictionary *tokenData;
@property (nonatomic, readwrite, copy) NSString *uid;


@end

@implementation HummerManager

+ (instancetype)sharedManager {
    static HummerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.tokenData = [[NSMutableDictionary alloc] init];
    self.uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyUid];
    self.isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyIsLoggedIn];
}

#pragma mark - Setup

- (void)setupHummerSDK {
    
    // 1. 创建 Hummer 通道
    // 1. Create a Hummer channel
    HMRServiceChannel *channel = [[HMRServiceChannel alloc] initWithMode:[HMRServiceChannelAutonomousMode modeWithTokenType:HMRTokenTypeThird]];
    // 2. 注册 Hummer 通道
    // 2. Register for the Hummer channel
    [Hummer registerChannel:channel completionHandler:^(NSError *error) {
        
    }];
    // 3. 初始化 Hummer SDK
    // 3. Initialize the Hummer SDK
    [Hummer startSDKWithAppId:UInt64AppId];
    
    
#ifdef DEBUG
    // 业务可以通过一下方法来设置 SDK 日志输出，即将日志托管给业务
    // The business can set the SDK log output by the following method, that is, to log the log to the business
//    [Hummer setLogger:^(HMRLoggerLevel level, NSString * _Nonnull log) {
//        switch (level) {
//                case HMRLoggerLevelError:
//                    kLog(@"[HummerSDK] %@", log);
//                    break;
//                case HMRLoggerLevelWarning:
//                    kLog(@"[HummerSDK] %@", log);
//                    break;
//                case HMRLoggerLevelInfo:
//                    kLog(@"[HummerSDK] %@", log);
//                    break;
//                case HMRLoggerLevelDebug:
//                    kLog(@"[HummerSDK] %@", log);
//                    break;
//                case HMRLoggerLevelVerbose:
//                    kLog(@"[HummerSDK] %@", log);
//                    break;
//        }
//    }];
#endif

}



#pragma mark - Login

- (void)loginWithUid:(NSString *)uid completionHandler:(HMRCompletionHandler)completionHandler {
    // 登录
    // login
    NSString *token = [[DataEnvironment sharedDataEnvironment] getTokenWithUid:uid.longLongValue];
    [Hummer openWithUid:uid.longLongValue environment:@"china/private/share" msgFetchStrategy:HMRContinuously tags:nil token:token completionHandler:^(NSError *error) {
        NSError *err = error;
        // 未退出继续登录的情况
        // Continue to log in without logging out
        if (error.code == 1008) {
            err = nil;
        }

        if (!err) {
            self.uid = uid;
            self.isLoggedIn = YES;
        }
        
        if (completionHandler) {
            completionHandler(err);
        }
    }
     ];
    
}


- (void)logoutWithCompletionHandler:(HMRCompletionHandler)completionHandler {
    // 退出登录
    // sign out
    [Hummer closeWithCompletionHandler:^(NSError *error) {
        if (!error) {
            self.isLoggedIn = NO;
        }
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}


#pragma mark - Chat

- (void)createChatRoomWithCompletionHandler:(HMRChatRoomCompletionHandler)completionHandler {
    NSString *roomName = [NSString stringWithFormat:@"%@", [Utils generateRandomNumberWithDigitCount:6]];
    // 创建聊天室信息
    // Create chat room information
    HMRChatRoomInfo *chatRoomInfo = [HMRChatRoomInfo chatRoomInfoWithName:roomName description:roomName bulletin:nil appExtra:nil];
    // 创建聊天室
    // Create chat room
    [[HMRChatRoomService instance] createChatRoom:chatRoomInfo completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(chatRoom, error);
            }
        } else {
            [[HMRChatRoomService instance] joinChatRoom:chatRoom extraProps:nil completionHandler:^(NSError *error) {
                if (completionHandler) {
                    completionHandler(chatRoom, error);
                }
            }];
        }

    }];
}

- (void)joinChatRoomWithRoomId:(NSString *)roomId completionHandler:(HMRChatRoomCompletionHandler)completionHandler {
    HMRChatRoom *chatRoom = [HMRChatRoom chatRoomWithID:roomId.longLongValue];
    [[HMRChatRoomService instance] joinChatRoom:chatRoom extraProps:nil completionHandler:^(NSError *error) {
        if (completionHandler) {
            completionHandler(chatRoom, error);
        }
    }];
}


#pragma mark - Members

// 获取观众列表
// Get audience list
- (void)fetchAudienceMembersWithChatRoom:(HMRChatRoom *)chatRoom completionHandler:(FetchAudienceMembersCompletionHandler)completionHandler {

    // 获取聊天室成员列表
    // Get a list of chat room members
    [[HMRChatRoomService instance] fetchMembers:chatRoom offset:0 num:100 completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        
        if (error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        } else {
            NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
            [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
                if (chatRoom.sy_roomOwner.ID != obj.ID) {
                    UserPickerData *pickerData = [[UserPickerData alloc] initWithValue:obj];
                    [targetMembers addObject:pickerData];
                }
            }];
            
            if (completionHandler) {
                completionHandler([targetMembers copy], error);
            }
        }

    }];
}

- (void)fetchMembersWithChatRoom:(HMRChatRoom *)chatRoom completionHandler:(FetchMembersCompletionHandler)completionHandler {
    
    // 获取聊天室成员列表
    // Get a list of chat room members
    [[HMRChatRoomService instance] fetchMembers:chatRoom offset:0 num:100 completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        
        if (error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        } else {
            [self fetchMutedUsersWithChatRoom:chatRoom members:members completionHandler:completionHandler];
        }

    }];
    
}

- (void)fetchMutedUsersWithChatRoom:(HMRChatRoom *)chatRoom members:(NSSet<HMRUser *> *)members completionHandler:(FetchMembersCompletionHandler)completionHandler {
    
    // 获取聊天室内的禁言列表
    // Get a list of bans in the chat room
    [[HMRChatRoomService instance] fetchMutedUsers:chatRoom completionHandler:^(NSSet<HMRUser *> *mutedMembers, NSError * _Nullable mutedError) {
        if (mutedError) {
            if (completionHandler) {
                completionHandler(nil, mutedError);
            }
        } else {
            NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
            
            [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
                User *targetUser = [[User alloc] initWithHummerUser:user];
                [mutedMembers enumerateObjectsUsingBlock:^(HMRUser *mutedUser, BOOL *mutedStop) {
                    if (user.ID == mutedUser.ID) {
                        targetUser.isMuted = YES;
                        *mutedStop = YES;
                    }
                }];
                
                if (chatRoom.sy_roomOwner.ID == user.ID) {
                    targetUser.isRoomOwner = YES;
                }
                
                if (targetUser.isRoomOwner) {
                    [targetMembers insertObject:targetUser atIndex:0];
                } else {
                    [targetMembers addObject:targetUser];
                }
            }];
            
            if (completionHandler) {
                completionHandler([targetMembers copy], mutedError);
            }
        }
        
    }];
}


#pragma mark - SendMessage


- (void)sendSignalMessage:(NSString *)message receiver:(HMRUser *)receiver chatRoom:(HMRChatRoom *)chatRoom completionHandler:(HMRCompletionHandler)completionHandler {
    HMRSignalContent *content = [HMRSignalContent unicstWithUser:receiver content:message];
    HMRMessage *aMessage = [HMRMessage messageWithContent:content receiver:chatRoom];
    [[HMRChatService instance] sendMessage:aMessage completionHandler:completionHandler];
}



#pragma mark - Get or Set

- (void)setUid:(NSString *)uid {
    _uid = uid;
    
    [[NSUserDefaults standardUserDefaults] setObject:_uid forKey:kUserDefaultsKeyUid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (void)setIsLoggedIn:(BOOL)isLoggedIn {
    _isLoggedIn = isLoggedIn;
    
    [[NSUserDefaults standardUserDefaults] setBool:_isLoggedIn forKey:kUserDefaultsKeyIsLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
}





@end
