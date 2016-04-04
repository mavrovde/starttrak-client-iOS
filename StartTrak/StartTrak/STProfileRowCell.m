//
//  STProfileRowCell.m
//  StartTrak
//
//  Created by mdv on 04/02/16.
//  Copyright © 2016 StartTrak Inc. All rights reserved.
//

#import "STProfileRowCell.h"
#import "STDictionariesManager.h"
#import "STStyleUtility.h"

#define kRowLabelEmptyBottomContraint 16.0
#define kRowValueEmptyBottomContraint 10.0

#define kRowLabelFilledBottomContraint 40.0
#define kRowValueFilledBottomContraint 9.0


@interface STProfileRowCell ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL tapOnCellReceived;
@property (weak, nonatomic) IBOutlet UIView *grView;
@property (assign, nonatomic) UIEdgeInsets defaultContentInsets;

@end

@implementation STProfileRowCell

- (void)awakeFromNib {
    // Initialization code
    
    self.rowValue.delegate = self;
    self.rowValue.tintColor = [STStyleUtility defaultAppTextColor];
    self.rowValue.returnKeyType = UIReturnKeyDone;
    self.rowValue.adjustsFontSizeToFitWidth = YES;

    //Install Tap Gesture Recognizer
    [self installGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItem:(STProfileItem *)item
{
    _item = item;
    
    self.defaultContentInsets = self.tableView.contentInset;
    
    if (STProfileItemTypeRowSelectable != item.itemType) {
        
    }
    
    self.rowLabel.text = [item.label uppercaseString];
    
    if (STProfileItemTypeRowEditable == item.itemType) {
        self.rowValue.text = item.value;
        self.dropDownArrow.hidden = YES;
    }
    else if (STProfileItemTypeRowSelectable == item.itemType) {
        self.rowValue.userInteractionEnabled = NO; //prevent text field to receive touches
        
        self.dropDownArrow.hidden = NO;
        
        [self.grView removeFromSuperview];
        
        NSString *value = nil == item.valueDict ? @"None" : item.valueDict[kEntryKeyName];
        
        self.rowValue.text = value;
    }
    else {
        assert(false);
    }
    
    //adjust constraints depending of if value is set or not
    [self positionFieldsAnimated:NO willEdit:NO];
    
}

- (void)positionFieldsAnimated:(BOOL)animated willEdit:(BOOL)willEdit
{
    __weak typeof(self) weakSelf = self;
    
    __block void (^animationBlock)() = [^{
        if (willEdit || (nil != weakSelf.rowValue.text && weakSelf.rowValue.text.length > 0)) {
            weakSelf.rowLabelBottomConstraint.constant = kRowLabelFilledBottomContraint;
            weakSelf.rowValueBottomConstraint.constant = kRowValueFilledBottomContraint;
            
            weakSelf.rowLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:14.0];
            weakSelf.rowValue.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:20.0];
        }
        else {
            weakSelf.rowLabelBottomConstraint.constant = kRowLabelEmptyBottomContraint;
            weakSelf.rowValueBottomConstraint.constant = kRowValueEmptyBottomContraint;
            weakSelf.rowLabel.font = [UIFont fontWithName:[STStyleUtility defaultAppFont] size:16.0];
        }
        
        [weakSelf layoutIfNeeded];
    } copy];
    
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            animationBlock();
        }];
    }
    else {
        animationBlock();
    }
}

- (void)installGestureRecognizer
{
//    if (self.item.itemType == STProfileItemTypeRowEditable) {
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnCell:)];
        tapgr.delegate = self;
//    tapgr.cancelsTouchesInView = NO;
        [self.grView addGestureRecognizer:tapgr];
//    }
}

- (void)didTapOnCell:(UITapGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateEnded) {
        NSLog(@"didTapOnCell");
        
        self.grView.hidden = YES;
        self.tapOnCellReceived = YES;
        
        [self.rowValue becomeFirstResponder];
//        [self.tableView scrollRectToVisible:self.frame animated:YES];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self positionFieldsAnimated:YES willEdit:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (STProfileItemTypeRowEditable == self.item.itemType) {
        self.item.value = textField.text;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self positionFieldsAnimated:YES willEdit:NO];

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.grView.hidden = NO;
    
    if (STProfileItemTypeRowEditable == self.item.itemType) {
        self.item.value = textField.text;
    }
    
    [self.rowValue resignFirstResponder];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return STProfileItemTypeRowEditable == self.item.itemType;// || STProfileItemTypeRowSelectable == self.item.itemType;
}

#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    //Prevent other cells from observing this notification
    if (!self.grView.hidden)
        return;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    
    //take content offset into account
    cellRect = CGRectOffset(cellRect, 0, -self.tableView.contentOffset.y);
    
    //	NSLog(@"cellRect=%@", NSStringFromCGRect(cellRect));
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGSize bounds = [UIScreen mainScreen].bounds.size;
    
    CGFloat yDiff = cellRect.origin.y - (bounds.height - keyboardSize.height);
//    NSLog(@"yDiff = %.2f", yDiff);
    
    //if at least a part of current cell is hidden behind the keyboard
    CGRect convertedRect = [self.tableView convertRect:self.frame toView:self.tableView];
    
    if (yDiff > -convertedRect.size.height)//*2.0)
    {
        CGFloat bottomInset = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? keyboardSize.height : keyboardSize.width;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, bottomInset + 20.0, 0.0);
        
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //Prevent other cells from observing this notification
    if (!self.tapOnCellReceived)
        return;
    
    self.tapOnCellReceived = NO;
//    NSLog(@"keyboardWillHide");
    
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = self.defaultContentInsets;
        self.tableView.scrollIndicatorInsets = self.defaultContentInsets;
    }];
}


@end;
