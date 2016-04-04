//
//  STSignUpWithEmailViewController.m
//  StartTrak
//
//  Created by mdv on 03/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSignUpWithEmailViewController.h"
#import "STStyleUtility.h"
#import "STCreateProfileViewController.h"
#import "STProfile.h"
#import "STDictionariesManager.h"
#import "STService.h"
#import "VDAlertMessageView.h"
#import "UIButton+Activity.h"

@interface STSignUpWithEmailViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailGroupBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation STSignUpWithEmailViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isSignUp) {
        [iPhoneDeviceBlockExecutor
         executeDeviceBlocks:^{
             [UIView animateWithDuration:0.3 animations:^{
                 [self.emailGroupBottomConstraint setMultiplier:2.65];
                 [self.view layoutIfNeeded];
             }];
             
         }
         iphone5Block:nil
         iphone6Block:nil
         iphone6PlusBlock:nil];
    }
    
//    [self setClearButtonImageForTextField:self.email];
//    [self setClearButtonImageForTextField:self.password];

//    [self.view layoutIfNeeded];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO: remove this
    [[STDictionariesManager sharedInstance] loadDictionariesWithContent:nil];
    
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBarHidden = NO;
    
    if (self.isSignUp) {
        self.forgotPasswordLabel.hidden = YES;
        self.bgImageView.image = [UIImage imageNamed:@"signup-email-background"];
    }
    else {
        self.forgotPasswordLabel.hidden = NO;
        self.bgImageView.image = [UIImage imageNamed:@"signin-email-background"];
    }
    
    self.title = self.isSignUp ? @"Sign up with email" : @"Sign in with email";
    
    
//    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"back.png"]
//                                                          style:UIBarButtonItemStylePlain
//                                                         target:self
//                                                         action:@selector(back:)];
//    self.navigationItem.backBarButtonItem = b;
//    self.navigationItem.leftBarButtonItem = b;
    
    [STStyleUtility setupBackButtonOfColor:[UIColor colorWithRGBA:0x312F32FF]
                          inNavigationItem:self.navigationItem
                                    target:self
                                    action:@selector(back:)];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
//    [iPhoneDeviceBlockExecutor executeDeviceBlocks:^{
//        self.emailGroupBottomConstraint.active = NO;
//    } iphone5Block:nil iphone6Block:nil iphone6PlusBlock:nil];

//    [self.view layoutIfNeeded];
//    [iPhoneDeviceBlockExecutor
//     executeDeviceBlocks:^{
//         [self.emailGroupBottomConstraint setMultiplier:2.65];
//     }
//     iphone5Block:nil
//     iphone6Block:nil
//     iphone6PlusBlock:nil];
    
    NSAttributedString *emailPlaceholder = [[NSAttributedString alloc] initWithString:@"Your email"
                                                                      attributes:@{
                                                                                   NSFontAttributeName:[UIFont fontWithName:[STStyleUtility defaultAppFontLight] size:16],
                                                                                   NSForegroundColorAttributeName : [STStyleUtility defaultAppTextColor]
                                                                                   }];
    
    NSAttributedString *passwordPlaceholder = [[NSAttributedString alloc] initWithString:@"Your password"
                                                                              attributes:@{
                                                                                           NSFontAttributeName:[UIFont fontWithName:[STStyleUtility defaultAppFontLight] size:16],
                                                                                           NSForegroundColorAttributeName : [STStyleUtility defaultAppTextColor]
                                                                                           }];
    
    self.email.font = self.password.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:16.0];
    
    self.email.textColor = self.password.textColor = [STStyleUtility defaultAppTextColor];
    self.email.tintColor = self.password.tintColor = [STStyleUtility defaultAppTextColor];
    
    self.email.delegate = self.password.delegate = self;
    
    self.email.clearButtonMode = self.password.clearButtonMode = UITextFieldViewModeNever;
    
    [self setClearButtonImageForTextField:self.email];
    [self setClearButtonImageForTextField:self.password];
    
    [self.email setAttributedPlaceholder:emailPlaceholder];
    [self.password setAttributedPlaceholder:passwordPlaceholder];
    self.password.secureTextEntry = YES;
    
    self.doneButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.doneButton.titleLabel.textColor = [UIColor blackColor];
    
    self.forgotPasswordLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:16.0];
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showErrorMessageWithTitle:(NSString *)title body:(NSString *)body
{
    [VDAlertMessageView showMessageWithTitle:title
                                        body:body
                               cancelHandler:nil
                                   doneTitle:nil
                                 doneHandler:nil];
}

- (void)showGenericErrorWithTitle:(NSString *)title status:(STServiceErrorCode)status message:(NSString *)message
{
    [VDAlertMessageView showMessageWithTitle:title
                                        body:[NSString stringWithFormat:@"%@ (error code=%@)", message, @(status)]
                               cancelHandler:nil
                                   doneTitle:nil
                                 doneHandler:nil];
}

- (BOOL)isValidEmail:(NSString *)email
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

- (BOOL)isValidPassword:(NSString *)pwd
{
    return nil != pwd && pwd.length >= 6;
}

- (IBAction)doneButtonClick:(id)sender {
    
    //TODO: implement proper email & password validation
    
    if (![self isValidEmail:self.email.text]) {
        [self showErrorMessageWithTitle:@"Validation Error" body:@"Please provide valid e-mail"];
        return;
    }
    
    if (![self isValidPassword:self.password.text]) {
        [self showErrorMessageWithTitle:@"Validation Error" body:@"Incorrect password length (>= 6 characters)"];
        return;
    }
        
    NSDictionary *loginParams = @{
                                  kLoginParamUsername : self.email.text,
                                  kLoginParamPassword : self.password.text,
                                  kLoginParamSocialNetworkType : @(STLoginTypeNative)
                                  };
    
    [sender startActivityIndicator];
    self.view.userInteractionEnabled = NO;
    
    if (self.isSignUp) {
        [STService createUserWithLoginParams:loginParams
                                     success:^(NSDictionary *content) {
                                         
                                         [sender stopActivityIndicator];
                                         self.view.userInteractionEnabled = YES;
                                         
                                         NSNumber *profileExists = content[@"profile_exists"];
                                         
                                         if (!profileExists || NO == [profileExists boolValue]) {
                                             NSLog(@"New user has been successfully created");
                                             
                                             STProfile *profile = [[STProfile alloc] init];
                                             
                                             [self performSegueWithIdentifier:@"CreateProfileSegue" sender:profile];
                                         }
                                         else {
                                             NSLog(@"Logging in existing user");
                                             [self performSegueWithIdentifier:@"showSearchAfterSignIn" sender:nil];
                                         }
                                         
                                     }
                                     failure:^(STServiceErrorCode status, NSString *msg) {
                                         [sender stopActivityIndicator];
                                         self.view.userInteractionEnabled = YES;
                                         
                                         switch (status) {
                                             case STServiceErrorCodeUsernamePasswordNotCorrect:
                                             {
                                                 NSLog(@"Login Error: %@", msg);
                                                 [self showErrorMessageWithTitle:@"Login Error" body:@"Email or password is not correct."];
                                                 break;
                                             }
                                                 
                                             case STServiceErrorCodeUserExists:
                                             {
                                                 NSLog(@"User with this email already has an account. Please login using Social Network, which had been used to create this account.");
                                                 [self showErrorMessageWithTitle:@"Login Error" body:@"This email has already been taken. Please choose another one."];
                                                 break;
                                             }
                                             default:
                                             {
                                                 NSLog(@"Error creating a user: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
                                                 [self showGenericErrorWithTitle:@"Login Error" status:status message:msg];
                                                 break;
                                             }
                                         }
                                     }];
    }
    else {
        [STService signInUserWithLoginParams:loginParams
                                     success:^(NSDictionary *content) {
                                         [sender stopActivityIndicator];
                                         self.view.userInteractionEnabled = YES;
                                         
                                         NSLog(@"Logging in existing user");
                                         [self performSegueWithIdentifier:@"showSearchAfterSignIn" sender:nil];
                                     }
                                     failure:^(STServiceErrorCode status, NSString *msg) {
                                         
                                         //This should never happen, as we have the same check at one step back.
                                         //Adding this code just as a safety mechanism
                                         [sender stopActivityIndicator];
                                         self.view.userInteractionEnabled = YES;
                                         
                                         switch (status) {
                                            case STServiceErrorCodeProfileDoesntExist:
                                            {
                                                STProfile *profile = [[STProfile alloc] init];
                                                
                                                [self performSegueWithIdentifier:@"CreateProfileSegue" sender:profile];
                                                 break;
                                            }
                                                 
                                            case STServiceErrorCodeUsernamePasswordNotCorrect:
                                            {
                                                NSLog(@"Login Error: %@", msg);
                                                [self showErrorMessageWithTitle:@"Login Error" body:@"Email or password is not correct."];
                                                break;
                                            }
                                                 
                                            case STServiceErrorCodeUserExists:
                                             {
                                                 NSLog(@"User with this email already has an account. Please login using Social Network, which had been used to create this account.");
                                                 [self showErrorMessageWithTitle:@"Login Error" body:@"This email has already been taken. Please choose another one."];
                                                 break;
                                             }
                                                 
                                            default:
                                            {
                                                NSLog(@"Error Logging user in: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
                                                
                                                [self showGenericErrorWithTitle:@"Login Error" status:status message:msg];
                                                
                                                break;
                                            }
                                                 
                                         }
                                         
                                         
                                     }];
    }
}

- (void)clearText:(id)sender
{
    if ([sender superview] == self.email)
        self.email.text = @"";
    else if ([sender superview] == self.password)
        self.password.text = @"";
}

- (void)setClearButtonImageForTextField:(UITextField *)tf
{
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];//[tf valueForKey:@"_clearButton"];
    UIImage *clearButtonImage = [UIImage imageNamed:@"delete"];
    clearButton.frame = CGRectMake(0, 0, clearButtonImage.size.width, clearButtonImage.size.height);
    [clearButton setBackgroundImage:clearButtonImage forState:UIControlStateNormal];
    [clearButton setBackgroundImage:clearButtonImage forState:UIControlStateHighlighted];
    
    [clearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    
    tf.rightViewMode = UITextFieldViewModeWhileEditing;
    [tf setRightView:clearButton];
}


//-(BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    return YES;
//}

 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"CreateProfileSegue"]) {
        STProfile *profile = sender;
        STCreateProfileViewController *createProfileVC = segue.destinationViewController;
        createProfileVC.isCreateProfile = YES;
        createProfileVC.profile = profile;
    }

}
 


@end
