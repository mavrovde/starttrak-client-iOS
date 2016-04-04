//
//  STSearchViewController.m
//  StartTrak
//
//  Created by mdv on 29/01/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSearchViewController.h"
#import "STSearchResultsViewController.h"
#import "STSearchItem.h"
#import "STSearchCell.h"
#import "STStyleUtility.h"
#import "STSelectableOptionsViewController.h"
#import "STProfile.h"
#import "STDictionariesManager.h"
#import "STService.h"
#import "UIButton+Activity.h"
#import "VDAlertMessageView.h"

@interface STSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, STSelectableOptionsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (strong, nonatomic) STProfile *profile;
@property (strong, nonatomic) NSArray *searchItems;
@property (strong, nonatomic) STSearchItem *selectedSearchItem;

@end

@implementation STSearchViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"I Would Like to Meet";
    
    self.searchField.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.searchField.textColor = [UIColor colorWithRGBA:0x282222FF];
    self.searchField.tintColor = self.searchField.textColor;
    self.searchField.returnKeyType = UIReturnKeyDone;
    
    self.searchButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.searchButton.titleLabel.textColor = [UIColor blackColor];
    
    //Logout button
    self.logoutButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFontBold] size:20.0];
    
    //Model
    self.profile = [[STProfile alloc] init];
    self.searchItems = [self.profile buildSearchItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [STStyleUtility setNavigationBar:self.navigationController.navigationBar
                    textColorToColor:[STStyleUtility defaultAppTextColor]
                            barStyle:UIBarStyleBlack];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    //TODO: show confirmation dialog
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)searchButtonClick:(id)sender {
//    [self performSegueWithIdentifier:@"showSearchResultsSegue" sender:nil];
    
    NSDictionary *searchParams = [self.profile searchParamsFromSearchItems:self.searchItems];
    
    NSMutableDictionary *mutableSearchParams = searchParams.count > 0 ? [NSMutableDictionary dictionaryWithDictionary:searchParams] : [NSMutableDictionary dictionary];
    
    if (self.searchField.text.length > 0) {
        mutableSearchParams[@"search_text"] = self.searchField.text;
    }
    
    
    NSLog(@"searchParams=%@", mutableSearchParams);

    if (mutableSearchParams && mutableSearchParams.count > 0) {
        
        [self.searchButton startActivityIndicator];
        self.view.userInteractionEnabled = NO;
        
        [STService searchProfilesWithParams:mutableSearchParams
                                    success:^(id content) {
                                        if ([content isKindOfClass:[NSArray class]]) {
                                            NSMutableArray *profiles = [NSMutableArray array];
                                            
                                            for (NSDictionary *p in content) {
                                                STProfile *pr = [STProfile new];
                                                [pr loadFromDictionary:p];
                                                
                                                [profiles addObject:pr];
                                            }
                                            
                                            [self.searchButton stopActivityIndicator];
                                            self.view.userInteractionEnabled = YES;
                                            
                                            if (profiles.count > 0) {
                                                NSLog(@"Found: %@", [profiles description]);
                                                
                                                [self performSegueWithIdentifier:@"showSearchResultsSegue" sender:profiles];
                                            }
                                            else {
                                                NSLog(@"No results");
                                                
                                                [VDAlertMessageView showMessageWithTitle:@"Oops"
                                                                                    body:@"Search yielded no results. Please try with another search options"
                                                                           cancelHandler:nil
                                                                               doneTitle:nil
                                                                             doneHandler:nil];
                                            }
                                        }
                                        else {
                                            [VDAlertMessageView showMessageWithTitle:@"Error"
                                                                                body:@"Invalid type of search results"
                                                                       cancelHandler:nil
                                                                           doneTitle:nil
                                                                         doneHandler:nil];
                                        }
                                    }
                                    failure:^(STServiceErrorCode status, NSString *msg) {
                                        NSLog(@"Error in Search: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
                                        
                                        [self.searchButton stopActivityIndicator];
                                        self.view.userInteractionEnabled = YES;
                                        
                                        [VDAlertMessageView showMessageWithTitle:@"Search Error"
                                                                            body:[NSString stringWithFormat:@"%@ (error code=%@)", msg, @(status)]
                                                                   cancelHandler:nil
                                                                       doneTitle:nil
                                                                     doneHandler:nil];
                                    }];
    }
    else {
        
        [sender stopActivityIndicator];
        self.view.userInteractionEnabled = YES;

        [VDAlertMessageView showMessageWithTitle:@"Warning"
                                            body:@"Please specify either search text or select at least one search criteria in the list"
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
    return self.searchItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STSearchItem *item = self.searchItems[indexPath.row];
    
    if (nil != item) {
        return item.rowHeight;
    }
    
    return kDefaultRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STSearchItem *item = self.searchItems[indexPath.row];
    
    STSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    [cell setSearchItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STSearchItem *item = self.searchItems[indexPath.row];
    
    if (nil != item) {
        NSLog(@"Did select item = %@", [item description]);
        self.selectedSearchItem = item;
        
        [self performSegueWithIdentifier:@"showSearchOptionsSegue" sender:item];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showSearchResultsSegue"]) {
        STSearchResultsViewController *vc = segue.destinationViewController;
        vc.searchResults = sender;
        
    }
    else if ([segue.identifier isEqualToString:@"showSearchOptionsSegue"]) {
        NSLog(@"segue=%@", segue.identifier);
        
        STProfileItem *selectedProfileItem = sender;
        
        STSelectableOptionsViewController *optionsVC = segue.destinationViewController;
        optionsVC.optionTitle = selectedProfileItem.label;
        optionsVC.cameFromProfile = NO;
        
        NSDictionary *selectedOption = selectedProfileItem.valueDict;
        
        NSArray *entryOptions = [[STDictionariesManager sharedInstance] entriesForKey:selectedProfileItem.entryKey];
        
        NSDictionary *noneOption = @{kEntryKeyId : @"", kEntryKeyName : @"All"};
        
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
    if (self.selectedSearchItem && nil != option) {
        
        NSString *entryID = option[kEntryKeyId];
        
        if (entryID && entryID.length > 0) {
            self.selectedSearchItem.value = option[kEntryKeyId];
            self.selectedSearchItem.valueDict = option;
        }
        else {
            self.selectedSearchItem.value = nil;
            self.selectedSearchItem.valueDict = nil;
        }
        
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
