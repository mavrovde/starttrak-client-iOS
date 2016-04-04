//
//  STSearchResultsViewController.m
//  StartTrak
//
//  Created by mdv on 07/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STSearchResultsViewController.h"
#import "STStyleUtility.h"
#import "STSearchResultsCell.h"
#import "STProfile.h"
#import "STService.h"
#import "UIButton+Activity.h"
#import "VDAlertMessageView.h"

@interface STSearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *meetButton;

@end

@implementation STSearchResultsViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    UIColor *navBarColor = [UIColor colorWithRGBA:0x312F32FF];
    
    [STStyleUtility setNavigationBar:self.navigationController.navigationBar textColorToColor:navBarColor barStyle:UIBarStyleDefault];
    
    [STStyleUtility setupBackButtonOfColor:navBarColor
                          inNavigationItem:self.navigationItem
                                    target:self
                                    action:@selector(back:)];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Matches";
    
    self.meetButton.titleLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.meetButton.titleLabel.textColor = [UIColor blackColor];
    
//Note: Uncomment this line to test UI
//    self.searchResults = [self buildTestSearchResults];

}

- (NSArray *)buildTestSearchResults
{
    //Suzanne Herzig
    STProfile *p1 = [STProfile new];
    p1.first_name = @"Suzanne";
    p1.last_name = @"Herzig";
    p1.position_id = @"255";
    p1.company_name = @"E-redtexon";
    p1.city_name = @"Sacramento";
    p1.soc_network_type = @"2";
    p1.profile_pic = @"https://www.dropbox.com/s/qgo7wrm8ue8lw6r/suzanne_herzig_144.png?dl=1";
    
    //Bernie Santiago
    STProfile *p2 = [STProfile new];
    p2.first_name = @"Bernie";
    p2.last_name = @"Santiago";
    p2.position_id = @"256";
    p2.company_name = @"Siliconcore";
    p2.city_name = @"Sacramento";
    p2.soc_network_type = @"1";
    p2.profile_pic = @"https://www.dropbox.com/s/xjvb2al9c032c2t/bernie_santiago_144.png?dl=1";
    
    //Morris Siple
    STProfile *p3 = [STProfile new];
    p3.first_name = @"Morris";
    p3.last_name = @"Siple";
    p3.position_id = @"257";
    p3.company_name = @"unokix";
    p3.city_name = @"San Jose";
    p3.soc_network_type = @"3";
    p3.profile_pic = @"https://www.dropbox.com/s/7bnuv0bs2em58n3/morris_simple_144.png?dl=1";
    
    //Unknown
    STProfile *p4 = [STProfile new];
    
    
    return @[p1, p2, p3, p4];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)meetButtonClick:(id)sender {
    NSMutableArray *people = [NSMutableArray array];
    
    [sender startActivityIndicator];
    self.view.userInteractionEnabled = NO;
    
    for (STProfile *p in self.searchResults) {
        if (p.selected) {
            [people addObject:p.user_id];
        }
    }
    
    if (people.count > 0) {
        NSLog(@"Sending invitations to: %@", [people componentsJoinedByString:@", "]);
        
        [STService sendInvitationsToUsersWithParams:@{@"user_ids": people} success:^(id content) {
            NSLog(@"Invitations successfully sent");
            
            [sender stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            
            [VDAlertMessageView showMessageWithTitle:@"Success"
                                                body:@"Invitations have been successfully sent"
                                       cancelHandler:nil
                                           doneTitle:nil
                                         doneHandler:nil];
            
        } failure:^(STServiceErrorCode status, NSString *msg) {
            [sender stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            
            NSLog(@"Error in Search: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
            
            [VDAlertMessageView showMessageWithTitle:@"Send Invitation Error"
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
                                            body:@"Please tap on a card to send invitation to people you want to meet"
                                   cancelHandler:nil
                                       doneTitle:nil
                                     doneHandler:nil];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 121.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STProfile *profile = self.searchResults[indexPath.row];
    
    STSearchResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultsCell"];
    
    [cell setProfile:profile];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    STProfile *profile = self.searchResults[indexPath.row];
    
    if (profile) {
        profile.selected = !profile.selected;
        
        NSInteger index = [self.searchResults indexOfObject:profile];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
        [tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
