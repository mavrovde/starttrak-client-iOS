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
#import "STEditMessageViewController.h"

#define kSelectTitle @"Select all"
#define kDeselectTitle @"Deselect"

@interface STSearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate, STEditMessageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *meetButton;
@property (strong, nonatomic) UIButton *selectDeselectButton;
@property (strong, nonatomic) NSMutableArray *userIds;

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
    
    //Select/deselect button
    
    UIFont *selectButtonFont = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:16.0];
    
    NSDictionary *selectButtonAttrs = @{
                                        NSFontAttributeName : selectButtonFont,
                                        NSForegroundColorAttributeName : [UIColor whiteColor]
                                        };
    
    CGFloat maxButtonWidth = MAX([kSelectTitle sizeWithAttributes:selectButtonAttrs].width, [kDeselectTitle sizeWithAttributes:selectButtonAttrs].width) + 30.0;
    
    self.selectDeselectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, maxButtonWidth, 30)];
    self.selectDeselectButton.clipsToBounds = YES;
    self.selectDeselectButton.layer.cornerRadius = 6.0;
    [self.selectDeselectButton addTarget:self action:@selector(selectAllClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectDeselectButton setBackgroundColor:[UIColor colorWithRGBA:0x585352ff]];
    self.selectDeselectButton.titleLabel.textColor = [UIColor whiteColor];
    self.selectDeselectButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    [self setTitleForSelectButton:kSelectTitle];
    
    UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithCustomView:self.selectDeselectButton];
    
    self.navigationItem.rightBarButtonItem = selectButton;
}

- (void)selectAllClick:(id)sender
{
    BOOL shouldSelectAll = [[self.selectDeselectButton titleForState:UIControlStateNormal] isEqualToString:kSelectTitle];
    
    for (STProfile *p in self.searchResults) {
        p.selected = shouldSelectAll;
    }
    
    NSString *newTitle = shouldSelectAll ? kDeselectTitle : kSelectTitle;
    
    [self setTitleForSelectButton:newTitle];
    
    [self.tableView reloadData];
}

- (void)setTitleForSelectButton:(NSString *)title
{
    [self.selectDeselectButton setTitle:title forState:UIControlStateNormal];
    [self.selectDeselectButton setTitle:title forState:UIControlStateHighlighted];
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
    self.userIds = [NSMutableArray array];
    
    [sender startActivityIndicator];
    self.view.userInteractionEnabled = NO;
    
    for (STProfile *p in self.searchResults) {
        if (p.selected) {
            [self.userIds addObject:p.user_id];
        }
    }
    
    if (self.userIds.count > 0) {
        NSLog(@"Sending invitations to: %@", [self.userIds componentsJoinedByString:@", "]);
        
        [STService sendInvitationsToUsersWithParams:@{@"user_ids": self.userIds, @"send" : @"false"} success:^(id content) {
            NSLog(@"Invitations successfully sent. Content=%@", content);
            
            [sender stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            
//            [VDAlertMessageView showMessageWithTitle:@"Success"
//                                                body:@"Invitations have been successfully sent"
//                                       cancelHandler:nil
//                                           doneTitle:nil
//                                         doneHandler:nil];
            
            [self performSegueWithIdentifier:@"editMessageSegue" sender:content];
            
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editMessageSegue"]) {
        STEditMessageViewController *vc = segue.destinationViewController;
        
        vc.delegate = self;
        vc.templateText = sender;
    }
}

- (void)editMessageViewController:(STEditMessageViewController *)vc didFinishWithMessage:(NSString *)message
{
    if (nil == message || 0 == message.length) {
        [VDAlertMessageView showMessageWithTitle:@"Error" body:@"Message shouldn't be empty" cancelHandler:nil doneTitle:@"OK" doneHandler:nil];
        return;
    }
    
    if (self.userIds.count > 0) {
        NSLog(@"Sending invitations to: %@", [self.userIds componentsJoinedByString:@", "]);
        
        [self.meetButton startActivityIndicator];
        self.view.userInteractionEnabled = NO;
        
        [STService sendInvitationsToUsersWithParams:@{@"user_ids": self.userIds, @"send" : @"true", @"message" : message} success:^(id content) {
            NSLog(@"Invitations successfully sent. Content=%@", content);
            
            [self.meetButton stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            
            [vc.navigationController popViewControllerAnimated:YES];
            
            [VDAlertMessageView showMessageWithTitle:@"Success"
                                                body:@"Invitations have been successfully sent"
                                       cancelHandler:nil
                                           doneTitle:nil
                                         doneHandler:nil];
            
            
        } failure:^(STServiceErrorCode status, NSString *msg) {
            [self.meetButton stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            
            NSLog(@"Error in Search: status=%@, msg=%@", [STService serviceErrorCodeStringFromEnum:status], msg);
            
            [VDAlertMessageView showMessageWithTitle:@"Send Invitation Error"
                                                body:[NSString stringWithFormat:@"%@ (error code=%@)", msg, @(status)]
                                       cancelHandler:nil
                                           doneTitle:nil
                                         doneHandler:nil];
            
        }];
    }
}

@end
