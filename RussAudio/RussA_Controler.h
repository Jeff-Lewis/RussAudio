//
//  RussA_Controler.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RussA_FirstViewController.h"


#import "GCDAsyncSocket.h"

typedef NS_ENUM(long, Russ_tags) {
    
    RUSSA_System_INIT = 0,                  //0000:0000
    RUSSA_System_GET = 8,                   //0000:1001
    RUSSA_System_SET = 9,                   //0000:1010
    
    RUSSA_Controller_GET = 16,              //0001:0001
    RUSSA_Controller_SET = 17,              //0001:0010
    RUSSA_Controller_EVENT = 18,            //0001:0011
    
    RUSSA_Source_GET = 33,                  //0010:0001
    RUSSA_Source_SET = 34,                  //0010:0010
    RUSSA_Source_EVENT = 35,                //0010:0011

    RUSSA_Zone_GET = 65,                    //0100:0001
    RUSSA_Zone_SET = 66,                    //0100:0010
    RUSSA_Zone_EVENT = 67,                  //0100:0011
    
    RUSSA_Notifications =129,               //1000:0001
};

typedef NS_ENUM(BOOL, Russ_BOOL) {
    RUSSA_OFF = 0,
    RUSSA_ON = 1,
};






//@class GCDAsyncSocket;
@class RussA_FirstViewController;


@interface RussA_Controler : NSObject
{

@private
	GCDAsyncSocket *asyncSocket;
	
}

@property   NSString            *host;
@property   uint16_t            port;
@property   NSTimeInterval      timeOut;
@property   UIAlertView         *alert;
@property   NSString            *controllerIPAddress;
@property   NSString            *controllerMacAddress;
@property   NSString            *controllerType;
@property   long                 controllerID;
@property   NSMutableArray      *sources;
@property   NSMutableArray      *zones;
@property   long                 zoneSourceCount;
@property   NSMutableArray      *zoneSleepTimer;
@property   RussA_FirstViewController   *zoneViewController;



- (id)initWithID:(long)initControllerID;
- (void) initStreamSocket;
- (void) tearStreamSocket;

- (void) sendMyData: (NSData *)data tag:(long)tag;
- (void) readMyData: (NSData *)data tag:(long)tag;

//Controller Calls
- (void)updateController:(NSString *) myKey withValue:(NSString *)myValue;
- (NSString *)getIPAddress;
- (NSString *)getMacAddress;
- (NSString *)getType;

//Zone Calls
- (void)setZoneWatch:(long)zone state:(BOOL)state;
- (void)setZone:(long)zoneID forKey:(NSString *)myKey withValue:(NSString *)myValue;
- (NSString *)getValueForZone:(long)zoneID forKey:(NSString *)myKey;

//Source Calls
- (void)setSourceWatch:(long)source state:(BOOL)state;
- (void)getCurrentSourceValue:(long)sourceID forKey:(NSString *)myKey;
- (NSString *)getValueforSource:(long)sourceID forKey:(NSString *)myKey;

//System Calls
- (void)setSystemWatch:(BOOL)state;
- (void)setSystemKey:(NSString *)myKey withValue:(NSString *)myValue;
- (void)updateSystemKey:(NSString *)myKey withValue:(NSString *)myValue;
- (void)getCurrentValueForSystemKey:(NSString *)myKey;
- (void)getValueForSystemKey:(NSString *)myKey;
- (NSString *)getSystemLanguage;
- (NSString *)getSystemStatus;

- (int) getIntFromChar:(char)theChar;
- (NSNumber *)getNumberfromString:(NSString *) theString;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void) sleepTimer:(NSTimeInterval)timer forZone:(long)aZone;


@end
