//
//  STService.h
//  StartTrak
//
//  Created by mdv on 07/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, STLoginType) {
    STLoginTypeNative = 0, //user name + password
    STOAuthLoginTypeFacebook,
    STOAuthLoginTypeLinkedIn,
    STOAuthLoginTypeXing
};

typedef NS_ENUM(NSInteger, STServiceErrorCode) {
    STServiceErrorCodeInternalError = 1,
    STServiceErrorCodeSuccess = 0,
    STServiceErrorCodeUnauthorized = 1000,
    STServiceErrorCodeUserExists = 1001,
    STServiceErrorCodeUsernamePasswordNotCorrect = 1002,
    STServiceErrorCodeTokenExpired = 1003,
    STServiceErrorCodeProfileDoesntExist = 1006,
    
    
    STServiceErrorCodeOAuthUserClosedDialog = 9000
};

//Callbacks
typedef void (^STServiceSuccessBlock)(id content);
typedef void (^STServiceFailureBlock)(STServiceErrorCode status, NSString *msg);

//Login Params
//OAuth2: Facebook, LinkedIn
extern NSString * const kLoginParamAccessToken;
extern NSString * const kLoginParamOAuthToken;

//OAuth1: Xing
extern NSString * const kLoginParamOAuthTokenSecret;

//Internal
extern NSString * const kLoginParamUsername;
extern NSString * const kLoginParamPassword;

//Login type
extern NSString * const kLoginParamSocialNetworkType;

//Search Params



//Invitation Params

@class STProfile;
typedef enum STLoginType : NSInteger STLoginType;

@interface STService : NSObject



#pragma mark - Auth
+ (BOOL)hasSessionID;

//+ (void)loginUserWithParams:(NSDictionary *)params
//                 forceLogin:(BOOL)forceLogin
//                    success:(STServiceSuccessBlock)success
//                    failure:(STServiceFailureBlock)failure;

+ (void)logoutUserOnSuccess:(STServiceSuccessBlock)success
                    failure:(STServiceFailureBlock)failure;

+ (void)createUserWithLoginParams:(NSDictionary *)params
                          success:(STServiceSuccessBlock)success
                          failure:(STServiceFailureBlock)failure;

+ (void)signInUserWithLoginParams:(NSDictionary *)params
                          success:(STServiceSuccessBlock)success
                          failure:(STServiceFailureBlock)failure;


//#pragma mark - Dictionaries
//+ (void)getDictionariesOnSuccess:(STServiceSuccessBlock)success
//                         failure:(STServiceFailureBlock)failure;

#pragma mark - Profile
+ (void)createUserProfile:(NSDictionary *)profileDict
                  success:(STServiceSuccessBlock)success
                  failure:(STServiceFailureBlock)failure;

+ (void)updateUserProfile:(NSDictionary *)profileDict
                  success:(STServiceSuccessBlock)success
                  failure:(STServiceFailureBlock)failure;

+ (void)getUserProfileWithLoginParams:(NSDictionary *)loginParams
                              success:(STServiceSuccessBlock)success
                              failure:(STServiceFailureBlock)failure;

#pragma mark - Search
+ (void)searchProfilesWithParams:(NSDictionary *)searchParams
                         success:(STServiceSuccessBlock)success
                         failure:(STServiceFailureBlock)failure;

#pragma mark - Meet (Invitations)
+ (void)sendInvitationsToUsersWithParams:(NSDictionary *)meetParams
                                 success:(STServiceSuccessBlock)success
                                 failure:(STServiceFailureBlock)failure;

#pragma mark - Helper
+ (NSString *)socialNetworkNameFromType:(STLoginType)type;

+ (NSString *)serviceErrorCodeStringFromEnum:(STServiceErrorCode)code;

@end
