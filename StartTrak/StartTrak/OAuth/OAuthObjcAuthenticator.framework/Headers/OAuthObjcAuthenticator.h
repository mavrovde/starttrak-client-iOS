//
//  OAuthObjcAuthenticator.h
//  OAuthObjcAuthenticator
//
//  Copyright © 2016 Denys Maruda. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for OAuthObjcAuthenticator.
FOUNDATION_EXPORT double OAuthObjcAuthenticatorVersionNumber;

//! Project version string for OAuthObjcAuthenticator.
FOUNDATION_EXPORT const unsigned char OAuthObjcAuthenticatorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OAuthObjcAuthenticator/PublicHeader.h>

///OAuth Authenticator for Facebook
extern NSString *const kOAuthObjcAuthenticatorFacebook;

///OAuth Authenticator for LinkedIn
extern NSString *const kOAuthObjcAuthenticatorLinkedIn;

///OAuth Authenticator for Xing
extern NSString *const kOAuthObjcAuthenticatorXing;

///Use this key to get the access_token from authTokens dictionary (compatible with OAuth2 providers)
extern NSString *const kOAuthObjcAuthenticatorTokenKeyAccessTokenOAuth2;

///Use this key to get the oauth_token from authTokens dictionary (compatible with OAuth1 providers)
extern NSString *const kOAuthObjcAuthenticatorTokenKeyOAuthTokenOAuth1;

///Use this key to get the oauth_token_secret from authTokens dictionary (compatible with OAuth1 providers)
extern NSString *const kOAuthObjcAuthenticatorTokenKeyOAuthTokenSecretOAuth1;

/** OAuth Authenticator completion block
 *  @param authTokens dictionary that contains access tokens
 *  @param error reports error
 */
typedef void (^OAuthObjcAuthenticatorCompletionBlock)(NSDictionary *authTokens, NSError *error);

/** Utility class which provides an ability to authenticate users via Open ID providers.
 *  Invokes OAuthObjcAuthenticatorCompletionBlock block when finished.
 *  Auth Tokens are cached in User Defaults
 */
@interface OAuthObjcAuthenticator : NSObject

/** Authenticates user in OpenID provider, specified in "authenticator" parameter. Invokes a completion callback when finished.
 *  @param authenticator Name of the OpenID provider. See supported authenticator types above
 *  @param clientKey Client Key. Obtained from provider.
 *  @param secretKey Secret Key. Obtained from provider.
 *  @param redirectURI Redirect URL. Usually you should add the same URL to your provider's dashboard
 *  @param forceAuth indicates if auth dialog (Web View) should be forcefully shown.
 *  @param completion Completion block which is invoked when authentication is done.
 */
+ (void)authenticateUsingAuthenticator:(NSString *)authenticator
                             clientKey:(NSString *)clientKey
                             secretKey:(NSString *)secretKey
                           redirectURI:(NSString *)redirectURI
                             forceAuth:(BOOL)forceAuth
                            completion:(OAuthObjcAuthenticatorCompletionBlock)completion;

@end