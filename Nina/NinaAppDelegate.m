//
//  NinaAppDelegate.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManagerManager.h"
#import "FlurryAnalytics.h"
#import "NinaHelper.h"
#import <RestKit/RestKit.h>
#import "User.h"
#import "Place.h"
#import "Perspective.h"
//#import "DBManagedObjectCache.h"

@implementation NinaAppDelegate


@synthesize window=_window;
@synthesize facebook;

@synthesize navigationController=_navigationController;

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //Restkit initialization  
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:[NinaHelper getHostname]];
    [[objectManager client] setOAuth1AccessToken:[NinaHelper getAccessToken]];
    [[objectManager client] setOAuth1AccessTokenSecret:[NinaHelper getAccessTokenSecret]];
    [[objectManager client] setOAuth1ConsumerKey:[NinaHelper getConsumerKey]];
    [[objectManager client] setOAuth1ConsumerSecret:[NinaHelper getConsumerSecret]];
    //[objectManager client] set
    objectManager.client.authenticationType = RKRequestAuthenticationTypeOAuth1;  
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    //[[RKClient sharedClient].cache invalidateAll];
    NSError *error = nil;
    NSString *filePath = [[NSHomeDirectory() 
                            stringByAppendingPathComponent:@"Documents"] 
                           stringByAppendingPathComponent:@"NinaRestCache.sqlite"];        
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    //RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"NinaRestCache.sqlite"];
    //objectManager.objectStore = objectStore;
    
    //objectManager.objectStore.managedObjectCache = [[DBManagedObjectCache new] autorelease];
    
    //set cache policy for restkit
    [[objectManager client] setCachePolicy:RKRequestCachePolicyEtag | RKRequestCachePolicyTimeout|RKRequestCachePolicyLoadIfOffline ];
    [[objectManager client] setCacheTimeout:60*60]; //hour
    
    
    [objectManager.mappingProvider setMapping:[User getObjectMapping] forKeyPath:@"users"];
    [objectManager.mappingProvider setMapping:[User getObjectMapping] forKeyPath:@"followers"];
    [objectManager.mappingProvider setMapping:[User getObjectMapping] forKeyPath:@"following"];
    [objectManager.mappingProvider setMapping:[User getObjectMapping] forKeyPath:@"suggested"];
    
    [objectManager.mappingProvider setMapping:[Place getObjectMapping] forKeyPath:@"suggested_places"];
    [objectManager.mappingProvider setMapping:[Place getObjectMapping] forKeyPath:@"places"];
    [objectManager.mappingProvider setMapping:[Place getObjectMapping] forKeyPath:@"place"];
    
    [objectManager.mappingProvider setMapping:[Perspective getObjectMapping] forKeyPath:@"perspectives"];
    [objectManager.mappingProvider setMapping:[Perspective getObjectMapping] forKeyPath:@"referring_perspectives"];
    
    DLog(@"RKClient singleton : %@", [RKClient sharedClient]);
    
    if ([NinaHelper isProductionRun]){
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        [FlurryAnalytics startSession:@"TF6YH8QMRQDXBXR9APF9"];
    }
    
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Disabled" message:@"Location services are disabled on your device " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
        [servicesDisabledAlert release];
    } else {
        CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
        [manager setDesiredAccuracy:kCLLocationAccuracyBest];
        [manager startUpdatingLocation];
    }
    
    facebook = [[Facebook alloc] initWithAppId:[NinaHelper getFacebookAppId] andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    [FlurryAnalytics logAllPageViews:self.navigationController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [FlurryAnalytics logEvent:@"REJECTED_PERMISSIONS"];
} 


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc{
    [_window release];
    [_navigationController release];
    [facebook release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
