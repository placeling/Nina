//
//  NinaHelper.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//single place to define debugging or not -iMack
#ifndef DEBUG 
//#define DEBUG 
#endif

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif





#define PROXIMITY 15

// S3
#define S3_SECRET_ACCESS_KEY @"/C8mDvHUlkpCXuHlK5Ic+Xnl8+rfMrrPwYWVI9C9"
#define S3_ACCESS_KEY @"1YQZ31XPEY4RZYBYV2R2"
#define BUCKET_NAME @"placeling-debug"

// Image Sizes
#define THUMBNAIL 69
#define DISPLAY_HEIGHT 500
#define DISPLAY_WIDTH 700
// Autocomplete
#define GOOGLE_AUTOCOMPLETE_BASE_URL @"https://maps.googleapis.com/maps/api/place/autocomplete/json?"
#define GOOGLE_AUTOCOMPLETE_TRAIL_URL @"&language=en&types=establishment&sensor=true&key=AIzaSyDijI8o1BMxEzTJQHPft_gSJopl7llqWXw"
#define AUTOCOMPLETE_RADIUS 10000 // Radius used for autocomplete

// CLLocation Manager
#define STOP_LOCATION_DELTA 30 // Distance at which location updating stops

// Autocomplete constant
#define AUTOCOMPLETE @"autocomplete"

// Pre-load spinner
#define SPINNER_SIZE 25

// Dimensions for PlaceDetail rows
#define topOffset 5 // offset between top of cell and profile pic
#define profilePicHeight 35
#define notesOffset 5 // offset between a profile pic and any notes
#define dataHorizontalIndent 35 // all data is 35 pixels from edge
#define notesWidth 245 // 300 - 20 for accessory - 35 indent
#define fullNotesWidth 290
#define fullNotesIndent 5
#define photoOffset 8 // offset above/below/left of any photo
#define photoHeight 69
#define tagHeight 21
#define bottomOffset 5 // gap between bottom of tags and bottom of cell
#define usernameIndent 5 // gap between profile pic and username
#define usernameOffset 7 // gap between top of profile pic and start of username

#define numPhotosPerLine 3
#define ownerNumPhotosPerLine 4
#define fullPhotoOffset 5

#define starButtonOffset 5 // delta between top of profile pic and start of starButton
#define starButtonHeight 25
#define starButtonIndent 5
#define flagButtonHeight 25
#define minStarFlagGap 10 // minimum vertical distance between the star and the flag button  
#define flagIndent 5

#define starTag 1
#define profilePicTag 2
#define usernameTag 3
#define flagTag 4
#define notesTag 5
#define tagsTag 6
#define photoTag 100
#define placeNameTag 7
#define dateTag 8

// Dimensions for LocationRecord info (Description of Place)
#define addRemoveIndent 5
#define addRemoveOffset 5
#define addRemoveHeight 25

#define infoIndent 35
#define nameOffset 8
#define nameOffsetSmall 5
#define fullWidth 260
#define shortWidth 235
#define nameHeight 20
#define lockIndent 10
#define lockWidth 20
#define lockOffset 8

#define catsAndTagsOffset 8
#define addressHeight 14           
#define mapOffset 5
#define mapHeight 85
#define mapFooterOffset 5

#define editButtonIndent 5
#define editButtonOffset 10
#define editButtonWidth 25
#define editButtonHeight 40

// Compare with all users
#define compareAll @"all"

#define standardRowHeight 44



#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManagerManager.h"
#import "StyleHelper.h"
#import <RestKit/RestKit.h>

@interface NinaHelper : NSObject 

+(void) handleBadRequest:(ASIHTTPRequest *)request sender:(UIViewController*)sender;
+(void) handleBadRKRequest:(RKResponse *)response sender:(UIViewController*)sender;

+(void) handleCoreLocationError:(NSError*)error;
+(void) signRequest:(ASIHTTPRequest *)request; 

+(void) clearActiveRequests:(NSInteger) range;

+(NSString *)dateDiff:(NSString *)origStamp;

+(NSString*) getHostname;
+(BOOL) isProductionRun;
+(NSString*) getUsername;

+(void) setAccessToken:(NSString*)accessToken;
+(void) setAccessTokenSecret:(NSString*)accessTokenSecret;
+(void) setUsername:(NSString*)username;

+(NSString*) getAccessToken;
+(NSString*) getAccessTokenSecret;

+(NSString*) getConsumerKey;
+(NSString*) getConsumerSecret;

+(void) clearCredentials;

+(NSString*) metersToLocalizedDistance:(float)m;
+(NSString*) encodeForUrl:(NSString*)string;

+(NSString*) getFacebookAppId;

@end
