//
//  STCreateProfileViewController.h
//  StartTrak
//
//  Created by mdv on 29/01/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STProfile;
@interface STCreateProfileViewController : UIViewController

@property (assign, nonatomic) BOOL isCreateProfile;
@property (strong, nonatomic) STProfile *profile;

@end
