//
//  STSelectableOptionCell.h
//  StartTrak
//
//  Created by mdv on 05/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STSelectableOptionCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *option; //valueDict
@property (assign, nonatomic) BOOL isSelectedOption;

@end
