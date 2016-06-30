//
//  RussA_ZoneSettingsController.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/1/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_Controler.h"


//@class RussA_Controler;


@interface RussA_ZoneSettingsController : UITableViewController

@property RussA_Controler       *russController;
@property long                   currentZone;


- (IBAction)changeLoudness:(id)sender;
- (IBAction)changeDoNotDisturb:(id)sender;

- (void) updateViewData;

@end
