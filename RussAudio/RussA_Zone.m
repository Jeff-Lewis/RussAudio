//
//  RussA_Zone.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_Zone.h"
//#import "DDTTYLogger.h"

@implementation RussA_Zone


- (id)init
{
    return [self initWithID:1 forController:1];
    
}

- (id)initWithID:(long)thisZoneID forController:(long)initControllerID
{
    
    self = [super init];
    if (self != nil) {
        _zoneControllerID = (long)malloc(sizeof(long));
        _zoneID = (long)malloc(sizeof(long));
        
        _zoneControllerID = initControllerID;
        _zoneID = thisZoneID;
        _zoneKeys = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"name",@"",@"currentSource",@"",@"volume",@"",@"bass",@"",@"treble",@"",@"balance",@"",@"loudness",@"",@"turnOnVolume",@"",@"doNotDisturb",@"",@"partyMode",@"",@"status",@"",@"mute",@"",@"sharedSource",@"",@"lastError",@"",@"page",@"",nil];
        
    }
    return self;
}

- (void)updateValueForKey:(NSString *)myKey withValue:(NSString *)myValue
{
        [_zoneKeys setObject:myValue forKey:myKey];

}
/*
    Get the stored value for a given key
 */
- (NSString *)getValueForKey:(NSString *)myKey
{
    return [_zoneKeys valueForKey:myKey];
}

/*
    Get a the value of a given key from the system.  The response will call updateValueForKey:withValue
    to update cached value.  Note that a notification will also cause an update to the cached vlaues.
 */
- (NSData *)getCurrentValueforKey:(NSString *)myKey forZone:(long)zoneID
{
    
    NSString* myCommand = [NSString stringWithFormat:@"GET C[%ld].Z[%ld].%@\r",_zoneControllerID,zoneID,myKey];
    
    return[myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
}
- (NSData *)setCurrentValueforKey:(NSString *)myKey withValue:(NSString *)myValue forZone:(long)zoneID
{
    NSString* myCommand;
    NSArray *zoneSetKeys = @[@"bass", @"treble", @"balance", @"loudness", @"turnOnVolume"];
    NSUInteger zonsSetKey = [zoneSetKeys indexOfObject:myKey];
    switch (zonsSetKey) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        {
            myCommand = [NSString stringWithFormat:@"SET C[%ld].Z[%ld].%@=\"%@\"\r",_zoneControllerID,zoneID,myKey, myValue];
            break;
        }
            
        default:
        {
            //EVENT C[c].Z[z]!<event id> <data1> <data2>
            myCommand = [NSString stringWithFormat:@"EVENT C[%ld].Z[%ld]!%@ %@\r",_zoneControllerID,zoneID,myKey,myValue];
            break;
        }
    }

    
    return [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
}
@end

