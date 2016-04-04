//
//  STSelectableOptionCell.m
//  StartTrak
//
//  Created by mdv on 05/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSelectableOptionCell.h"
#import "STDictionariesManager.h"
#import "STStyleUtility.h"

@interface STSelectableOptionCell ()
@property (weak, nonatomic) IBOutlet UIImageView *dotImage;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;

@end

@implementation STSelectableOptionCell

- (void)awakeFromNib
{
    self.optionLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:18.0];
}

- (void)setIsSelectedOption:(BOOL)isSelectedOption
{
    _isSelectedOption = isSelectedOption;
    
    NSString *imageName = isSelectedOption ? @"dot-selected" : @"dot";
    self.dotImage.image = [UIImage imageNamed:imageName];
}

-(void)setOption:(NSDictionary *)option
{
    _option = option;
    
//    NSString *optionId = option[kEntryKeyId];
    
    self.optionLabel.text = option[kEntryKeyName];
}



@end
