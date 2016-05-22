//
//  STDictionariesManager.m
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STDictionariesManager.h"

@interface STDictionariesManager ()

@property (strong, nonatomic) NSMutableDictionary *dictionaries;

@end

@implementation STDictionariesManager

+ (instancetype)sharedInstance
{
    static STDictionariesManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STDictionariesManager alloc] init];
        instance.dictionaries = [NSMutableDictionary dictionary];
    });
    
    return instance;
}

- (void)loadDictionariesWithContent:(NSDictionary *)content
{
    [self processDictionariesFromResponse:content];
}

- (void)processDictionariesFromResponse:(NSDictionary *)dict
{
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *entries = obj;
        
        //convert array of dictionaries into dictionary of dictionaries for quick lookup
        NSMutableDictionary *entriesDict = [NSMutableDictionary dictionary];
        
        for (NSDictionary *entry in entries) {
            NSString *entryIDString = [entry[kEntryKeyId] stringValue];
            
            id sortKeyVal = nil;
            
            if (entry[@"minValue"]) {
                sortKeyVal = entry[@"minValue"];
//                NSLog(@"entry=%@", [entry description]);
            }
            else {
                sortKeyVal = @"";
            }
            
            NSDictionary *entryWithConvertedId = @{kEntryKeyId : entryIDString, kEntryKeyName : entry[kEntryKeyName], kEntryKeySortKey : sortKeyVal};
            entriesDict[entryIDString] = entryWithConvertedId;
        }
        
        self.dictionaries[key] = entriesDict;
        
    }];
}

- (NSDictionary *)entryValuesForKey:(NSString *)entryKey; //{ "id" : { id:"", name:"" }, ...
{
    return self.dictionaries[entryKey];
}

- (NSDictionary *)entryDictForKey:(NSString *)entryKey withID:(NSString *)entryValID; //{ id:"", name:"" }
{
    return [self entryValuesForKey:entryKey][entryValID];
}

- (NSArray *)entriesForKey:(NSString *)key
{
    NSDictionary *entries = self.dictionaries[key];
    
    NSMutableArray *entriesArray = [NSMutableArray array];
    
    [entries enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [entriesArray addObject:obj];
    }];
    
    NSArray *sortedArray = [entriesArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        id entrySortKey1 = obj1[kEntryKeySortKey];
        id entrySortKey2 = obj2[kEntryKeySortKey];
        
        id sortKey1 = [entrySortKey1 isKindOfClass:[NSNumber class]] ? entrySortKey1 : obj1[kEntryKeyName];
        id sortKey2 = [entrySortKey2 isKindOfClass:[NSNumber class]] ? entrySortKey2 : obj2[kEntryKeyName];
        
        return [sortKey1 compare:sortKey2];
    }];
    
    return sortedArray;
}

@end
