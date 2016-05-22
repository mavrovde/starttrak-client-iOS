//
//  STProfile.m
//  StartTrak
//
//  Created by mdv on 05/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STProfile.h"
#import "STProfileItem.h"
#import "STDictionariesManager.h"
#import "STService.h"
#import "STSearchItem.h"

@implementation STProfile

- (NSArray *)editableFields
{
    return @[@{kFieldKey : @"first_name", kLabelKey : @"first name"},
             @{kFieldKey : @"last_name", kLabelKey : @"last name"},
             @{kFieldKey : @"city_name", kLabelKey : @"city"},
             @{kFieldKey : @"phone_number", kLabelKey : @"phone number"},
             @{kFieldKey : @"company_name", kLabelKey : @"company name"},
             ];
}

- (NSArray *)selectableFields
{
    return @[//@{kFieldKey : @"title_id", kLabelKey : @"title", kEntryKey : kEntryKeyTitles},
             @{kFieldKey : @"seniority_id", kLabelKey : @"seniority", kEntryKey : kEntryKeySeniorities},
             @{kFieldKey : @"industry_id", kLabelKey : @"industry", kEntryKey : kEntryKeyIndustries},
             @{kFieldKey : @"country_id", kLabelKey : @"country", kEntryKey : kEntryKeyCountries},
             @{kFieldKey : @"position_id", kLabelKey : @"position", kEntryKey : kEntryKeyPositions},
             @{kFieldKey : @"size_id", kLabelKey : @"company size", kEntryKey : kEntryKeyCompanySizes},
//             @{kFieldKey : @"state_id", kLabelKey : @"state"},
             ];
}

- (NSArray *)buildProfileItems
{
    NSMutableArray *profileItems = [NSMutableArray array];
    
    //Add avatar
    STProfileItem *avatarItem = [[STProfileItem alloc] init];
    avatarItem.itemType = STProfileItemTypeAvatar;
    avatarItem.rowHeight = 196.0;
    avatarItem.value = self.profile_pic;
    [profileItems addObject:avatarItem];
    
    //Editable Fields
    for (NSDictionary *fieldDescription in self.editableFields) {
        STProfileItem *item = [STProfileItem new];
        item.itemType = STProfileItemTypeRowEditable;
        
        item.label = fieldDescription[kLabelKey];
        
        NSString *field = fieldDescription[kFieldKey];
        NSString *fieldVal = [self valueForKey:field];
        
        item.fieldKey = field;
        item.value = fieldVal;
        
        [profileItems addObject:item];
    }
    
    //Selectable Fields
    for (NSDictionary *fieldDescription in self.selectableFields) {
        STProfileItem *item = [STProfileItem new];
        item.itemType = STProfileItemTypeRowSelectable;
        
        item.label = fieldDescription[kLabelKey];
        
        NSString *field = fieldDescription[kFieldKey];
        NSString *fieldVal = [self valueForKey:field];
        
        item.fieldKey = field;
        
        //dictionary id
        item.value = fieldVal;
        
        //Lookup dict
        NSString *entryKey = fieldDescription[kEntryKey];
        
        assert(nil != entryKey);
        
        NSDictionary *valueDict = [[STDictionariesManager sharedInstance] entryDictForKey:entryKey withID:item.value];
        
//        NSMutableDictionary *mutableValueDict = [valueDict mutableCopy];
//        mutableValueDict[kEntryKey] = entryKey;
        
        item.valueDict = valueDict;
        item.entryKey = entryKey;
        
        [profileItems addObject:item];
    }
    
    //Add button
    STProfileItem *buttonItem = [[STProfileItem alloc] init];
    buttonItem.itemType = STProfileItemTypeButton;
    buttonItem.rowHeight = 120.0;
    
    [profileItems addObject:buttonItem];
    
    return profileItems;
}

- (NSArray *)buildSearchItems
{
    NSMutableArray *profileItems = [NSMutableArray array];
    
    //Selectable Fields
    for (NSDictionary *fieldDescription in self.selectableFields) {
        STProfileItem *item = [STProfileItem new];
        item.itemType = STProfileItemTypeRowSelectable;
        
        item.label = fieldDescription[kLabelKey];
        
        NSString *field = fieldDescription[kFieldKey];
        item.fieldKey = field;
        
//        NSString *fieldVal = [self valueForKey:field];
        
        //dictionary id
//        item.value = fieldVal;
        
        //Lookup dict
        NSString *entryKey = fieldDescription[kEntryKey];
        
        assert(nil != entryKey);
        
//        NSDictionary *valueDict = [[STDictionariesManager sharedInstance] entryDictForKey:entryKey withID:item.value];
        
//        item.valueDict = valueDict;
        item.entryKey = entryKey;
        
        [profileItems addObject:item];
    }
    
    return profileItems;
}

- (NSDictionary *)profileToSendFromProfileItems:(NSArray *)profileItems
{
    if (!profileItems)
        return nil;
    
    NSMutableDictionary *profileDict = [NSMutableDictionary dictionaryWithCapacity:profileItems.count];
    
    for (STProfileItem *pi in profileItems) {
        if (STProfileItemTypeRowEditable == pi.itemType || STProfileItemTypeRowSelectable == pi.itemType) {
            if (pi.fieldKey && pi.fieldKey.length > 0 && pi.value) {
                if ((STProfileItemTypeRowSelectable == pi.itemType && pi.valueDict) ||
                    (STProfileItemTypeRowEditable == pi.itemType && pi.value)) {
                    profileDict[pi.fieldKey] = pi.value;
                }
            }
        }
    }
    
    return profileDict;
}

- (NSDictionary *)searchParamsFromSearchItems:(NSArray *)searchItems
{
    if (!searchItems)
        return nil;
    
    NSMutableDictionary *searchParams = [NSMutableDictionary dictionaryWithCapacity:searchItems.count];
    
    for (STSearchItem *si in searchItems) {
        if (STProfileItemTypeRowSelectable == si.itemType) {
            if (si.fieldKey && si.value) {
                searchParams[si.fieldKey] = si.value;
            }
        }
    }
    
    return searchParams.count > 0 ? searchParams : nil;
}

- (NSString *)titleName
{
    return [[STDictionariesManager sharedInstance] entryDictForKey:kEntryKeyCountries withID:self.title_id][kEntryKeyName] ?: @"";
}

- (NSString *)positionName
{
    return [[STDictionariesManager sharedInstance] entryDictForKey:kEntryKeyPositions withID:self.position_id][kEntryKeyName] ?: @"";
}

- (NSString *)seniorityName
{
    return [[STDictionariesManager sharedInstance] entryDictForKey:kEntryKeySeniorities withID:self.seniority_id][kEntryKeyName] ?: @"";
}

- (NSString *)industryName
{
    return [[STDictionariesManager sharedInstance] entryDictForKey:kEntryKeyIndustries withID:self.industry_id][kEntryKeyName] ?: @"";
}

- (NSString *)countryName
{
    return [[STDictionariesManager sharedInstance] entryDictForKey:kEntryKeyCountries withID:self.country_id][kEntryKeyName] ?: @"";
}

- (NSString *)stateName
{
    return [[STDictionariesManager sharedInstance] entryDictForKey:kEntryKeyStates withID:self.state_id][kEntryKeyName] ?: @"";
}

- (NSString *)buildName
{
    NSMutableString *nameLabel = [[NSMutableString alloc] init];
    
    NSString *firstName = self.first_name ?: @"";
    
    if (firstName.length > 0) {
        [nameLabel appendString:firstName];
    }
    
    NSString *lastName = self.last_name ?: @"";
    
    if (lastName.length > 0) {
        NSString *format = firstName.length > 0 ? @" %@" : @"%@";
        [nameLabel appendFormat:format, lastName];
    }
    
    return nameLabel.length > 0 ? nameLabel : @"No Name";
}

- (NSString *)buildPosition
{
    NSMutableString *positionLabel = [[NSMutableString alloc] init];
    
    NSString *positionName = [self positionName];
    
    if (positionName.length > 0) {
        [positionLabel appendString:positionName];
    }
    
    NSString *companyName = self.company_name ?: @"";
    
    if (companyName.length > 0) {
        NSString *format = positionName.length > 0 ? @" at %@" : @"%@";
        [positionLabel appendFormat:format, companyName];
    }
    
    return positionLabel.length > 0 ? positionLabel : @"at Unknown Company";
}

- (NSString *)buildLocation
{
    NSMutableString *locationLabel = [[NSMutableString alloc] init];
    
    NSString *cityName = self.city_name;
    
    if (cityName.length > 0) {
        [locationLabel appendString:cityName];
    }
    
    NSString *countryName = self.countryName;
    
    if (countryName.length > 0) {
        NSString *format = cityName.length > 0 ? @", %@" : @"%@";
        [locationLabel appendFormat:format, countryName];
    }
    
    NSString *from = [NSString stringWithFormat:@"From %@", locationLabel.length > 0 ? locationLabel : @"Undefined location"];
    
    return from;
}

- (NSString *)buildFromNetwork
{
    NSMutableString *fromNetwork = [[NSMutableString alloc] initWithString:@""];
    
    NSInteger socialNetworkTypeInteger = -1;
    
    @try {
        socialNetworkTypeInteger = self.soc_network_type ? [self.soc_network_type integerValue] : socialNetworkTypeInteger;
    }
    @catch (NSException *exception) {}
    
    NSString *networkFromType = [STService socialNetworkNameFromType:socialNetworkTypeInteger];
    
    [fromNetwork appendFormat:@"via %@", networkFromType];
    
    return fromNetwork;
}

- (void)loadFromDictionary:(NSDictionary *)dict
{
    if (nil != dict) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *theValue = nil;
            
            if ([obj isKindOfClass:[NSNumber class]]) {
                theValue = [obj stringValue];
            }
            else {
                theValue = obj;
            }
            @try {
                if (nil != theValue && ![theValue isKindOfClass:[NSNull class]])
                [self setValue:theValue forKey:key];
            }
            @catch (NSException *exception) {
                NSLog(@"exception=%@", exception);
            }
            
            
        }];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSLog(@"valueForUndefinedKey=%@", key);
    return nil;
}
@end
