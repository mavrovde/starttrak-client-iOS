//
//  STSelectableOptionsViewController.h
//  StartTrak
//
//  Created by mdv on 05/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STSelectableOptionsViewControllerDelegate;
@interface STSelectableOptionsViewController : UIViewController

@property (strong, nonatomic) NSArray *allOptions;
@property (strong, nonatomic) NSDictionary *selectedOption;
@property (weak, nonatomic) id<STSelectableOptionsViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *optionTitle;
@property (assign, nonatomic) BOOL cameFromProfile;

@end

@protocol STSelectableOptionsViewControllerDelegate <NSObject>

- (void)selectableOptionsViewController:(STSelectableOptionsViewController *)vc didSelectOption:(NSDictionary *)option;

@end