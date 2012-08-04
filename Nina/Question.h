//
//  Question.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "NinaHelper.h"
#import "Answer.h"

@interface Question : NSObject{
    NSString *questionId;
    NSString *title;
    NSString *description;
    NSString *cityName;
    NSString *countryCode;    
    
    NSNumber *lat;
    NSNumber *lng;
    
    NSNumber *score;
    
    NSDate *createdAt;
    
    User *user;
    
    NSMutableArray *answers;
}

@property (nonatomic, retain) NSString *questionId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *cityName;
@property (nonatomic, retain) NSString *countryCode;    

@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lng;

@property (nonatomic, retain) NSNumber *score;

@property (nonatomic, retain) NSDate *createdAt;

@property (nonatomic, retain) User *user;

@property (nonatomic, retain) NSMutableArray *answers;


+(RKObjectMapping*)getObjectMapping;



@end
