//
//  NPSPopupWindow.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-22.
//
//

#import <Foundation/Foundation.h>

#import "AFPickerView.h"

@interface NPSPopupWindow : NSObject<AFPickerViewDataSource, AFPickerViewDelegate> {
    UIView* bgView;
    UIView* bigPanelView;
    
    AFPickerView *defaultPickerView;
}

+(void)showWindowInsideView:(UIView*)view;

@end
