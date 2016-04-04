//
//  STStyleUtility.h
//  StartTrak
//
//  Created by mdv on 02/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIColor (HEXColors)

+ (UIColor *)colorWithRGBA:(NSUInteger)color;

@end

typedef void(^iPhoneDeviceBlock)();

@interface iPhoneDeviceBlockExecutor : NSObject

+ (void)executeDeviceBlocks:(iPhoneDeviceBlock)iphone4sBlock
               iphone5Block:(iPhoneDeviceBlock)iphone5Block
               iphone6Block:(iPhoneDeviceBlock)iphone6Block
           iphone6PlusBlock:(iPhoneDeviceBlock)iphone6PlusBlock;
@end

@interface NSLayoutConstraint (Multiplier)
- (void)setMultiplier:(CGFloat)multiplier;
@end


@interface STStyleUtility : NSObject

+ (NSString *)defaultAppFont;
+ (NSString *)defaultAppFontBold;
+ (NSString *)defaultAppFontLight;

+ (UIColor *)defaultAppTextColor;

+ (UIColor *)createProfileBackgroundColor;

+ (void) setNavigationBar:(UINavigationBar *)bar textColorToColor:(UIColor *)color barStyle:(UIBarStyle)barStyle;
+ (void) setupBackButtonOfColor:(UIColor *)color inNavigationItem:(UINavigationItem *)navItem target:(id)target action:(SEL)action;
+ (UIImage *) buildAvatarImageFromImage:(UIImage *)originalImage imageSize:(CGSize)imageSize;

+ (void)setupAvatarImageWithURLString:(NSString *)urlString
                               ofSize:(CGSize)size
                           completion:(void(^)(UIImage *image))completion;
@end
