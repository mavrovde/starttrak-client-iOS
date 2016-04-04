//
//  STProfileRowCell.h
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STProfileItem.h"

@protocol STProfileRowCellDelegate;

@interface STProfileRowCell : UITableViewCell

@property (weak, nonatomic) id<STProfileRowCellDelegate> delegate;

//Weak reference to a tableView
@property (weak, nonatomic) UITableView *tableView;

//Model
@property (strong, nonatomic) STProfileItem *item;

//UI
@property (weak, nonatomic) IBOutlet UILabel *rowLabel;
@property (weak, nonatomic) IBOutlet UITextField *rowValue;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rowLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rowValueBottomConstraint;

@end

@protocol STProfileRowCellDelegate <NSObject>

//TBD

@end