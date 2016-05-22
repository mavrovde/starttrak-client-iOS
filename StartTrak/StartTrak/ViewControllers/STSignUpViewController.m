//
//  STSignUpViewController.m
//  StartTrak
//
//  Created by mdv on 29/01/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSignUpViewController.h"
#import "STSearchViewController.h"
#import "STSignUpWithEmailViewController.h"

#import "STStyleUtility.h"
#import "STService.h"
#import "STProfile.h"
#import "STCreateProfileViewController.h"
#import "UIButton+Activity.h"
#import "VDAlertMessageView.h"

typedef void (^getUserProfileBlock)(NSDictionary *params);

@interface STSignUpViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signInWithFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *signInWithLinkedInButton;
@property (weak, nonatomic) IBOutlet UIButton *signInWithXingButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *signupWithEmailButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *haveAnAccountLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topGroupMutiplier;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topGroupMultiplies4s;

@property (copy, nonatomic) getUserProfileBlock getUserProfile;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;
@end

@implementation STSignUpViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [iPhoneDeviceBlockExecutor
     executeDeviceBlocks:^{
         [self.topGroupMutiplier setMultiplier:3.0];
     }
     iphone5Block:nil
     iphone6Block:nil
     iphone6PlusBlock:nil];
    
    [self.signInWithFacebookButton stopActivityIndicator];
    [self.signInWithLinkedInButton stopActivityIndicator];
    [self.signInWithXingButton stopActivityIndicator];
    
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    [STStyleUtility setNavigationBar:self.navigationController.navigationBar
                    textColorToColor:[STStyleUtility defaultAppTextColor]
                            barStyle:UIBarStyleBlack];
    
    self.welcomeLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:30.0];
    self.orLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    
    self.signInWithFacebookButton.titleLabel.font =
    self.signInWithLinkedInButton.titleLabel.font =
    self.signInWithXingButton.titleLabel.font =
    self.signupWithEmailButton.titleLabel.font =
    [UIFont fontWithName:[STStyleUtility defaultAppFont] size:18.0];
    
    self.haveAnAccountLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:16.0];
    self.signInButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFontBold] size:20.0];
    
    self.loginActivityIndicator.hidden = YES;
    
    //Try Auto Login
    if ([STService hasSessionID]) {

        [self hideLoginControls];
        
        self.loginActivityIndicator.hidden = NO;
        [self.loginActivityIndicator startAnimating];
        self.view.userInteractionEnabled = NO;
        
        //Get User Profile
        [STService getUserProfileWithLoginParams:nil
                                         success:^(NSDictionary *content) {
                                             STProfile *profile = [STProfile new];
                                             [profile loadFromDictionary:content];
                                             
                                             [self showLoginControlsAnimated:YES];
                                             
                                             [self.loginActivityIndicator stopAnimating];
                                             self.view.userInteractionEnabled = YES;
                                             
//                                             [self performSegueWithIdentifier:@"STSearchViewControllerSegue" sender:profile];
                                             [self performSegueWithIdentifier:@"showStartTracking" sender:nil];
                                             
                                         } failure:^(STServiceErrorCode status, NSString *msg) {
                                             //TODO: error handling
                                             NSLog(@"status=%@, msg=%@", @(status), msg);
                                             
                                             [self.loginActivityIndicator stopAnimating];
                                             self.view.userInteractionEnabled = YES;
                                             
                                             if (STServiceErrorCodeProfileDoesntExist == status) {
                                                 //User exists, but profile hasn't been created yet -> go to CreateProfile
                                                 
                                                 STProfile *profile = [[STProfile alloc] init];
                                                 
                                                 [self performSegueWithIdentifier:@"CreateProfileIfNotExistsSegue" sender:profile];
                                             }
                                             else {
                                                 [VDAlertMessageView showMessageWithTitle:@"Error"
                                                                                     body:[NSString stringWithFormat:@"%@ (error code=%@)", msg, @(status)]
                                                                            cancelHandler:nil
                                                                                doneTitle:nil
                                                                              doneHandler:nil];
                                                 
                                                 [self showLoginControlsAnimated:YES];
                                             }
                                             
                                         }];
    }
}

- (void)showLoginControlsAnimated:(BOOL)animated
{
    __block void (^animationsBlock)() = ^{
        self.signInButton.alpha = 1.0;
        self.signInWithFacebookButton.alpha = 1.0;
        self.signInWithLinkedInButton.alpha = 1.0;
        self.signInWithXingButton.alpha = 1.0;
        self.signupWithEmailButton.alpha = 1.0;
        self.orLabel.alpha = 1.0;
        self.haveAnAccountLabel.alpha = 1.0;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:animationsBlock];
    }
    else {
        animationsBlock();
    }
    
}

- (void)hideLoginControls
{
    self.signInButton.alpha = 0.0;
    self.signInWithFacebookButton.alpha = 0.0;
    self.signInWithLinkedInButton.alpha = 0.0;
    self.signInWithXingButton.alpha = 0.0;
    self.signupWithEmailButton.alpha = 0.0;
    self.orLabel.alpha = 0.0;
    self.haveAnAccountLabel.alpha = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInWithFacebook:(id)sender {
    [self.signInWithFacebookButton startActivityIndicator];
    self.view.userInteractionEnabled = NO;
    
    [self signInWithSocialNetworkParams:@{ kLoginParamSocialNetworkType : @(STOAuthLoginTypeFacebook) } button:self.signInWithFacebookButton];
}

- (IBAction)signInWithLinkedIn:(id)sender {
    [self.signInWithLinkedInButton startActivityIndicator];
    self.view.userInteractionEnabled = NO;
    
    [self signInWithSocialNetworkParams:@{ kLoginParamSocialNetworkType : @(STOAuthLoginTypeLinkedIn) } button:self.signInWithLinkedInButton];
}

- (IBAction)signInWithXing:(id)sender {
    [self.signInWithXingButton startActivityIndicator];
    self.view.userInteractionEnabled = NO;
    
    [self signInWithSocialNetworkParams:@{ kLoginParamSocialNetworkType : @(STOAuthLoginTypeXing) } button:self.signInWithXingButton];
}

- (IBAction)signInButtonClick:(id)sender {
    
//    [self.signupWithEmailButton startActivityIndicator];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.signupWithEmailButton stopActivityIndicator];
//        
//        [VDAlertMessageView showMessageWithTitle:@"Success" body:nil cancelHandler:^{
//            NSLog(@"Cancel clicked");
//        } doneTitle:@"Done" doneHandler:^{
//            NSLog(@"Done clicked");
//        }];
//    });
    
    [self performSegueWithIdentifier:@"signInWithEmailSegue" sender:nil];
}

- (void)signInWithSocialNetworkParams:(NSDictionary *)params button:(UIButton *)signInButton
{
    __weak __block getUserProfileBlock weakGetUserProfile;
    
    __weak typeof (self) weakSelf = self;
    
    if (nil == self.getUserProfile) {
        self.getUserProfile = ^(NSDictionary *params){
//            [weakSelf.signInWithLinkedInButton startActivityIndicator];
//            weakSelf.view.userInteractionEnabled = NO;
            
            [STService getUserProfileWithLoginParams:params success:^(NSDictionary *content) {
                STProfile *profile = [STProfile new];
                
                [profile loadFromDictionary:content];
                
                [weakSelf performSegueWithIdentifier:@"ReviewProfileSegue" sender:profile];
                
                [signInButton stopActivityIndicator];
                weakSelf.view.userInteractionEnabled = YES;
                
            } failure:^(STServiceErrorCode status, NSString *msg) {
                //handle error
                NSLog(@"Login Failure: status=%@, msg=%@", @(status), msg);
                
                [signInButton stopActivityIndicator];
                weakSelf.view.userInteractionEnabled = YES;
                
                if (STServiceErrorCodeTokenExpired == status) {
                    NSMutableDictionary *loginParamsIncludingForceLogin = [params mutableCopy];
                    loginParamsIncludingForceLogin[@"forceLogin"] = @YES;
                    
                    weakGetUserProfile(loginParamsIncludingForceLogin);
                }
                else if (STServiceErrorCodeOAuthUserClosedDialog == status) {
                    NSLog(@"OAuth: %@", msg);
                }
                else {
                    [VDAlertMessageView showMessageWithTitle:@"Login Error"
                                                        body:[NSString stringWithFormat:@"%@ (error code=%@)", msg, @(status)]
                                               cancelHandler:nil
                                                   doneTitle:nil
                                                 doneHandler:nil];
                }
            }];
        };
    }
    
    weakGetUserProfile = self.getUserProfile;
    
    self.getUserProfile(params);

}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
//    if ([segue.identifier isEqualToString:@"STSearchViewControllerSegue"]) {
//        STSearchViewController *svc = segue.destinationViewController;
//        svc.profile = (STProfile *)sender;
//        NSLog(@"svc=%@", svc);
        
//    }
//    else
    if ([segue.identifier isEqualToString:@"signInWithEmailSegue"]) {
        STSignUpWithEmailViewController *signUpEmailVC = segue.destinationViewController;
        
        signUpEmailVC.isSignUp = NO;
//        signUpEmailVC.title = @"Sign in with email";
    }
    else if ([segue.identifier isEqualToString:@"signUpWithEmailSegue"]) {
        STSignUpWithEmailViewController *signUpEmailVC = segue.destinationViewController;
        
        signUpEmailVC.isSignUp = YES;
//        signUpEmailVC.title = @"Sign up with email";
    }
    else if ([segue.identifier isEqualToString:@"ReviewProfileSegue"]) {
        STCreateProfileViewController *reviewProfileVC = segue.destinationViewController;
        reviewProfileVC.isCreateProfile = NO;
        reviewProfileVC.profile = sender;
    }
    else if ([segue.identifier isEqualToString:@"CreateProfileIfNotExistsSegue"]) {
        STCreateProfileViewController *reviewProfileVC = segue.destinationViewController;
        reviewProfileVC.isCreateProfile = YES;
        reviewProfileVC.profile = sender;
    }

}


@end
