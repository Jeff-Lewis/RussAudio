//
//  RussA_Source.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_Source.h"
//#import "DDTTYLogger.h"


@interface RussA_Source ()

@property   NSMutableDictionary * sourceValues;

@end


@implementation RussA_Source

- (id)init
{
    return [self initWithID:1];
}


- (id)initWithID:(long)thisSourceID
{
    if (self == nil) {
        self = [super init];
    }
    if (self != nil) {
        _sourceID = thisSourceID;
        _sourceValues =[[NSMutableDictionary alloc]init];
        _sourceValues = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"name",@"",@"type",@"",@"composerName",@"",@"ipAddress",@"",@"channel",@"",@"coverArtURL",@"",@"channelName",@"",@"genre",@"",@"artistName",@"",@"albumName",@"",@"playlistName",@"",@"songName",@"",@"programServiceName",@"",@"radioText",@"",@"radioText2",@"",@"radioText3",@"",@"radioText4",@"",@"shuffleMode",@"",@"repeatMode",@"",@"mode",@"",@"Support.MM.longList",@"", nil];
    }
    return self;
}

- (void)updateValueForKey:(NSString *)myKey withValue:(NSString *)myValue
{
    
    [_sourceValues setObject:myValue forKey:myKey];
}

- (NSString *)getValueForKey:(NSString *)myKey
{
    return [_sourceValues valueForKey:myKey];
}
- (NSData *)getCurrentValueForKey:(NSString *)myKey forSource:(long)sourceID
{
    
    NSString* myCommand = [NSString stringWithFormat:@"GET S[%ld].%@\r",sourceID,myKey];
    
    return [myCommand dataUsingEncoding:NSUTF8StringEncoding];
}

@end
