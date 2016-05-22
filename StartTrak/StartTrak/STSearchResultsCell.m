//
//  STSearchResultsCell.m
//  StartTrak
//
//  Created by mdv on 07/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSearchResultsCell.h"
#import "STStyleUtility.h"
#import "STProfile.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface STSearchResultsCell ()

@property (weak, nonatomic) IBOutlet UILabel *initialsView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialNetworkTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImage;

@end

@implementation STSearchResultsCell

- (void)awakeFromNib
{
    self.initialsView.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:36.0];
    self.nameLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFontBold] size:16.0];
    self.positionLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:12.0];
    self.locationLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:11.0];
    self.socialNetworkTypeLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:10.0];
}

- (void)setProfile:(STProfile *)profile
{
    _profile = profile;
    
    //Checkmark
    NSString *checkmarkImageName = self.profile.selected ? @"checkmark-selected" : @"checkmark";
    self.checkmarkImage.image = [UIImage imageNamed:checkmarkImageName];
    
    //Build initials
    NSMutableString *initials = [[NSMutableString alloc] init];
    
    if (self.profile.first_name.length > 0)
    {
        [initials appendString: [[self.profile.first_name substringWithRange: NSMakeRange(0, 1)] uppercaseString]];
    }
    
    if (self.profile.last_name.length > 0)
    {
        [initials appendString: [[self.profile.last_name substringWithRange: NSMakeRange(0, 1)] uppercaseString]];
    }

    if (initials.length > 0) {
        self.initialsView.text = initials;
    }
    
    //Setup avatar
    __weak typeof (self) weakSelf = self;
    
    if (profile.profile_pic && profile.profile_pic.length > 0) {
    [STStyleUtility setupAvatarImageWithURLString:profile.profile_pic ofSize:CGSizeMake(72.0, 72.0) completion:^(UIImage *image) {
        weakSelf.avatarView.image = image;
    }];
    }
    else {
        self.avatarView.image = nil;
    }
    
    //Name Label
    self.nameLabel.text = [self.profile buildName];
    
    //Position label
    self.positionLabel.text = [self.profile buildPosition];
    
    //Location label
    self.locationLabel.text = [self.profile buildLocation];
    
    //Via Network
    self.socialNetworkTypeLabel.text = [self.profile buildFromNetwork];
}



//- (void)setupAvatarImageWithURLString:(NSString *)urlString
//{
//    if (!urlString) {
//        return;
//    }
//    
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    
//    __weak typeof (self) weakSelf = self;
//    
//    [manager downloadImageWithURL:[NSURL URLWithString:urlString]
//                          options:0
//                         progress:nil
//                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                            if (image) {
//                                weakSelf.avatarView.image = [STStyleUtility buildAvatarImageFromImage:image imageSize:CGSizeMake(72.0, 72.0)];
//                            }
//                        }];
//
//}

@end
