//
//  JoinOperationView.h
//  JLYChatRoom
//
//  Created by iPhuan on 2019/9/10.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JoinOperationView;

@protocol JoinOperationViewDelegate <NSObject>

@optional

- (void)operationView:(JoinOperationView *)operationView didTapOnJoinButtonWithTextFieldText:(NSString *)text;

@end

@interface JoinOperationView : UIView
@property (nonatomic, weak) id <JoinOperationViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger maxInputLength;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *textFieldText;
@property (nonatomic, copy) NSString *buttonTitle;

- (void)textFieldBecomeFirstResponder;
- (void)resignTextFieldFirstResponder;


@end
