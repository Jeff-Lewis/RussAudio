//
//  RussA_Source.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 sourceID will range from 1 -> 12
 */


typedef NS_ENUM(NSInteger, RussA_sourceMode) {
	RUSSA_SourceMode_OFF = 0,
	RussA_SourceMode_ON = 1,
	RUSSA_SourceMode_SONG = 4,
	RUSSA_SourceMode_ALBUM = 8,
};



@interface RussA_Source : NSObject

@property   long sourceID;

- (id)initWithID:(long)initSourceID;
- (void)updateValueForKey:(NSString *)myKey withValue:(NSString *)myValue;
- (NSString *)getValueForKey:(NSString *)myKey;
- (NSData *)getCurrentValueForKey:(NSString *)myKey forSource:(long)sourceID;

@end

