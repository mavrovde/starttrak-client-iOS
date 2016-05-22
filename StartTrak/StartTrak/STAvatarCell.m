//
//  STAvatarCell.m
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STAvatarCell.h"
#import "STStyleUtility.h"

@interface STAvatarCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation STAvatarCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAvatarURL:(NSString *)avatarURL
{
    _avatarURL = avatarURL;
    
    __weak typeof (self) weakSelf = self;
    
    [STStyleUtility setupAvatarImageWithURLString:avatarURL ofSize:CGSizeMake(178.0, 178.0) completion:^(UIImage *image) {
        weakSelf.avatarImageView.image = image;
    }];

}

@end
