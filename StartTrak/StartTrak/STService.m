//
//  STService.m
//  StartTrak
//
//  Created by mdv on 07/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STService.h"
#import "STDictionariesManager.h"
#import <AFNetworking/AFNetworking.h>
#import <OAuthObjcAuthenticator/OAuthObjcAuthenticator.h>

//Login Params
//OAuth2: Facebook, LinkedIn
NSString * const kLoginParamAccessToken = @"access_token";
NSString * const kLoginParamOAuthToken = @"oauth_token";

//OAuth1: Xing
NSString * const kLoginParamOAuthTokenSecret = @"oauth_token_secret";

//Internal
NSString * const kLoginParamUsername = @"email";
NSString * const kLoginParamPassword = @"password";

//Login type
NSString * const kLoginParamSocialNetworkType = @"soc_network_type";

//Base URL
#define kBaseURL @"http://mavrov.de:8080"

//URIs
#define kLoginURI @"starttrak-profiles-rest/service/auth/login"
#define kLogoutURI @"logout"
#define kValidateURI @"starttrak-profiles-rest/service/auth/validate"
#define kDictionariesURI @"starttrak-profiles-rest/service/dictionaries/all"
#define kProfileURI @"starttrak-profiles-rest/service/profile"
#define kSearchURI @"starttrak-profiles-rest/service/profile/search"
#define kMeetURI @"starttrak-profiles-rest/service/profile/meet"

//User Defaults Session Id Key
#define kUserDefaultsSessionIDKey @"kUserDefaultsSessionIDKey"

//Response object keys
#define kResponseObjectErrorCodeKey @"code"
#define kResponseObjectContentKey @"content"
#define kResponseObjectMessageKey @"message"

//TEST MODE
//#define TEST_MODE 1

@interface STService ()

@property (assign, nonatomic) BOOL validSession;
@property (copy, nonatomic) NSString *sessionID;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation STService

+ (instancetype)sharedService
{
    static STService *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[STService alloc] init];
        instance.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        instance.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        instance.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
#ifdef TEST_MODE
        NSDictionary *testDict = @{
                                   kEntryKeyIndustries : @[
                                           @{
                                               @"id": @23,
                                               @"name": @"Computer Hardware"
                                               }, @{
                                               @"id": @24,
                                               @"name": @"Computer Networking"
                                               }, @{
                                               @"id": @25,
                                               @"name": @"Computer Software"
                                               }, @{
                                               @"id": @26,
                                               @"name": @"Construction"
                                               }
                                           ],
                                   
                                   kEntryKeyPositions : @[
                                           @{
                                               @"id": @255,
                                               @"name": @"Security Specialist"
                                               }, @{
                                               @"id": @256,
                                               @"name": @"Senior Management Information"
                                               }, @{
                                               @"id": @257,
                                               @"name": @"Social Insurance Analyst"
                                               }],
                                   
                                   kEntryKeySeniorities : @[
                                           @{
                                               @"id": @5,
                                               @"seniorityCode": @"m",
                                               @"name": @"Manager"
                                               }, @{
                                               @"id": @6,
                                               @"seniorityCode": @"d",
                                               @"name": @"Director"
                                               }, @{
                                               @"id": @7,
                                               @"seniorityCode": @"vp",
                                               @"name": @"Vice President (VP)"
                                               }, @{
                                               @"id": @8,
                                               @"seniorityCode": @"c",
                                               @"name": @"Chief X Officer (CxO)"
                                               }
                                           ]
                                   
                                   };
        [[STDictionariesManager sharedInstance] loadDictionariesWithContent:testDict];
#endif
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsSessionIDKey];
    }
    return self;
}

- (void)setSessionID:(NSString *)sessionID
{
    NSLog(@"sessionID=%@", sessionID);
    
    if (sessionID && ![_sessionID isEqualToString:sessionID]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        [ud setObject:sessionID forKey:kUserDefaultsSessionIDKey];
        
        [ud synchronize];
    }
    
    _sessionID = sessionID;

    if (nil != _sessionID) {
        [self.sessionManager.requestSerializer setValue:_sessionID forHTTPHeaderField:@"x-auth-id"];
    }
}

- (void)GET:(NSString *)uri
     params:(NSDictionary *)params
    success:(STServiceSuccessBlock)success
    failure:(STServiceFailureBlock)failure
{
    [[self.sessionManager GET:uri
                  parameters:params
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         [self processResponse:responseObject success:success failure:failure];
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         if (failure) {
                             failure(STServiceErrorCodeInternalError, error.localizedDescription);
                         }
                     }] resume];
}

- (void)POST:(NSString *)uri
      params:(NSDictionary *)params
     success:(STServiceSuccessBlock)success
     failure:(STServiceFailureBlock)failure
{
    [[self.sessionManager POST:uri
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          [self processResponse:responseObject success:success failure:failure];
                      }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          if (failure) {
                              failure(STServiceErrorCodeInternalError, error.localizedDescription);
                          }
                      }] resume];
}

- (void)PUT:(NSString *)uri
     params:(NSDictionary *)params
    success:(STServiceSuccessBlock)success
    failure:(STServiceFailureBlock)failure
{
    [[self.sessionManager PUT:uri
                  parameters:params
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         [self processResponse:responseObject success:success failure:failure];
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         if (failure) {
                             failure(STServiceErrorCodeInternalError, error.localizedDescription);
                         }
                     }] resume];
}

- (void)processResponse:(id)responseObject
                success:(STServiceSuccessBlock)success
                failure:(STServiceFailureBlock)failure
{
    if (success) {
        
        NSNumber *statusCode = responseObject[kResponseObjectErrorCodeKey];
        NSString *errorMsg = responseObject[kResponseObjectMessageKey];
        
        if (!statusCode) {
            if (failure) {
                failure(STServiceErrorCodeInternalError, @"Internal Error");
                return;
            }
        }
        
        if (statusCode) {
            STServiceErrorCode statusCodeVal = [statusCode integerValue];
            
            if (STServiceErrorCodeSuccess != statusCodeVal) {
                if (failure) {
                    failure(statusCodeVal, errorMsg ?: @"Internal Error");
                }
                return;
            }
        }
        
        NSDictionary *content = responseObject[kResponseObjectContentKey];
        
        if (success) {
            success(content);
        }
    }
}

#pragma mark - Auth
+ (BOOL)hasSessionID
{
    return nil != [[self sharedService] sessionID];
}

+ (void)validateSessionOnSuccess:(STServiceSuccessBlock)success
                         failure:(STServiceFailureBlock)failure
{
    NSString *sessionID = [[self sharedService] sessionID];
    
    if (nil == sessionID || 0 == sessionID.length) {
        return;
    }
    
    NSDictionary *params = @{
                             @"session_id" : sessionID
                             };
    
    [[self sharedService] GET:kValidateURI
                       params:params
                      success:success
                      failure:failure];
}

+ (void)createUserWithLoginParams:(NSDictionary *)params
                          success:(STServiceSuccessBlock)success
                          failure:(STServiceFailureBlock)failure
{
    NSParameterAssert(params);
    
    [self loginUserWithParams:params
                   forceLogin:NO
                      success:^(NSDictionary *content) {
                          NSString *sessionID = content[@"session_id"];
                          
                          assert(nil != sessionID && sessionID.length > 0);
                          
                          [[self sharedService] setSessionID:sessionID];
                          
                          if (success) {
                              success(content);
                          }
                          
                      } failure:failure];
}

+ (void)signInUserWithLoginParams:(NSDictionary *)params
                          success:(STServiceSuccessBlock)success
                          failure:(STServiceFailureBlock)failure
{
    [self loginUserWithParams:params
                   forceLogin:NO
                      success:^(NSDictionary *content) {
                          NSNumber *profileExists = content[@"profile_exists"];
                          
                          if (!profileExists || NO == [profileExists boolValue]) {
                              if (failure) {
                                  failure(STServiceErrorCodeProfileDoesntExist, @"User exists, but Profile hasn't been created yet.");
                              }
                          }
                          else {
                              NSString *sessionID = content[@"session_id"];
                              
                              assert(nil != sessionID && sessionID.length > 0);
                              
                              [[self sharedService] setSessionID:sessionID];
                              
                              [self getDictionariesOnSuccess:^(id content) {
                                  if (success) {
                                      success(nil);
                                  }
                              } failure:failure];
                          }
                      }
                      failure:failure];
}

+ (NSDictionary *)OAuthOptionsForLoginType:(STLoginType)loginType
{
    switch (loginType) {
        case STOAuthLoginTypeFacebook:
            return @{
                     @"client_key" : @"659248597511389",
                     @"secret_key" : @"4e8d68b411affc73f0d15b82970b3056",
                     @"uri" : @"http://localhost/li",
                     @"authenticator" : kOAuthObjcAuthenticatorFacebook
                     };
            
        case STOAuthLoginTypeLinkedIn:
            return @{
                     @"client_key" : @"774g998g1hvui6",
                     @"secret_key" : @"12WaBJlQxbSndcSI",
                     @"uri" : @"http://localhost/li",
                     @"authenticator" : kOAuthObjcAuthenticatorLinkedIn
                     };
            
        case STOAuthLoginTypeXing:
            return @{
                     @"client_key" : @"200498315bfcba1df1dc",//@"4cbc7615d6bfcb8d597e",
                     @"secret_key" : @"c9d77b643643bd940c475ce08deba22c55dd3fa6",//@"817043f7325e2cf287ad462b6d93431ce8ee231b",
                     @"uri" : @"http://localhost/li",
                     @"authenticator" : kOAuthObjcAuthenticatorXing
                     };
        
        default:
            break;
    }
    
    return nil;
}

+ (void)loginUserWithParams:(NSDictionary *)params
                 forceLogin:(BOOL)forceLogin
                    success:(STServiceSuccessBlock)success
                    failure:(STServiceFailureBlock)failure
{
    NSParameterAssert(params);
    
    NSNumber *loginType = params[kLoginParamSocialNetworkType];
    
    assert(nil != loginType);
    
    STLoginType lType = [loginType integerValue];
    
    if (STLoginTypeNative == lType) {
        [self doLoginWithParams:params success:success failure:failure];
    }
    else {
        NSDictionary *OAuthOpts = [self OAuthOptionsForLoginType:lType];
        
        [OAuthObjcAuthenticator authenticateUsingAuthenticator:OAuthOpts[@"authenticator"]
                                                     clientKey:OAuthOpts[@"client_key"]
                                                     secretKey:OAuthOpts[@"secret_key"]
                                                   redirectURI:OAuthOpts[@"uri"]
                                                     forceAuth:forceLogin
                                                    completion:^(NSDictionary *authTokens, NSError *error)
        {
            if (nil != error) {
                NSLog(@"OAuth Error: %@", [error localizedDescription]);
                
                if (failure) {
                    
                    if ([error.domain isEqualToString:@"com.vd.oAuth"] && error.code == 0x100) {
                        //user closed oAuth dialog
                        failure(STServiceErrorCodeOAuthUserClosedDialog, @"OAuth Dialog closed by the user");
                    }
                    else {
                        failure(STServiceErrorCodeInternalError, [error localizedDescription]);
                    }
                }
            }
            else {
                NSLog(@"authTokens: %@", [authTokens description]);
                //                 NSMutableDictionary *loginParams = [NSMutableDictionary dictionaryWithCapacity:params.count];
                NSMutableDictionary *loginParams = [NSMutableDictionary dictionaryWithDictionary:params];
                [loginParams removeObjectForKey:@"forceLogin"];
                
                switch (lType) {
                    case STOAuthLoginTypeFacebook:
                        loginParams[kLoginParamAccessToken] = authTokens[kLoginParamAccessToken] ?: @"";
                        break;
                        
                    case STOAuthLoginTypeLinkedIn:
                        loginParams[kLoginParamAccessToken] = authTokens[kLoginParamAccessToken] ?: @"";
                        break;
                        
                    case STOAuthLoginTypeXing:
                        loginParams[kLoginParamOAuthToken] = authTokens[kLoginParamOAuthToken] ?: @"";
                        loginParams[kLoginParamOAuthTokenSecret] = authTokens[kLoginParamOAuthTokenSecret]?: @"";
                        break;
                        
                    default:
                        break;
                }
                
                assert(nil != loginParams);
                
                [self doLoginWithParams:loginParams success:success failure:failure];
            }
        }];
    }
}

+ (void)doLoginWithParams:(NSDictionary *)params
                  success:(STServiceSuccessBlock)success
                  failure:(STServiceFailureBlock)failure
{
    [[self sharedService] POST:kLoginURI params:params success:success failure:failure];
}

+ (void)doGetProfileWithParams:(NSDictionary *)params
                       success:(STServiceSuccessBlock)success
                       failure:(STServiceFailureBlock)failure
{
    [[self sharedService] GET:kProfileURI params:params success:success failure:failure];
}

+ (void)logoutUserOnSuccess:(STServiceSuccessBlock)success
                    failure:(STServiceFailureBlock)failure
{
    assert([self hasSessionID]);
    
    [[self sharedService] GET:kLogoutURI params:nil success:success failure:failure];
}

#pragma mark - Dictionaries
+ (void)getDictionariesOnSuccess:(STServiceSuccessBlock)success
                         failure:(STServiceFailureBlock)failure
{
    assert([self hasSessionID]);
    
    [[self sharedService] GET:kDictionariesURI
                       params:nil
                      success:success failure:failure];
}

#pragma mark - Profile
+ (void)createUserProfile:(NSDictionary *)profileDict
                  success:(STServiceSuccessBlock)success
                  failure:(STServiceFailureBlock)failure
{
    assert([self hasSessionID]);
    
    [[self sharedService] POST:kProfileURI
                        params:profileDict
                       success:success
                       failure:failure];
}

+ (void)updateUserProfile:(NSDictionary *)profileDict
                  success:(STServiceSuccessBlock)success
                  failure:(STServiceFailureBlock)failure
{
    assert([self hasSessionID]);
    
    [[self sharedService] PUT:kProfileURI
                       params:profileDict
                      success:success
                      failure:failure];
}

+ (void)getUserProfileWithLoginParams:(NSDictionary *)loginParams
                              success:(STServiceSuccessBlock)success
                              failure:(STServiceFailureBlock)failure
{
#ifdef TEST_MODE
    success(@{
               @"first_name" : @"Suzanne",
               @"last_name" : @"Herzig",
               @"industry_id" : @25,
               @"position_id" : @256,
               @"seniority_id" : @6,
               @"profile_pic" : @"https://www.dropbox.com/s/j4sqjo1kawkubrx/suzanne_herzig_356.png?dl=1"
            });
    return;
#endif
    
    if (nil == loginParams && [self hasSessionID]) {
        [self validateSessionOnSuccess:^(NSDictionary *content) {
            [[self sharedService] setValidSession:YES];
            [[self sharedService] setSessionID:content[@"session_id"]];
            [self getDictionariesOnSuccess:^(NSDictionary *content) {
                [[STDictionariesManager sharedInstance] loadDictionariesWithContent:content];
                
                [self doGetProfileWithParams:nil success:success failure:failure];
                
            } failure:failure];
        } failure:failure];
    }
    else {
        NSNumber *forceLogin = loginParams[@"forceLogin"];
        
        BOOL theForceLogin = forceLogin && YES == [forceLogin boolValue];
        
        [self loginUserWithParams:loginParams
                       forceLogin:theForceLogin
                          success:^(NSDictionary *content) {
            NSString *session = content[@"session_id"];
            
            [[self sharedService] setSessionID:session];
            [[self sharedService] setValidSession:YES];
            
            [self getDictionariesOnSuccess:^(NSDictionary *content) {
                [[STDictionariesManager sharedInstance] loadDictionariesWithContent:content];
                
                [self doGetProfileWithParams:nil success:success failure:failure];
                
            } failure:failure];
        } failure:failure];
    }
}


#pragma mark - Search
+ (void)searchProfilesWithParams:(NSDictionary *)searchParams
                         success:(STServiceSuccessBlock)success
                         failure:(STServiceFailureBlock)failure
{
    assert([self hasSessionID]);
    
    [[self sharedService] POST:kSearchURI params:searchParams success:success failure:failure];
    
}

#pragma mark - Meet (Invitations)
+ (void)sendInvitationsToUsersWithParams:(NSDictionary *)meetParams
                                 success:(STServiceSuccessBlock)success
                                 failure:(STServiceFailureBlock)failure
{
    assert([self hasSessionID]);
    
    [[self sharedService] POST:kMeetURI params:meetParams success:success failure:failure];
}

+ (NSString *)socialNetworkNameFromType:(STLoginType)type
{
    switch (type) {
        case STLoginTypeNative:
            return @"StarTTrak";
        case STOAuthLoginTypeFacebook:
            return @"Facebook";
        case STOAuthLoginTypeLinkedIn:
            return @"LinkedIn";
        case STOAuthLoginTypeXing:
            return @"Xing";
        default:
            return @"Unknown";
    }
}

+ (NSString *)serviceErrorCodeStringFromEnum:(STServiceErrorCode)code
{
    switch (code) {
        case STServiceErrorCodeSuccess:
            return @"STServiceErrorCodeSuccess";

        case STServiceErrorCodeInternalError:
            return @"STServiceErrorCodeInternalError";
        
        case STServiceErrorCodeUnauthorized:
            return @"STServiceErrorCodeUnauthorized";
        
        case STServiceErrorCodeUserExists:
            return @"STServiceErrorCodeUserExists";
        
        case STServiceErrorCodeUsernamePasswordNotCorrect:
            return @"STServiceErrorCodeUsernamePasswordNotCorrect";
        
        case STServiceErrorCodeTokenExpired:
            return @"STServiceErrorCodeTokenExpired";
            
        case STServiceErrorCodeProfileDoesntExist:
            return @"STServiceErrorCodeProfileDoesntExist";
        
        default:
            return @"Unknown Error Code";
    }
}

@end
