//
//  STProfile.h
//  StartTrak
//
//  Created by mdv on 05/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STProfile : NSObject

@property (copy, nonatomic) NSString *email;

///Link to profile picture retrieved from social network
@property (copy, nonatomic) NSString *profile_pic;

@property (copy, nonatomic) NSString *first_name;
@property (copy, nonatomic) NSString *last_name;
@property (copy, nonatomic) NSString *phone_number;
@property (copy, nonatomic) NSString *company_name;
@property (copy, nonatomic) NSString *title_id;
@property (copy, nonatomic) NSString *position_id;
@property (copy, nonatomic) NSString *seniority_id;
@property (copy, nonatomic) NSString *industry_id;
@property (copy, nonatomic) NSString *country_id;
@property (copy, nonatomic) NSString *state_id;
@property (copy, nonatomic) NSString *user_id;
@property (copy, nonatomic) NSString *size_id;
@property (copy, nonatomic) NSString *soc_network_type;
@property (copy, nonatomic) NSString *city_name;

@property (strong, nonatomic) NSArray *editableFields;
@property (strong, nonatomic) NSArray *selectableFields;

@property (assign, nonatomic) BOOL selected;

- (void)loadFromDictionary:(NSDictionary *)dict;
- (NSArray *)buildProfileItems;
- (NSArray *)buildSearchItems;
- (NSDictionary *)profileToSendFromProfileItems:(NSArray *)profileItems;
- (NSDictionary *)searchParamsFromSearchItems:(NSArray *)searchItems;

- (NSString *)titleName;
- (NSString *)positionName;
- (NSString *)seniorityName;
- (NSString *)industryName;
- (NSString *)countryName;
- (NSString *)stateName;

- (NSString *)buildName;
- (NSString *)buildPosition;
- (NSString *)buildLocation;
- (NSString *)buildFromNetwork;

@end
