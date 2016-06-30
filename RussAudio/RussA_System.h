//
//  RussA_System.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RussA_systemState) {
	RussA_system_OFF = 0,
	RussA_system_ON = 1,
	RussA_system_SLAVE = 4,
	RussA_system_MASTER = 8,
};



@interface RussA_System : NSObject

- (void)updateKey:(NSString *)myKey withValue:(NSString *)myValue;
- (NSString *)getValueForKey:(NSString *)myKey;
- (NSData *)setKey:(NSString *)myKey withValue:(NSString *)myValue;
- (NSData *)getCurrentValueForKey:(NSString *)myKey;

@end
