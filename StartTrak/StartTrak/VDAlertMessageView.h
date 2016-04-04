//
//  VDAlertMessageView.m
//  VD7
//
//  Copyright © 2016 VD7 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDAlertMessageView : NSObject

+ (void)showMessageWithTitle:(NSString *)title
                        body:(NSString *)body
               cancelHandler:(void(^)())cancelHandler
                   doneTitle:(NSString *)doneTitle
                 doneHandler:(void(^)())doneHandler;

@end
