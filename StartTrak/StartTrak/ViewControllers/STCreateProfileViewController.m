//
//  STCreateProfileViewController.m
//  StartTrak
//
//  Created by mdv on 29/01/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STCreateProfileViewController.h"
#import "STStyleUtility.h"
#import "STProfileItem.h"
#import "STAvatarCell.h"
#import "STProfileRowCell.h"
#import "STButtonCell.h"
#import "STSelectableOptionsViewController.h"
#import "STDictionariesManager.h"
#import "STSearchViewController.h"
#import "STProfile.h"
#import "STService.h"
#import "VDAlertMessageView.h"
#import "UIButton+Activity.h"

#define kDefaultContentTopInset 65.0

@interface STCreateProfileViewController ()<UITableViewDataSource, UITableViewDelegate, STSelectableOptionsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *profileItems; //model

@property (strong, nonatomic) STProfileItem *selectedProfileItem;

@end

@implementation STCreateProfileViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.isCreateProfile ? @"Create Profile" : @"Review Profile";
    
    [iPhoneDeviceBlockExecutor executeDeviceBlocks:^{
        self.tableView.contentInset = UIEdgeInsetsMake(kDefaultContentTopInset-10.0, 0.0, 0.0, 0.0);
    } iphone5Block:^{
        self.tableView.contentInset = UIEdgeInsetsMake(kDefaultContentTopInset, 0.0, 0.0, 0.0);
    } iphone6Block:^{
        self.tableView.contentInset = UIEdgeInsetsMake(kDefaultContentTopInset+40, 0.0, 0.0, 0.0);
    } iphone6PlusBlock:^{
        self.tableView.contentInset = UIEdgeInsetsMake(kDefaultContentTopInset+60, 0.0, 0.0, 0.0);
    }];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(kDefaultContentTopInset, 0.0, 0.0, 0.0);
    
    self.profileItems = [self.profile buildProfileItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonClick:(id)sender {
//    NSLog(@"button click sender=%@", sender);
    for (STProfileItem *pi in self.profileItems) {
        NSLog(@"pi=%@", [pi description]);
    }
    

    NSDictionary *profileToSend = [[STProfile new] profileToSendFromProfileItems:self.profileItems];
    
    NSLog(@"profileToSend=%@", [profileToSend description]);
    
    if (profileToSend && profileToSend.count > 0) {
        
        [sender startActivityIndicator];
        self.view.userInteractionEnabled = NO;
        
        if (self.isCreateProfile) {
            [STService createUserProfile:profileToSend
                                 success:^(NSDictionary *content) {
                                     NSLog(@"Success updating profile. content=%@", [content description]);
                                     
                                     [sender stopActivityIndicator];
                                     self.view.userInteractionEnabled = YES;
                                     
//                                     [self performSegueWithIdentifier:@"showSearchSegue" sender:nil];
                                     [self performSegueWithIdentifier:@"showStartTracking" sender:nil];
                                 }
                                 failure:^(STServiceErrorCode status, NSString *msg) {
                                     [sender stopActivityIndicator];
                                     self.view.userInteractionEnabled = YES;
                                     
                                     NSLog(@"Error creating profile: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
                                     
                                     [VDAlertMessageView showMessageWithTitle:@"Error Creating Profile"
                                                                         body:[NSString stringWithFormat:@"%@ (error code=%@)", msg, @(status)]
                                                                cancelHandler:nil
                                                                    doneTitle:nil
                                                                  doneHandler:nil];
                                 }];
        }
        else {
            [STService updateUserProfile:profileToSend
                                 success:^(NSDictionary *content) {
                                     NSLog(@"Success updating profile. content=%@", [content description]);
                                     
                                     [sender stopActivityIndicator];
                                     self.view.userInteractionEnabled = YES;
                                     
//                                     [self performSegueWithIdentifier:@"showSearchSegue" sender:nil];
                                     [self performSegueWithIdentifier:@"showStartTracking" sender:nil];
                                 }
                                 failure:^(STServiceErrorCode status, NSString *msg) {
                                     
                                     [sender stopActivityIndicator];
                                     self.view.userInteractionEnabled = YES;
                                     
                                     NSLog(@"Error updating profile: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
                                     
                                     [VDAlertMessageView showMessageWithTitle:@"Error Updating Profile"
                                                                         body:[NSString stringWithFormat:@"%@ (error code=%@)", msg, @(status)]
                                                                cancelHandler:nil
                                                                    doneTitle:nil
                                                                  doneHandler:nil];
                                 }];
        }
    }
    else {
        [VDAlertMessageView showMessageWithTitle:@"Warning"
                                            body:@"Please fill in at least one field in the profile"
                                   cancelHandler:nil
                                       doneTitle:nil
                                     doneHandler:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profileItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STProfileItem *item = self.profileItems[indexPath.row];
    
    if (nil != item) {
        return item.rowHeight;
    }
    
    return kDefaultRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STProfileItem *item = self.profileItems[indexPath.row];
    
    if (nil != item) {
        switch (item.itemType) {
                
            case STProfileItemTypeAvatar:
            {
                STAvatarCell *avatarCell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell"];
                [avatarCell setAvatarURL:item.value];
                
                return avatarCell;
            }
            
            case STProfileItemTypeRowEditable:
            case STProfileItemTypeRowSelectable:
            {
                STProfileRowCell *rowCell = [tableView dequeueReusableCellWithIdentifier:@"rowCell"];
                rowCell.tableView = self.tableView;
                [rowCell setItem:item];
                
                return rowCell;
            }
                
            case STProfileItemTypeButton:
            {
                STButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
                
                return buttonCell;
            }
                
            default:
                break;
        }
    }
    assert(false);
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STProfileItem *item = self.profileItems[indexPath.row];
    
    if (nil != item && STProfileItemTypeRowSelectable == item.itemType) {
        NSLog(@"Did select item = %@", [item description]);
        self.selectedProfileItem = item;
        
        [self performSegueWithIdentifier:@"showOptionsSegue" sender:item];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showOptionsSegue"]) {
        
        STProfileItem *selectedProfileItem = sender;
        
        STSelectableOptionsViewController *optionsVC = segue.destinationViewController;
        optionsVC.optionTitle = selectedProfileItem.label;
        optionsVC.cameFromProfile = YES;
        
        NSDictionary *selectedOption = selectedProfileItem.valueDict;
        
        NSArray *entryOptions = [[STDictionariesManager sharedInstance] entriesForKey:selectedProfileItem.entryKey];
        
        //sort entry options
        
        
        NSDictionary *noneOption = @{kEntryKeyId : @"", kEntryKeyName : @"None"};
        
        NSMutableArray *allOptions = [NSMutableArray arrayWithObject:noneOption];
        [allOptions addObjectsFromArray:entryOptions];
        
        optionsVC.allOptions = allOptions;
        optionsVC.selectedOption = selectedOption ?: noneOption;
        optionsVC.delegate = self;
    }
}

#pragma mark - STSelectableOptionsViewControllerDelegate
- (void)selectableOptionsViewController:(STSelectableOptionsViewController *)vc didSelectOption:(NSDictionary *)option
{
    
    NSLog(@"selectableOptionsViewController didSelectOption = %@", [option description]);
    
    //Update model for selected option
    if (self.selectedProfileItem && nil != option) {
        
        NSString *entryID = option[kEntryKeyId];
        
        if (entryID && entryID.length > 0) {
            self.selectedProfileItem.value = option[kEntryKeyId];
            self.selectedProfileItem.valueDict = option;
        }
        else {
            self.selectedProfileItem.value = nil;
            self.selectedProfileItem.valueDict = nil;
        }
        
        [self.tableView reloadData];
        
    }
}

@end
