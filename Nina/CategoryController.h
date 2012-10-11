//
//  CategoryController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryControllerDelegate
-(void)updateCategory:(NSString *)category;
@end


@interface CategoryController : UITableViewController<CategoryControllerDelegate>{
    id<CategoryControllerDelegate> delegate;
    UIViewController *addNewPlaceController;
    NSDictionary *categories;
    NSArray *sortedKeys;
    NSString *selectedCategory;
}

@property(nonatomic,retain) NSDictionary *categories;
@property(nonatomic,assign) id<CategoryControllerDelegate> delegate;
@property(nonatomic,assign) UIViewController *addNewPlaceController;
@property(nonatomic,retain) NSArray *sortedKeys;
@property(nonatomic,retain) NSString *selectedCategory;

-(id)initWithCategory:(NSDictionary*)category;

@end
