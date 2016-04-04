//
//  STProfileItem.m
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STProfileItem.h"

@implementation STProfileItem

@synthesize itemType;
@synthesize rowHeight;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rowHeight = kDefaultRowHeight;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"label=%@, value=%@, valueDict=%@", self.label, self.value, [self.valueDict description]];
}
@end
