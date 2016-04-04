//
//  STButtonCell.m
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STButtonCell.h"
#import "STStyleUtility.h"

@implementation STButtonCell

- (void)awakeFromNib {
    // Initialization code
    self.doneButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.doneButton.titleLabel.textColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
