//
//  EditableTableCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditableTableCell.h"

@implementation EditableTableCell
@synthesize textField=_textField;


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier]) {
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
        
        textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textColor = [UIColor blackColor];
        textField.backgroundColor = [UIColor whiteColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.textAlignment = UITextAlignmentLeft;
        
        self.textField = textField;
        
        [self addSubview:self.textField];
        [textField release];
    }
    return self;
}

- (void)dealloc {
    [_textField release];
    [super dealloc];
}


#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
