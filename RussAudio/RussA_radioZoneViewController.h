//
//  RussA_radioZoneViewViewController.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/29/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_AppDelegate.h"

//class RussA_Controler;

@interface RussA_radioZoneViewController : UIViewController

@property long   currentZone;
@property long   currentSource;
@property   RussA_Controler             *russController;

- (IBAction)stepVolume:(UIStepper *)sender;
- (IBAction)changeVolume:(id)sender;
- (IBAction)powerOnZone:(id)sender;
- (IBAction)setiingsView:(id)sender;
- (IBAction)muteVolue:(id)sender;
- (IBAction)tuneDown:(UIButton *)sender;
- (IBAction)tuneUp:(UIButton *)sender;
- (IBAction)tunePresetDown:(UIButton *)sender;
- (IBAction)tunePresetUp:(UIButton *)sender;
- (IBAction)selectSource:(UIButton *)sender;
- (IBAction)setZoneSleepTimer:(UIButton *)sender;


-(void)updateViewData;

@end

