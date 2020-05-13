//
//  DataEnvironment.m
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/9.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "DataEnvironment.h"
#import "TokenHelper.h"


UInt64 const UInt64AppId = 1470236061;      


@interface DataEnvironment ()

@property (nonatomic, strong) NSMutableDictionary *tokenData;


@end

@implementation DataEnvironment

+ (instancetype)sharedDataEnvironment {
    static DataEnvironment *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}




#pragma mark - Public


- (NSString *)getTokenWithUid:(UInt64)uid {
    NSString *stringUid = [NSString stringWithFormat:@"%llu", uid];
    return [self getTokenWithStingUid:stringUid];
}

- (NSString *)getTokenWithStingUid:(NSString *)uid {
    NSString *token = self.tokenData[uid];
    if (token.length) {
        return token;
    }
    
    __block NSString *result = @"";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    TokenRequestParams *params = [TokenRequestParams defaultParams];
    params.appId = self.stringAppId;
    params.uid = uid;
    params.validTime = 24*60*60;
    [TokenHelper requestTokenWithParams:params completionHandler:^(BOOL success, NSString *token) {
        if (success) {
            result = token;
            self.tokenData[uid] = result;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}



#pragma mark - Get

- (NSString *)stringAppId {
    return [NSString stringWithFormat:@"%llu", UInt64AppId];
}

- (NSMutableDictionary *)tokenData {
    if (_tokenData == nil) {
        _tokenData = [[NSMutableDictionary alloc] init];
    }
    return _tokenData;
}



@end
