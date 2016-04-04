//
//  VDAlertMessageView.m
//  VD7
//
//  Copyright © 2016 VD7 Inc. All rights reserved.
//

#import "VDAlertMessageView.h"
#import <UIKit/UIKit.h>

@interface VDAlertMessageView ()

@property (strong, nonatomic) UIAlertController *alertController;

@end

@implementation VDAlertMessageView

+ (void)showMessageWithTitle:(NSString *)title
                        body:(NSString *)body
               cancelHandler:(void(^)())cancelHandler
                   doneTitle:(NSString *)doneTitle
                 doneHandler:(void(^)())doneHandler
{
    UIViewController *topViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    if (!topViewController.presentedViewController) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelHandler) {
                cancelHandler();
            }
        }];
        
        [alertController addAction:cancelAction];
        
        if (doneTitle && doneTitle.length > 0) {
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:doneTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (doneHandler) {
                    doneHandler();
                }
            }];
            
            [alertController addAction:doneAction];
        }

        
        
        [topViewController presentViewController:alertController animated:YES completion:nil];
    }
}

@end
