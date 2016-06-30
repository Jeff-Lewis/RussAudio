//
//  RussA_System.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_System.h"
//#import "DDTTYLogger.h"


@interface RussA_System ()
@property   NSMutableDictionary * systemValues;

@end


@implementation RussA_System

NSData *systemRequest;

-(id)init
{
    self = [super init];
    if (self != nil) {
        _systemValues =[[NSMutableDictionary alloc]init];
        _systemValues = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"language",@"",@"status",@"", nil];
    }
    return self;
    
}

- (void)updateKey:(NSString *)myKey withValue:(NSString *)myValue
{
    [_systemValues setObject:myValue forKey:myKey];
}

- (NSString *)getValueForKey:(NSString *)myKey
{
    return [_systemValues valueForKey:myKey];
}


- (NSData *)setKey:(NSString *)myKey withValue:(NSString *)myValue
{
    NSString* myCommand = [NSString stringWithFormat:@"SET System.%@=\"%@\"\r",myKey,myValue];
    systemRequest = [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
    return systemRequest;
    
}
- (NSData *)getCurrentValueForKey:(NSString *)myKey
{
    NSString* myCommand = [NSString stringWithFormat:@"GET System.%@\r",myKey];
    systemRequest = [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
    return systemRequest;
    
}


@end
