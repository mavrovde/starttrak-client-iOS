//
//  STEditMessageViewController.m
//  StartTrak
//
//  Created by Denis on 10/04/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STEditMessageViewController.h"
#import "STStyleUtility.h"
#import "UPTextInputAccessoryView.h"

@interface STEditMessageViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation STEditMessageViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    UIColor *navBarColor = [UIColor colorWithRGBA:0xFFFFFFFF];
    
    [STStyleUtility setNavigationBar:self.navigationController.navigationBar textColorToColor:navBarColor barStyle:UIBarStyleDefault];
    
    [STStyleUtility setupBackButtonOfColor:navBarColor
                          inNavigationItem:self.navigationItem
                                    target:self
                                    action:@selector(back:)];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Edit message";
    
    self.textView.clipsToBounds = YES;
    self.textView.layer.cornerRadius = 10.0;
    
    self.textView.text = self.templateText;
    self.textView.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
    self.textView.textColor = [UIColor colorWithRGBA:0x1B1A1Bff];
    self.textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    UPTextInputAccessoryView *inputAccessoryView = [[UPTextInputAccessoryView alloc]
                                                    initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kInputAccessoryViewHeight)
                                                    target:self
                                                    action:@selector(doneButtonClick:)];
    
    self.textView.inputAccessoryView = inputAccessoryView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonClick:(id)sender
{
    [self.textView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)sendButtonClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editMessageViewController:didFinishWithMessage:)]) {
        [self.delegate editMessageViewController:self didFinishWithMessage:self.textView.text];
    }
}

//-(BOOL)textViewShouldEndEditing:(UITextView *)textView

@end
