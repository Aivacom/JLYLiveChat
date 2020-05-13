//
//  DataEnvironment.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/9.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>

extern UInt64 const UInt64AppId;   // 信令和Thunder共用AppId/Signaling and Thunder share AppId

@interface DataEnvironment : NSObject

+ (instancetype)sharedDataEnvironment;


// 获取信令和Thunder共用Token
// Get signaling and Thunder shared token
- (NSString *)getTokenWithUid:(UInt64)uid;
- (NSString *)getTokenWithStingUid:(NSString *)uid;



// 字符串AppId
// String AppId
- (NSString *)stringAppId;

@end
