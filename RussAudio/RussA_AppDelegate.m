//
//  RussA_AppDelegate.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/15/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_AppDelegate.h"
#import "RussA_FirstViewController.h"
#import "RussA_radioZoneViewController.h"
#import "RussA_Zone.h"


@implementation RussA_AppDelegate

NSMutableArray  *zoneNamesArray;
NSMutableArray  *zonePowerStateArray;
//NSString        *sonosIPAddress = @"83.86.70.22";
NSString        *sonosIPAddress = @"192.168.176.35";




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    DDLogError(@"%@:>>",THIS_METHOD);
    
    DDLogError(@"%@:>> application:didFinishLaunchingWithOptions>>",THIS_METHOD);
    
    
    char defaultID = 1;
    
    // Register the preference defaults early.
    
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *preferenceObjects = @[@"192.168.176.35",[NSNumber numberWithInt:9621]];
    NSArray *preferenceKeys = @[@"host_pref",@"port_pref"];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:preferenceObjects forKeys:preferenceKeys];
    
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    RussA_FirstViewController *rootViewController = (RussA_FirstViewController *)navController.topViewController;
    
    _russController = [[RussA_Controler alloc] initWithID:defaultID];
    
    
    
    
    [_russController setZoneViewController:rootViewController];
    
    
    // Initialize Zone table data early so they are available to populate before FirstView
    zoneNamesArray = [[NSMutableArray alloc] init];
    zonePowerStateArray = [[NSMutableArray alloc] init];
    
    
    [rootViewController setZoneNames:zoneNamesArray];
    [rootViewController setZonePowerStates:zonePowerStateArray];
    [rootViewController setRussController:_russController];
    [rootViewController initZoneTables];
    
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    //[_russController tearStreamSocket];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DDLogError(@"%@:>>",THIS_METHOD);

    //[_russController initStreamSocket];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDLogError(@"%@:>>",THIS_METHOD);

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogError(@"%@:>>",THIS_METHOD);
    [_russController tearStreamSocket];
    
}

// required for state restoration
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return NO;
}

// required for state restoration
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return NO;
}


@end
