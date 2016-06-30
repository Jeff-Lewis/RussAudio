//
//  RussA_settingsSlider.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/3/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_Controler.h"


@interface RussA_settingsSlider : UIViewController

@property IBOutlet UISlider     *slider;
@property IBOutlet UIStepper    *stepSlider;

@property RussA_Controler       *russController;
@property long                   currentZone;
@property NSString              *myKey;

@property   float   sliderInitialValue;
@property   float   sliderMinValue;
@property   float   sliderMaxValue;

- (IBAction)sliderDidChange:(UISlider *)sender;
- (IBAction)incrementValue:(id)sender;


@end
