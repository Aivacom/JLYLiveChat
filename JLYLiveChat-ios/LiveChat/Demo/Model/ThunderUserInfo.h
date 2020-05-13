//
//  ThunderUserInfo.h
//  JLYLiveChat
//
//  Created by iPhuan on 2019/10/9.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ThunderUserInfo : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *roomId;


- (instancetype)initWithUid:(NSString *)uid roomId:(NSString *)roomId;


@end
