//
//  STProfileItemInterface.h
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, STProfileItemType) {
    STProfileItemTypeAvatar = 0,
    STProfileItemTypeRowEditable,
    STProfileItemTypeRowSelectable,
    STProfileItemTypeButton
};

@protocol STProfileItemInterface <NSObject>

@property (assign, nonatomic) STProfileItemType itemType;
@property (assign, nonatomic) CGFloat rowHeight;

@end
