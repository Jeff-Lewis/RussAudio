//
//  RussA_timePickerViewController.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/9/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_Controler.h"


@interface RussA_timePickerViewController : UIViewController

@property       RussA_Controler     *russController;
@property       long                currentZone;


- (IBAction)enableDisableTimer:(UISwitch *)sender;
- (IBAction)setSleepTime:(UIDatePicker *)sender;

@end
