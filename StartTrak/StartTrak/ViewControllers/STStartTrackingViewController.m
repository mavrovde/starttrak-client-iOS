//
//  STStartTrackingViewController.m
//  StartTrak
//
//  Created by Denis on 22/05/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STStartTrackingViewController.h"

@implementation STStartTrackingViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super  viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

@end
