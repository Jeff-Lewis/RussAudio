//
//  RussA_Zone.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 GET c[1].z[1].currentSources
 E InvalidKey (error near: GET c[1].z[1].currentSources^)
 
  GET c[1].z[1].currentSource # Note space before the GET
 E Command not found: +illegal-characters

 */

typedef NS_ENUM(NSInteger, RussA_zoneState) {
	RussA_zone_OFF = 0,
	RussA_zone_ON = 1,
    //RussA_zone_SLAVE = 8,
    RussA_zone_SLAVE = 4,
	RussA_zone_MASTER = 8,
};



@interface RussA_Zone : NSObject
@property   long                 zoneControllerID;
@property   long                 zoneID;
@property   NSMutableDictionary * zoneKeys;

- (id)initWithID:(long)initZoneID forController:(long)initControllerID;
- (void)updateValueForKey:(NSString *)myKey withValue:(NSString *)myValue;
- (NSString *)getValueForKey:(NSString *)myKey;
- (NSData *)getCurrentValueforKey:(NSString *)myKey forZone:(long)zoneID;
- (NSData *)setCurrentValueforKey:(NSString *)myKey withValue:(NSString *)myValue forZone:(long)zoneID;

/*
 //  These methods are automatically setup based @property getter for @property zoneID is zoneID for setter is setZoneID
 - (long)getZoneID;
- (void)setZoneID:(long)newZoneID;
*/

@end
