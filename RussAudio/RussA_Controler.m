//
//  RussA_Controler.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/16/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

/*
 We will use the tag field to make it simpler to decode the responses we get back from the controller
 */

#import "RussA_Controler.h"
#import "RussA_System.h"
#import "RussA_Zone.h"
#import "RussA_Source.h"

//#import "XMLReader.h"

//#import "DDLog.h"
//#import "DDTTYLogger.h"

@interface RussA_Controler ()


@end



@implementation RussA_Controler

RussA_Source        *source;
RussA_Zone          *zone;
RussA_System        *mySystem;
int                 reconnectCount = 3;
id                  appDelegate;

//Russound Controller Connectivity information
NSString        *terminatorString;
bool            controllerIsInitialized;
bool            zonesIsInitialized;
NSData          *russRequest;
NSData          *russResponse;
NSString        *currentSystemStatus;
NSString        *currentSystemLanguage;
NSData          *dataTerminator;
Russ_tags       myTag;
NSMutableDictionary *sleepDictionary;


#define receiveTerminator @"\r\n"
#define sendTerminator @"\r"



//GCDAsyncSocket      *asyncSocket;//TCP Async Socket to use

- (id)init
{
    /*
     Default init will initialize with a Controller ID of 1
     if more than one controller you need to initialize with initWithID:
     */
    

    self = [super init];
    if (self != nil) {
        long defaultControllerID = 1;
        return [self initWithID:defaultControllerID];
    }else
    {
        DDLogError(@"Something went terribly wrong");
        
        EXIT_FAILURE;
    }
    return self;
}

- (id)initWithID:(long)thisControllerID
{
    
    // Setup logging framework
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    if (self == nil) {
        self = [super init];
        DDLogInfo(@"%@:>> Created controller ",THIS_METHOD);
    }
    
    if (self != nil) {
        DDLogInfo(@"%@:>> Creating controller with ID = %ld",THIS_METHOD,thisControllerID);
        
        // Read the saved preference or use predefined defaults
        DDLogInfo(@"%@:>> Reading Defaults",THIS_METHOD);
        _host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host_pref"];
        _port = [[NSUserDefaults standardUserDefaults] integerForKey:@"port_pref"];
        
        DDLogInfo(@"%@:>>  Default Host = %@ and Port = %d",THIS_METHOD,_host, _port);
        
        _timeOut    = 5;
        
        dataTerminator  = [receiveTerminator dataUsingEncoding:NSUTF8StringEncoding];
        
        controllerIsInitialized = NO;
        zonesIsInitialized      = NO;
        _controllerID           = thisControllerID;
        
        _controllerIPAddress    = [[NSString alloc] init];
        _controllerMacAddress   = [[NSString alloc] init];
        _controllerType         = [[NSString alloc] init];
        _sources                = [[NSMutableArray alloc] init];
        _zones                  = [[NSMutableArray alloc] init];
        _zoneSleepTimer         = [[NSMutableArray alloc] init];
        
        
        //Creeate Empty zone and source to fix index and avoid doing index+1 everytime...
        source = [[RussA_Source alloc]initWithID:0];
        [_sources addObject:source];
        zone = [[RussA_Zone alloc]initWithID:0 forController:0];
        [_zones addObject:zone];
        
        // Create a new socket to send commands with
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
        
        // Initiate connection for this controller
        [self initStreamSocket];
        
    }
    
    return self;
}

#pragma mark - KVO


- (void) initControllerAndSystem
{
    // Read controller data or set it to default...
    [self getCurrentValueForKey:@"ipAddress"];
    [self getCurrentValueForKey:@"macAddress"];
    [self getCurrentValueForKey:@"type"];
    
    //Initialize System components
    mySystem = [[RussA_System alloc] init];
    [self setSystemWatch:RUSSA_ON];
    [self getCurrentSystemValueForKey:@"language"];
    [self getCurrentSystemValueForKey:@"status"];
    
    
}
- (void) initControllerZonesAndSources
{
    //  Initialize Source and Zone Arrays.  Best is to get Controller and see how many
    //  sources and Zones it has.  Then initialize array to fit
    //
    long thisSourceID;
    long thisZoneID;
    
    
    //Max Available sources Default to the max for now...
    _zoneSourceCount = 12;
    
    if ([[self getType]isEqual:@"MCA-C5"]) {
        _zoneSourceCount = 8;
    }
    else if ([[self getType] isEqual: @"MCA-C3"])
    {
        _zoneSourceCount = 6;
    }
    
    
    
    DDLogInfo(@"%@:>>  Size of _zoneSleepTimer = %lu and _zoneSourceCount = %ld",THIS_METHOD,(unsigned long)[_zoneSleepTimer count],_zoneSourceCount);
    // There is no Zone 0, so add object there for now...
    sleepDictionary = [[NSMutableDictionary alloc] init];
    [sleepDictionary setObject:@NO forKey:@"timerEnabled"];
    [sleepDictionary setObject:@"" forKey:@"sleepTimer"];
    
    [_zoneSleepTimer addObject:sleepDictionary];
    
    
    for (int device = 1; device <= _zoneSourceCount; device++)
    {
        thisSourceID = device;
        thisZoneID = device;
        
        source = [[RussA_Source alloc]initWithID:thisSourceID];
        [_sources addObject:source];
        
        zone = [[RussA_Zone alloc]initWithID:thisZoneID forController:_controllerID];
        [_zones addObject:zone];
        
        //Disable Sleep time for each zone
        sleepDictionary = [[NSMutableDictionary alloc] init];
        [sleepDictionary setObject:@NO forKey:@"timerEnabled"];
        [sleepDictionary setObject:@"" forKey:@"sleepTimer"];
        
        [_zoneSleepTimer addObject:sleepDictionary];
        
        
    }
    
    [self setZoneAndSourceWatches];
    
    DDLogInfo(@"%@:>> %lu Zones initiaized", THIS_METHOD,(unsigned long)([_zones count] -1));
    DDLogInfo(@"%@:>> %lu Sources initiaized", THIS_METHOD,(unsigned long)([_sources count] - 1));
    
}


- (void) setZoneAndSourceWatches
{
    //  Initialize Source and Zone Arrays.  Best is to get Controller and see how many
    //  sources and Zones it has.  Then initialize array to fit
    //
    
    long thisSourceID;
    long thisZoneID;
    
    for (int device = 1; device <= _zoneSourceCount; device++)
    {
        thisSourceID = device;
        thisZoneID = device;
        
        [self setSourceWatch:thisSourceID state:RUSSA_ON];
        [self setZoneWatch:thisZoneID state:RUSSA_ON];
    }
    
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (_alert) {
        [_alert dismissWithClickedButtonIndex:1 animated:YES];
    }
    
    DDLogError(@"%@:>>%p didConnectToHost:%@ port:%hu", THIS_METHOD,sock, host, port);
    //prime the Socket to clear the gunk so to say...
    [self readMyData:russResponse tag:RUSSA_Notifications];
    
    // if _zoneSourceCount != 0 means we are probably reconnecting after being in background
    // Enable watches again to keep up with notiofications.
    if (_zoneSourceCount != 0) {
        [self setZoneAndSourceWatches];
    }
    else
    {
        DDLogError(@"%@: initControllerAndSystem",THIS_METHOD);
        [self initControllerAndSystem];
        
    }
    //Dismiss the connecting Dialog and start updating dialog
    [_zoneViewController updateViewData];
    
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    DDLogError(@"%@:>>%p", THIS_METHOD,sock);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //DDLogError(@"%@:>>%p Tag:%ld", THIS_METHOD,sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString * dataToProcess = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //DDLogError(@"%@:>>%p Tag:%ld", THIS_METHOD,sock, tag);
    [self processMyData:dataToProcess withTag:tag];
    
    // Read Notifications as they are unsolicited
    // Note thuis might result in a race condition when I send Data system send notification
    // at the same time.  I might get a TAG mismatch.  Catch this in processMyData:datatToprocess:withTag
    [self readMyData:russResponse tag:(long)RUSSA_Notifications];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogError(@"%@:>>%p withError: %@.  Reconnect attempts left = %d", THIS_METHOD,sock, err,reconnectCount);
    
    if (reconnectCount != 0)
    {
        reconnectCount--;
        //sleep(5);
        [self initStreamSocket];
    }
    else
    {
        // Human readable error is between quotes " "
        NSString *networkError = [[NSString stringWithFormat:@"%@",err] componentsSeparatedByString:@"\""][1];
        if (_alert) {
            [_alert dismissWithClickedButtonIndex:1 animated:YES];
        }
        
        _alert = [[UIAlertView alloc] initWithTitle:@"Did not Connect!"
                                            message:[NSString stringWithFormat:@"Please check IP Address. \n Error was \"%@\"",networkError]
                                           delegate:self
                                  cancelButtonTitle:@"Update"
                                  otherButtonTitles:@"Quit", nil];
        
        [_alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [_alert textFieldAtIndex:0];
        textField.text = [NSString stringWithFormat:@"%@",_host];
        [_alert show];
        [[_alert textFieldAtIndex:0] resignFirstResponder];
    }
}


- (void) initStreamSocket
{
    NSError *error = nil;
    DDLogInfo(@"%@:>> Connecting to \"%@\" on port %hu...", THIS_METHOD,_host,_port);
    
    if (_alert) {
        [_alert dismissWithClickedButtonIndex:1 animated:NO];
    }
    [self showAlertWithTitle:@"Conecting"
                     message:[NSString stringWithFormat:@" Connecting to: \n%@ on port %hu\nRetry Count (%d)",_host,_port,reconnectCount]];
    
    if (![asyncSocket connectToHost:_host onPort:_port withTimeout:_timeOut error:&error])
    {
        DDLogError(@"%@:>> Error connecting to: \"%@\" on port %hu %@", THIS_METHOD,_host,_port,error);
    }
    
}

- (void) tearStreamSocket

{
    
    [asyncSocket disconnect];
    DDLogError(@"%@:>> Disconnecting from Host:%@ port:%hu", THIS_METHOD,_host, _port);
}


- (void) sendMyData: (NSData *)data tag:(long)tag
{
    //DDLogError(@"sendMyData to Host:%@ port:%hu", host, port);
    [asyncSocket writeData:data withTimeout:-1 tag:tag];
    
}

- (void) readMyData: (NSData *)data tag:(long)tag
{
    //DDLogError(@"readMyData: from Host:%@ port:%hu", host, port);
    [asyncSocket readDataToData:dataTerminator withTimeout:-1 tag:tag];
    
    return;
}

- (void) processMyData: (NSString *)data withTag:(long)tag
{
    /*
     For RIO commands that are processed successfully, a response is sent with this format:
     S <optional data>
     For RIO commands that result in failure, a response is sent with this format:
     E <error message>
     For asyncronous RIO responses, or „notifications‟, a response is sent with this format:
     N <key>=”<value>”
     */
    
    //DDLogError(@"%@:>>(%li): \"%s\"",THIS_METHOD,tag,[data cStringUsingEncoding:NSUTF8StringEncoding]);
    
    long thisZone;
    long thisSource;
    
    if (tag == RUSSA_System_INIT)
    {
        DDLogInfo(@"%@:>> !!Received Tag:(%li) \nData = %@ (Still initializing...)!!",THIS_METHOD,tag,data);
        return;
    }
    
    if (([data length] == 3))
    {
        
        if (zonesIsInitialized == YES) {
            [_zoneViewController updateViewData];
            DDLogInfo(@"%@:>> Empty Success for (zonesIsInitialized == YES)",THIS_METHOD);
        }
    }
    else
        
    {
        
        NSString *mytempKey = [data componentsSeparatedByString:@"="][0];
        NSString *myValue = [data componentsSeparatedByString:@"="][1];
        //remove quotes from te value returned
        myValue = [myValue stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myValue length])];
        
        // Strip off trailing \r\n in Russound responses
        myValue = [myValue stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        int response = [data cStringUsingEncoding:NSUTF8StringEncoding][0];
        
        switch (response) {
            case 'S':
            {
                if (tag == RUSSA_Controller_GET || tag == RUSSA_Controller_SET || tag == RUSSA_Notifications)
                {
                    //DDLogError(@"%@:>>(%li):Process Notification case 'C'",THIS_METHOD,tag);
                    
                    //Handle Controller specific responses
                    if ([data cStringUsingEncoding:NSUTF8StringEncoding][7] != 'Z') {
                        
                        //  Do not need this Controller ID.  At this point we only handle one Controller.
                        //char thisController = [[mytempKey componentsSeparatedByString:@"."][0] cStringUsingEncoding:NSUTF8StringEncoding][4]; //S C[1]
                        NSString *myKey = [mytempKey componentsSeparatedByString:@"."][1];
                        
                        [self updateController:myKey withValue:myValue];
                        
                    }
                    else
                    {
                        //Handle Zone Specific responses
                        thisZone = [[mytempKey componentsSeparatedByString:@"."][1] cStringUsingEncoding:NSUTF8StringEncoding][2];  //Z[1]
                        thisZone = [self getIntFromChar:thisZone];
                        NSString *myKey = [mytempKey componentsSeparatedByString:@"."][2];
                        [[_zones objectAtIndex:thisZone] updateValueForKey:myKey withValue:myValue ];
                        // Update the table view of Zones with power state now that we have received the last Zone attreibute notification.
                        if (thisZone == _zoneSourceCount && ([myKey  isEqual: @"lastError"])){
                            //DDLogInfo(@"%@:>>  (1) Zone(%ld) %@ changed to myValue = %@",THIS_METHOD,thisZone,myKey, myValue);
                            [_zoneViewController updateViewData];
                            zonesIsInitialized = YES;
                        }
                        // If we are done updating all zone notifications and there is a status change
                        if ([myKey  isEqual: @"status"] && (zonesIsInitialized == YES)){
                            //DDLogInfo(@"%@:>>  (2) Zone(%ld) %@ changed to myValue = %@",THIS_METHOD,thisZone,myKey, myValue);
                            [_zoneViewController updateViewData];
                        }
                        else if (zonesIsInitialized == YES){
                            //DDLogInfo(@"%@:>>  (3) Zone(%ld) %@ changed to myValue = %@",THIS_METHOD,thisZone,myKey, myValue);
                            [_zoneViewController updateViewData];
                        }
                    }
                    break;
                }
                
                else if (tag == RUSSA_Zone_GET ||tag == RUSSA_Zone_SET) {
                    switch ([data cStringUsingEncoding:NSUTF8StringEncoding][7]) {
                        case 'Z':
                        {
                            //DDLogError(@"processMyData->\"Controller SUCCESS\"");
                            thisZone = [[mytempKey componentsSeparatedByString:@"."][1] cStringUsingEncoding:NSUTF8StringEncoding][2];  //Z[1]
                            thisZone = [self getIntFromChar:thisZone];
                            NSString *myKey = [mytempKey componentsSeparatedByString:@"."][2];
                            
                            [[_zones objectAtIndex:thisZone ] updateValueForKey:myKey withValue:myValue ]; //zoneKey needs to be the write number not the char value
                            break;
                        }
                        default:
                            DDLogError(@"%@:>>(%li): \"%s\" is miscoded NOT Zone GET!!",THIS_METHOD,tag,[data cStringUsingEncoding:NSUTF8StringEncoding]);
                            break;
                    }
                }
                
                else if (tag == RUSSA_System_GET || tag == RUSSA_System_SET || tag == RUSSA_Notifications) {
                    
                    switch ([data cStringUsingEncoding:NSUTF8StringEncoding][2]) {
                        case 'S':
                        {
                            
                            NSString *myKey = [mytempKey componentsSeparatedByString:@"."][1];
                            //DDLogError(@"%@:updateSystemKey:%@ withValue:%@",THIS_METHOD,myKey,myValue);
                            [self updateSystemKey:myKey withValue:myValue];
                            break;
                        }
                        default:
                            DDLogError(@"%@:>> (%li): \"%s\" is miscoded NOT System GET!!",THIS_METHOD,tag,[data cStringUsingEncoding:NSUTF8StringEncoding]);
                            break;
                    }
                }
                else if (tag == RUSSA_Source_GET || tag == RUSSA_Source_SET) {
                    
                    switch ([data cStringUsingEncoding:NSUTF8StringEncoding][1]) {
                        case 'S':
                        {
                            thisSource = [[mytempKey componentsSeparatedByString:@"."][0] cStringUsingEncoding:NSUTF8StringEncoding][4]; //S S[1]
                            thisSource = [self getIntFromChar:thisSource];
                            
                            NSString *myKey = [mytempKey componentsSeparatedByString:@"."][1];
                            
                            [_sources[thisSource] updateValueForKey:myKey withValue:myValue];
                            break;
                        }
                        default:
                            DDLogError(@"%@:>> (%li): \"%s\" is miscoded NOT Source GET!!",THIS_METHOD,tag,[data cStringUsingEncoding:NSUTF8StringEncoding]);
                            break;
                    }
                }
                if (zonesIsInitialized == YES){
                    DDLogInfo(@"%@:>>  [_zoneViewController updateViewData] called", THIS_METHOD);
                    [_zoneViewController updateViewData];
                }
                
                break;
            }
                
            case 'E':
            {
                if (tag == RUSSA_Controller_GET) {
                    //DDLogError(@"processMyData->\"Controller ERROR\"");
                }
                break;
            }
            case 'N':
            {
                if (tag == RUSSA_Notifications || tag == RUSSA_System_GET || tag == RUSSA_Zone_SET) {
                    
                    switch ([data cStringUsingEncoding:NSUTF8StringEncoding][2]) {
                        case 'C':
                        {
                            //DDLogError(@"%@:>> (%li):Process Notification case 'C'",THIS_METHOD,tag);
                            
                            //Handle Controller specific responses
                            if ([data cStringUsingEncoding:NSUTF8StringEncoding][7] != 'Z') {
                                
                                //  Do not need this Controller ID.  At this point we only handle one Controller.
                                //char thisController = [[mytempKey componentsSeparatedByString:@"."][0] cStringUsingEncoding:NSUTF8StringEncoding][4]; //S C[1]
                                NSString *myKey = [mytempKey componentsSeparatedByString:@"."][1];
                                
                                [self updateController:myKey withValue:myValue];
                                
                            }
                            else
                            {
                                //Handle Zone Specific responses
                                thisZone = [[mytempKey componentsSeparatedByString:@"."][1] cStringUsingEncoding:NSUTF8StringEncoding][2];  //Z[1]
                                thisZone = [self getIntFromChar:thisZone];
                                NSString *myKey = [mytempKey componentsSeparatedByString:@"."][2];
                                [[_zones objectAtIndex:thisZone] updateValueForKey:myKey withValue:myValue ];
                                // Update the table view of Zones with power state now that we have received the last Zone attreibute notification.
                                if (thisZone == _zoneSourceCount && ([myKey  isEqual: @"lastError"])){
                                    [_zoneViewController updateViewData];
                                    zonesIsInitialized = YES;
                                }
                                // If we are done updating all zone notifications and there is a status change
                                if ([myKey  isEqual: @"status"] && (zonesIsInitialized == YES)){
                                    DDLogInfo(@"%@:>> (Status Change) Zone(%ld) %@ changed to myValue = %@",THIS_METHOD,thisZone,myKey, myValue);
                                    [_zoneViewController updateViewData];
                                }
                                else if (zonesIsInitialized == YES){
                                    DDLogInfo(@"%@:>> (zonesIsInitialized) Zone(%ld) %@ changed to myValue = %@",THIS_METHOD,thisZone,myKey, myValue);
                                    [_zoneViewController updateViewData];
                                }
                            }
                            break;
                        }
                            
                        case 'S':
                        {
                            // Check if it is a system Notification
                            if ([[mytempKey componentsSeparatedByString:@"."][0] isEqualToString:@"N System"])
                            {
                                NSString *myKey = [mytempKey componentsSeparatedByString:@"."][1];
                                DDLogError(@"%@:>> (%li):mySystem updateKey:%@ withValue:%@",THIS_METHOD,tag,myKey, myValue);
                                [mySystem updateKey:myKey withValue:myValue];
                                if (zonesIsInitialized == YES){
                                    DDLogInfo(@"%@:>> System %@ changed to = %@",THIS_METHOD, myKey, myValue);
                                    [_zoneViewController updateViewData];
                                }
                            }
                            else
                            {
                                //  Get the Source ID.  At this point we only handle one Controller.
                                
                                thisSource = [[mytempKey componentsSeparatedByString:@"."][0] cStringUsingEncoding:NSUTF8StringEncoding][4]; //N S[1]
                                thisSource = [self getIntFromChar:thisSource];
                                NSString *myKey = [mytempKey componentsSeparatedByString:@"."][1];
                                [_sources[thisSource] updateValueForKey:myKey withValue:myValue];
                                if (zonesIsInitialized == YES){
                                    //  This is calling Update view every time Radio RDS data changes wether Radio is playing or not.
                                    //  Need to fix the call to only triger if Radio is up
                                    DDLogInfo(@"%@:>> (zonesIsInitialized) System %@ changed to = %@",THIS_METHOD, myKey, myValue);
                                    [_zoneViewController updateViewData];
                                }
                            }
                            break;
                        }
                            
                        default:
                            DDLogError(@"%@:>> !!(%li):%s is miscoded Not NOTIFICATION!!",THIS_METHOD,tag,[data cStringUsingEncoding:NSUTF8StringEncoding]);
                            
                            break;
                    }
                    
                }
                else
                {
                    DDLogError(@"!!%@:>> Packet %s \nTagged as RUSSA_Notifications(%li) but not Controller,Zone, or Source!!",THIS_METHOD,[data cStringUsingEncoding:NSUTF8StringEncoding],tag);
                }
                
                break;
            }
                
            default:
                break;
        }
    }
    return;
}


- (void)setZoneWatch:(long)zone state:(BOOL)state
{
    
    NSString* myCommand;
    
    if (state)
        myCommand = [NSString stringWithFormat:@"WATCH C[%ld].Z[%ld] ON\r", _controllerID,zone];
    else
        myCommand = [NSString stringWithFormat:@"WATCH C[%ld].Z[%ld] OFF\r", _controllerID,zone];
    
    russRequest = [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
    myTag = RUSSA_Notifications;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
}

- (void)setSourceWatch:(long)source state:(BOOL)state
{
    
    NSString* myCommand;
    
    if (state)
        myCommand = [NSString stringWithFormat:@"WATCH S[%ld] ON\r",source];
    else
        myCommand = [NSString stringWithFormat:@"WATCH S[%ld] OFF\r",source];
    
    russRequest = [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
    myTag = RUSSA_Notifications;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
}

- (void)setSystemWatch:(BOOL)state
{
    
    NSString* myCommand;
    
    if (state)
        myCommand = [NSString stringWithFormat:@"WATCH System ON\r"];
    else
        myCommand = [NSString stringWithFormat:@"WATCH System OFF\r"];
    
    russRequest = [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    
    myTag = RUSSA_Notifications;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
}

//  Set current Controller hardware system value for a given key

- (void)getCurrentSystemValueForKey:(NSString *)myKey
{
    DDLogError(@"%@:myKey = %@",THIS_METHOD,myKey);
    myTag = RUSSA_System_GET;
    
    [self sendMyData:[mySystem getCurrentValueForKey:myKey] tag:myTag];
    [self readMyData:russResponse tag:myTag];
    
    
}
//  Set current Controller hardware system value for a given key

- (void)setCurrentSystemValueForKey:(NSString *)myKey withValue:myValue
{
    
    myTag = RUSSA_System_SET;
    
    [self sendMyData:[mySystem setKey:myKey withValue:myValue] tag:myTag];
    [self readMyData:russResponse tag:myTag];
    
    
}
//  Get current Controller hardware system value for a given key
- (void)getCurrentValueForKey:(NSString *)myKey
{
    
    NSString* myCommand = [NSString stringWithFormat:@"GET C[%ld].%@\r",_controllerID,myKey];
    russRequest = [myCommand dataUsingEncoding:NSUTF8StringEncoding];
    myTag = RUSSA_Controller_GET;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
}

- (void)updateController:(NSString *) myKey withValue:(NSString *)myValue
{
    //Update this array with Controller atrributes we need to update
    NSArray *controllerKeys = @[@"ipAddress", @"macAddress", @"type"];
    unsigned long controllerKey = [controllerKeys indexOfObject:myKey];
    switch (controllerKey) {
        case 0:
        {
            _controllerIPAddress = myValue;
            DDLogError(@"%@:>> %@ Updated to %@",THIS_METHOD,myKey,myValue);
            
            break;
        }
        case 1:
        {
            _controllerMacAddress = myValue;
            DDLogError(@"%@:>> %@ Updated to %@",THIS_METHOD,myKey,myValue);
            
            break;
        }
        case 2:
        {
            _controllerType = myValue;
            DDLogError(@"%@:>> %@ Updated to %@",THIS_METHOD,myKey,myValue);
            DDLogError(@"%@:>> Controller IP address =  \"%@\"", THIS_METHOD,_controllerIPAddress);
            DDLogError(@"%@:>> Controller MAC Address =  \"%@\"", THIS_METHOD,_controllerMacAddress);
            DDLogError(@"%@:>> Controller Type =  \"%@\"", THIS_METHOD,_controllerType);
            DDLogError(@"%@:>> Controller ID =  \"%ld\" ", THIS_METHOD,_controllerID);
            // if the Controller has not been initialized then initialize the Zones and Sources.
            if (!controllerIsInitialized) {
                DDLogError(@"%@:>> Calling initControllerZonesAndSources for type %@", THIS_METHOD,myValue);
                [self initControllerZonesAndSources];
                controllerIsInitialized = YES;
            }
            break;
        default:
            DDLogError(@"%@:>> Unknown Controller Key %@:", THIS_METHOD,myKey);
            break;
        }
    }
}

- (void)getCurrentSourceValue:(long)sourceID forKey:(NSString *)myKey
{
    russRequest = [_sources[sourceID] getCurrentValueForKey:myKey forSource:sourceID];
    myTag = RUSSA_Source_GET;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
    
    DDLogError(@"%@:>> (Source %ld)Requested for %@",THIS_METHOD, sourceID,russRequest);
    
}

- (NSString *)getValueforSource:(long)sourceID forKey:(NSString *)myKey
{
    //DDLogError(@"%@:>> (Source %d)Requested for %@ and got %@",THIS_METHOD, sourceID,myKey,myValue);
    return [_sources[sourceID] getValueForKey:myKey];
    
}


- (NSString *)getValueForZone:(long)zoneID forKey:(NSString *)myKey
{
    NSString *myValue = [[_zones objectAtIndex:zoneID ] getValueForKey:myKey];
    //DDLogError(@"%@:>> (Zone %d)Requested for %@ and got %@",THIS_METHOD, zoneID,myKey,myValue);
    return myValue;
}

- (void)setZone:(long)zoneID forKey:(NSString *)myKey withValue:(NSString *)myValue
{
    
    russRequest = [[_zones objectAtIndex:zoneID] setCurrentValueforKey:myKey withValue:myValue forZone:zoneID];
    
    myTag = RUSSA_Zone_SET;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
    
    //DDLogError(@"%@:>> (Zone %d) %@ Updated to %@",THIS_METHOD, zoneID,myKey,myValue);
}

- (void)setSystemKey:(NSString *)myKey withValue:(NSString *)myValue
{
    
    russRequest = [mySystem setKey:myKey withValue:myValue];
    myTag = RUSSA_System_SET;
    [self sendMyData:russRequest tag:myTag];
    [self readMyData:russResponse tag:myTag];
    
    
}



- (void)updateSystemKey:(NSString *)myKey withValue:(NSString *)myValue
{
    
    [mySystem updateKey:myKey withValue:myValue];
}

- (void)getCurrentValueForSystemKey:(NSString *)myKey
{
    
    myTag = RUSSA_System_SET;
    
    [self sendMyData:[mySystem getCurrentValueForKey:myKey] tag:myTag];
    [self readMyData:russResponse tag:myTag];
}

- (void)getValueForSystemKey:(NSString *)myKey
{
    
    [mySystem getValueForKey:myKey];
}

- (NSString *)getSystemLanguage
{
    return [mySystem getValueForKey:@"language"];
}

- (NSString *)getSystemStatus
{
    return [mySystem getValueForKey:@"status"];
}

- (NSString *)getIPAddress
{
    return _controllerIPAddress;
}

- (NSString *)getMacAddress
{
    return _controllerMacAddress;
}

- (NSString *)getType
{
    return _controllerType;
    
}


- (int) getIntFromChar:(char)theChar
{
    return (int)[[self getNumberfromString:[NSString stringWithFormat:@"%c",theChar]] integerValue];
}

- (NSNumber *)getNumberfromString:(NSString *) theString
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * theNumber = [f numberFromString:theString];
    
    return theNumber;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Called when a button i pressed to dismiss the Alert dialog box
    if (buttonIndex == 0) {
        DDLogInfo(@"%@:>>  Entered: %@",THIS_METHOD,[[actionSheet textFieldAtIndex:0] text]);
        
        DDLogInfo(@"%@:>>  Changed IP Address",THIS_METHOD);
        _host =  [[actionSheet textFieldAtIndex: 0] text];
        // Save this in the settings for the App so it is the new default...
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",_host] forKey:@"host_pref"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        reconnectCount = 3;
        [self initStreamSocket];
    }
    
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    _alert = [[UIAlertView alloc] initWithTitle:title
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:nil];
    [_alert show];
}
- (void) powerOffZone:(NSTimer *)theTimer
{
    // used by the sleep timer
    RussA_Zone *zoneToSleep = [theTimer userInfo];
    /*
     sleepDictionary = [[NSMutableDictionary alloc] init];
     [sleepDictionary setObject:@NO forKey:@"timerEnabled"];
     [sleepDictionary setObject:nil forKey:@"sleepTimer"];
     
     [_zoneSleepTimer addObject:sleepDictionary];
     
     */
    
    //reset the sleep timer
    [[_zoneSleepTimer objectAtIndex:[zoneToSleep zoneID]] setObject:@NO forKey:@"timerEnabled"];
    [[_zoneSleepTimer objectAtIndex:[zoneToSleep zoneID]] setObject:@"" forKey:@"sleepTimer"];
    
    [self setZone:[zoneToSleep zoneID] forKey:@"ZoneOff" withValue:@""];
    
    
    DDLogInfo(@"%@:>>  Zone %ld going to sleep!",THIS_METHOD,[zoneToSleep zoneID]);
    
}

-(void) sleepTimer:(NSTimeInterval)timer forZone:(long)aZone
{
    // For a non repeating timer user this as an option:
    // [self performSelector:@selector(onTick:) withObject:nil afterDelay:2.0];
    
    if ([[[_zoneSleepTimer objectAtIndex:aZone] objectForKey:@"timerEnabled"] boolValue]) {
        // Check if we had a timer set for this zone
        if ([[[_zoneSleepTimer objectAtIndex:aZone] objectForKey:@"sleepTimer"] isKindOfClass:[NSTimer class]])
        {
            //Kill the old timer before setting inititing a new one
            [[[_zoneSleepTimer objectAtIndex:aZone] objectForKey:@"sleepTimer"] invalidate];
        }
        
        [[_zoneSleepTimer objectAtIndex:aZone] setObject:[NSTimer scheduledTimerWithTimeInterval: timer
                                                                                          target: self
                                                                                        selector:@selector(powerOffZone:)
                                                                                        userInfo: [_zones objectAtIndex:aZone] //Pass the current zone for when the timer fires
                                                                                         repeats:NO]
                                                  forKey:@"sleepTimer"];
        
        
        DDLogInfo(@"%@:>>  %ld Enabled in %ld minutes",THIS_METHOD,aZone,(long)(timer/60));
    }
    else
    {
        //Check if there was a timer set
        if ([[[_zoneSleepTimer objectAtIndex:aZone] objectForKey:@"sleepTimer"] isKindOfClass:[NSTimer class]])
        {
            //Kill the old timer
            [[[_zoneSleepTimer objectAtIndex:aZone] objectForKey:@"sleepTimer"] invalidate];
            [[_zoneSleepTimer objectAtIndex:aZone] setObject:@"" forKey:@"sleepTimer"];
            DDLogInfo(@"%@:>>  Zone %ld invalidated",THIS_METHOD, aZone);
        }
        
        
    }
    
}



@end
