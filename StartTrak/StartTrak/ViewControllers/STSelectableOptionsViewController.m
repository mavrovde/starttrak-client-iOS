//
//  STSelectableOptionsViewController.m
//  StartTrak
//
//  Created by mdv on 05/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSelectableOptionsViewController.h"
#import "STSelectableOptionCell.h"
#import "STStyleUtility.h"

@interface STSelectableOptionsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@end

@implementation STSelectableOptionsViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = [NSString stringWithFormat:@"Choose Your %@", self.optionTitle];
    self.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:24.0];
    
    NSString *bgImageName = self.cameFromProfile ? @"options-background" : @"options-search-bg";
    
    self.bgImage.image = [UIImage imageNamed:bgImageName];
    
    self.doneButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.doneButton.titleLabel.textColor = [UIColor blackColor];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    //TODO: hide back button
}

- (IBAction)doneButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectableOptionsViewController:didSelectOption:)]) {
        [self.delegate selectableOptionsViewController:self didSelectOption:self.selectedOption];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STSelectableOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
    
    NSDictionary *cellOption = self.allOptions[indexPath.row];
    
    if (nil != cellOption) {
        [cell setIsSelectedOption:(cellOption == self.selectedOption)];
        [cell setOption:cellOption];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellOption = self.allOptions[indexPath.row];
    STSelectableOptionCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    NSIndexPath *prevSelectedIndexPath = nil;
    
    if (cellOption != self.selectedOption) {

        if (nil != self.selectedOption) {
            NSInteger prevSelectedOptionIndex = [self.allOptions indexOfObject:self.selectedOption];
            prevSelectedIndexPath = [NSIndexPath indexPathForRow:prevSelectedOptionIndex inSection:0];
            STSelectableOptionCell *prevSelectedCell = [tableView cellForRowAtIndexPath:prevSelectedIndexPath];
            
            if (prevSelectedCell) {
                prevSelectedCell.isSelectedOption = NO;
            }
        }
    
        if (currentCell) {
            currentCell.isSelectedOption = YES;
        }
        
        self.selectedOption = cellOption;
        
        [tableView reloadRowsAtIndexPaths:(prevSelectedIndexPath ? @[prevSelectedIndexPath, indexPath] : @[indexPath]) withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
