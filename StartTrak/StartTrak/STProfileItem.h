//
//  STProfileItem.h
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STProfileItemInterface.h"

#define kDefaultRowHeight 78.0

@interface STProfileItem : NSObject<STProfileItemInterface>

@property (copy, nonatomic) NSString *label;
@property (copy, nonatomic) NSString *value; //either string or entry id

//Selectable Fields Support

@property (strong, nonatomic) NSDictionary *valueDict; // {id: "", name: ""}
@property (copy, nonatomic) NSString *entryKey;
@property (copy, nonatomic) NSString *fieldKey;

@end
