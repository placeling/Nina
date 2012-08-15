//
//  Suggestion.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-15.
//
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "NinaHelper.h"
#import "Place.h"

@interface Suggestion : NSObject{
    NSDate *createdAt;
    NSString *message;
    User *sender;
    User *receiver;
    Place *place;
}

+(RKObjectMapping*)getObjectMapping;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) User *receiver;
@property (nonatomic, retain) Place *place;

-(NSString*)getUserId;

@end
