//
//  UIButton+Activity.m
//  StartTrak
//
//  Created by mdv on 14/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "UIButton+Activity.h"
#import <objc/runtime.h>

#define kIndicatorTag 777

@interface UIButton (ActivityPrivate)

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation UIButton (Activity)

-(void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    objc_setAssociatedObject(self, @selector(activityIndicator), activityIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIActivityIndicatorView *)activityIndicator
{
    return objc_getAssociatedObject(self, @selector(activityIndicator));
}

- (void)startActivityIndicator
{
    if (![self viewWithTag:kIndicatorTag]) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = CGPointMake(self.frame.size.width-indicatorView.frame.size.width-20.0, self.frame.size.height/2);
        self.activityIndicator = indicatorView;
        self.activityIndicator.tag = kIndicatorTag;
        [self addSubview:self.activityIndicator];
        self.enabled = NO;
        [self.activityIndicator startAnimating];
    }
    
}

- (void)stopActivityIndicator
{
    self.enabled = YES;
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

@end
