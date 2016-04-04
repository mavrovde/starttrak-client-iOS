//
//  STStyleUtility.m
//  StartTrak
//
//  Created by mdv on 02/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STStyleUtility.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIColor (HEXColors)

+ (UIColor *)colorWithRGBA:(NSUInteger)color
{
    return [UIColor colorWithRed:((color >> 24) & 0xFF) / 255.0f
                           green:((color >> 16) & 0xFF) / 255.0f
                            blue:((color >> 8) & 0xFF) / 255.0f
                           alpha:((color) & 0xFF) / 255.0f];
}

@end

@implementation iPhoneDeviceBlockExecutor
+ (void)executeDeviceBlocks:(iPhoneDeviceBlock)iphone4sBlock
               iphone5Block:(iPhoneDeviceBlock)iphone5Block
               iphone6Block:(iPhoneDeviceBlock)iphone6Block
           iphone6PlusBlock:(iPhoneDeviceBlock)iphone6PlusBlock
{
    NSInteger screenHeight = (NSInteger)[UIScreen mainScreen].bounds.size.height;
    
    switch (screenHeight)
    {
        case 480: //4, 4s
        {
            if (iphone4sBlock) iphone4sBlock();
            
            break;
        }
            
        case 568: //5
        {
            if (iphone5Block) iphone5Block();
            break;
        }
            
        case 667: //6
        {
            if (iphone6Block) iphone6Block();
            break;
        }
            
        case 736: //6+
        {
            if (iphone6PlusBlock) iphone6PlusBlock();
            break;
        }
            
            
        default:
            break;
    }
}
@end

@implementation NSLayoutConstraint (Multiplier)

- (void)setMultiplier:(CGFloat)multiplier
{
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:self.firstItem
                                                         attribute:self.firstAttribute
                                                         relatedBy:self.relation
                                                            toItem:self.secondItem
                                                         attribute:self.secondAttribute
                                                        multiplier:multiplier
                                                          constant:self.constant];
    newConstraint.priority = self.priority;
    newConstraint.shouldBeArchived = self.shouldBeArchived;
    newConstraint.identifier = self.identifier;
    
    self.active = NO;
    newConstraint.active = YES;
}

@end


@implementation STStyleUtility

+ (NSString *)defaultAppFont
{
    return @"Bariol-Regular";
}

+ (NSString *)defaultAppFontBold
{
    return @"Bariol-Bold";
}

+ (NSString *)defaultAppFontLight
{
    return @"Bariol-Light";
}

+ (UIColor *)defaultAppTextColor
{
    return [UIColor colorWithRGBA:0xF8FAF4FF];
}

+ (UIColor *)createProfileBackgroundColor
{
    return [UIColor colorWithRGBA:0x352F2FFF];
}

+ (void) setNavigationBar:(UINavigationBar *)bar textColorToColor:(UIColor *)color barStyle:(UIBarStyle)barStyle
{
    NSShadow *navBarShadow = [[NSShadow alloc] init];
    navBarShadow.shadowColor = [UIColor clearColor];
    navBarShadow.shadowOffset = CGSizeZero;
    
    [bar setTitleTextAttributes:@{
                                  NSForegroundColorAttributeName : color,
                                  NSShadowAttributeName : navBarShadow,
                                  NSFontAttributeName : [UIFont fontWithName:[self defaultAppFont] size:24.0],
                                  }];
    
    bar.tintColor = color;
    bar.barStyle = barStyle;
    bar.translucent = YES;
    bar.backgroundColor = [UIColor clearColor];
    
    bar.shadowImage = [UIImage new];
    [bar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];

}

+ (void)setupBackButtonOfColor:(UIColor *)color inNavigationItem:(UINavigationItem *)navItem target:(id)target action:(SEL)action
{
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"back.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:target
                                                         action:action];
    navItem.backBarButtonItem = b;
    navItem.leftBarButtonItem = b;
}

+ (UIImage *) buildAvatarImageFromImage:(UIImage *)originalImage imageSize:(CGSize)imageSize
{
    CGFloat size = MIN( imageSize.width, imageSize.height );
    CGRect bounds = CGRectMake( 0, 0, size, size );
    
    UIGraphicsBeginImageContextWithOptions( bounds.size, NO, 0.0 );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor( context, 0.0, 0.0, 0.0, 1.0 );
    CGContextSetLineWidth( context, 1.0 );
    
    CGPathRef path = CGPathCreateWithEllipseInRect( bounds, NULL );
    CGContextAddPath( context, path );
    CGContextClip( context );
    
    [originalImage drawInRect: bounds];
    
    UIImage *avatarImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return avatarImage;
}

+ (void)setupAvatarImageWithURLString:(NSString *)urlString
                               ofSize:(CGSize)size
                           completion:(void(^)(UIImage *image))completion
{
    if (!urlString) {
        return;
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager downloadImageWithURL:[NSURL URLWithString:urlString]
                          options:0
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                
                                UIImage *maskedImage = [self buildAvatarImageFromImage:image imageSize:size];
                                
                                if (completion) {
                                    completion (maskedImage);
                                }
                            }
                        }];
    
}


@end
