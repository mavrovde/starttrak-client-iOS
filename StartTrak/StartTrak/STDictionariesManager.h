//
//  STDictionariesManager.h
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//Profile Item Keys
#define kFieldKey @"field"
#define kLabelKey @"label"
#define kEntryKey @"entry"

//Dictionary keys
#define kEntryKeyPositions @"positions"
#define kEntryKeyIndustries @"industries"
#define kEntryKeyCountries @"countries"
#define kEntryKeySeniorities @"seniority"
#define kEntryKeyCompanySizes @"sizes"
#define kEntryKeyTitles @"titles"
#define kEntryKeyStates @"states"

#define kEntryKeyId @"id"
#define kEntryKeyName @"label"
#define kEntryKeySortKey @"sort_key"

//{ kEntryKey : { "id" : { id:"", name:"" } }, ...

@interface STDictionariesManager : NSObject

+ (instancetype)sharedInstance;

- (void)loadDictionariesWithContent:(NSDictionary *)content;

- (NSDictionary *)entryValuesForKey:(NSString *)entryKey; //{ "id" : { id:"", name:"" }, ...
- (NSDictionary *)entryDictForKey:(NSString *)entryKey withID:(NSString *)entryValID; //{ id:"", name:"" }
- (NSArray *)entriesForKey:(NSString *)key;

@end
