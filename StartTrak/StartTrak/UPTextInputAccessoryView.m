//
//  UPTextInputAccessoryView.m

#import "UPTextInputAccessoryView.h"
#import "STStyleUtility.h"

@implementation UPTextInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
    self = [super initWithFrame:frame];
    if (self) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
        self.barStyle = UIBarStyleDefault;
        self.tintColor = [UIColor blackColor];
        self.items = @[flexibleSpace, doneButtonItem];
    }
    return self;
}
@end
