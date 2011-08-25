#import <UIKit/UIKit.h>

@protocol EditableTableViewCellDelegate;


@interface EditableTableViewCell : UITableViewCell<UITextViewDelegate> {
}

@property(nonatomic, assign) id<NSObject, EditableTableViewCellDelegate> delegate;
@property(nonatomic, readonly) UITextView *textView;
@property(nonatomic, retain) NSMutableString *text;

+ (UITextView *)dummyTextView;
+ (CGFloat)heightForText:(NSString *)text;

- (CGFloat)suggestedHeight;

@end


@protocol EditableTableViewCellDelegate

- (void)editableTableViewCellDidBeginEditing:(EditableTableViewCell *)editableTableViewCell;
- (void)editableTableViewCellDidEndEditing:(EditableTableViewCell *)editableTableViewCell;
- (void)editableTableViewCell:(EditableTableViewCell *)editableTableViewCell heightChangedTo:(CGFloat)newHeight;

@end