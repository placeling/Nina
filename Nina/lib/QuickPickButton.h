//
//  QuickPickButton.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickPickButton : UIButton{
    
    NSString *category;
}


@property(nonatomic, retain) NSString *category;

@end
