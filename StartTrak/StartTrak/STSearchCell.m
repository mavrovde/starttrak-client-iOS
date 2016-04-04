//
//  STSearchCell.m
//  StartTrak
//
//  Created by mdv on 07/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSearchCell.h"
#import "STSearchItem.h"
#import "STDictionariesManager.h"
#import "STStyleUtility.h"

@interface STSearchCell ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *value;

@end

@implementation STSearchCell

- (void)awakeFromNib
{
    self.label.font = self.value.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:18.0];
    self.label.textColor = self.value.textColor = [STStyleUtility defaultAppTextColor];
}

- (void)setSearchItem:(STSearchItem *)searchItem
{
    _searchItem = searchItem;
    
    self.label.text = [searchItem.label uppercaseString];
    
    NSString *value = nil == searchItem.valueDict ? @"All" : searchItem.valueDict[kEntryKeyName];
    
    self.value.text = value;
}

@end
