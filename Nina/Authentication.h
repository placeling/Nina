//
//  Authentication.h
//  Nina
//
//  Created by Ian MacKinnon on 12-02-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface Authentication : NSObject{
    NSString *provider;
    NSString *uid;
    NSString *token;
    NSString *secret;
    NSDate *expiry;
}

@property (nonatomic, retain) NSString *provider; 
@property (nonatomic, retain) NSString *uid; 
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSDate *expiry; 

+(RKObjectMapping*)getObjectMapping;
@end



