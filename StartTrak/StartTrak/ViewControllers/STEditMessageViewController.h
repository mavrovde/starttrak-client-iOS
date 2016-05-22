//
//  STEditMessageViewController.h
//  StartTrak
//
//  Created by Denis on 10/04/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STEditMessageViewControllerDelegate;
@interface STEditMessageViewController : UIViewController
@property (weak, nonatomic) id<STEditMessageViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *templateText;
@end


@protocol STEditMessageViewControllerDelegate <NSObject>

- (void)editMessageViewController:(STEditMessageViewController *)vc didFinishWithMessage:(NSString *)message;

@end