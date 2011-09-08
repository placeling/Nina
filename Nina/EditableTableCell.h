//
//  EditableTableCell.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableTableCell : UITableViewCell{
    UITextField *_textField;
}

@property (nonatomic, retain) UITextField *textField;


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end
