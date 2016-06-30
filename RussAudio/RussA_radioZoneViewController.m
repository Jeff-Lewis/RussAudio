//
//  RussA_radioZoneViewViewController.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/29/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_radioZoneViewController.h"
#import "RussA_ZoneSettingsController.h"
#import "RussA_ sourceSelectViewController.h"
#import "RussA_timePickerViewController.h"
//#import "DDTTYLogger.h"


@interface RussA_radioZoneViewController ()

@property   IBOutlet UILabel            *channel;
@property   IBOutlet UILabel            *programServiceName;
@property   IBOutlet UILabel            *radioText;
@property   IBOutlet UISlider           *volumeSlider;
@property   IBOutlet UIButton           *powerSwitch;
@property   IBOutlet UIButton           *settingsButton;
@property   IBOutlet UILabel            *sourceName;
@property   IBOutlet UIButton           *volumDown;
@property   IBOutlet UIStepper          *volumeStepper;
@property   IBOutlet UIButton           *volumeUp;
@property   IBOutlet UIButton           *volumeMute;
@property   IBOutlet UINavigationItem   *navigationTab;
@property   IBOutlet UIButton           *tuneDownButton;
@property   IBOutlet UIButton           *tuneUpButton;
@property   IBOutlet UIButton           *tunePresetDown;
@property   IBOutlet UIButton           *tunePresetUp;
@property   IBOutlet UIButton           *sourceSelectButton;
@property   IBOutlet UIButton           *SleepTimer;
@property   IBOutlet UIButton           *bankPresetUp;
@property   IBOutlet UIButton           *bankPresetDown;
@property   IBOutlet UILabel            *presetBankLable;
@property   IBOutlet UIImageView        *coverArt;

@property RussA_ZoneSettingsController      *zoneSettingsView;
@property RussA__sourceSelectViewController *sourceSelectView;
@property RussA_timePickerViewController    *timePicker;



@end

@implementation RussA_radioZoneViewController

//This should be passed when the view is called as the user is choosing to interact with a zone
NSString         *myVolume;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myVolume = [[NSString alloc] init];
    
    //  Send update messages only after user has finished moving thumb button
    [_volumeSlider setContinuous:NO];
    [_volumeSlider setBackgroundColor:[UIColor clearColor]];
    [_volumeSlider setMinimumValue:0];
    [_volumeSlider setMaximumValue:50];
    [_volumeStepper setMinimumValue:0];
    [_volumeStepper setMaximumValue:50];
    
    [_channel setTextAlignment:(NSTextAlignmentCenter)];
    [_channel setFont:[UIFont systemFontOfSize:15.0] ];
    [_channel setNumberOfLines:1];
    [_channel setAdjustsFontSizeToFitWidth:true];
    //[_channel adjustsFontSizeToFitWidth];
    
    [_programServiceName setTextAlignment:(NSTextAlignmentCenter)];
    [_programServiceName setFont:[UIFont systemFontOfSize:12.0]];
    [_programServiceName setNumberOfLines:2];
    //[_programServiceName adjustsFontSizeToFitWidth];
    
    [_radioText setTextAlignment:(NSTextAlignmentCenter)];
    [_radioText setFont:[UIFont systemFontOfSize:10.0]];
    [_radioText setNumberOfLines:2];
   // [_radioText adjustsFontSizeToFitWidth];


    // Custom images on the sides of the slider (use speaker images)
    //[volumeSlider setMinimumTrackImage:[UIImage imageNamed:@"volumeDown"] forState:UIControlStateNormal];
    //[volumeSlider setMaximumTrackImage:[UIImage imageNamed:@"volumeUp"] forState:UIControlStateNormal];
    //custom thumb image of touched and untouched
    [_volumeSlider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [_volumeSlider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    [_volumeSlider setValue:[[_russController getValueForZone:_currentZone forKey:@"volume"] doubleValue]];

}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogError(@"%@:>> ",THIS_METHOD);

    [super viewWillAppear:animated];
    
    [_navigationTab setTitle:[_russController getValueForZone:_currentZone forKey:@"name"]];

    [self updateViewData];      // Make sure we have the current data

    /*
     for (int count = 0; count < controllerCount; count++){
        thisController = [[[SonosControllerStore sharedStore] allControllers] objectAtIndex:count];
        DDLogError(@"%@>> Name: %@", THIS_METHOD, [thisController objectForKey:@"name"]);
    }
     */

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateViewData
{
    if ([[_russController getValueForZone:_currentZone forKey:@"status"]  isEqual: @"OFF"]) {
        [self hideViewElements:YES];
        [_powerSwitch setImage:[UIImage imageNamed:@"powerOff.png"]forState:UIControlStateNormal];
        [self clearViewData];
    }
    else
    {
        [self hideViewElements:NO];
        //long sourceID = [_russController getIntFromChar: [[_russController getValueForZone:_currentZone forKey:@"currentSource"] characterAtIndex:0]];
        _currentSource = (long)[[_russController getValueForZone:_currentZone forKey:@"currentSource"] doubleValue];
        
        
        NSString *thisSource = [_russController getValueforSource:_currentSource forKey:@"name"];
        
        [_sourceName setText:thisSource];
        //DDLogError(@"%@:>> Source updated to: %@",THIS_METHOD,[_sourceName text]);
        
        [_powerSwitch setImage:[UIImage imageNamed:@"powerOn.png"]forState:UIControlStateNormal];

        if ([[_russController getValueforSource:_currentSource forKey:@"type"] rangeOfString:@"RNET AM/FM Tuner" options:NSCaseInsensitiveSearch].length > 0) {  //This Source is a Radio
            [_channel setText:[_russController getValueforSource:_currentSource forKey:@"channel"]];
            [_programServiceName setText:[_russController getValueforSource:_currentSource forKey:@"programServiceName"]];
            [_radioText setText:[_russController getValueforSource:_currentSource forKey:@"radioText"]];
            //Change CoverArt to reflect radio
            [_coverArt setImage:[UIImage imageNamed:@"Radio-Wooden"]];
        }
        else
        {
            // ChangeChanel to Artist
            [_channel setHidden:YES];
            // ChangeChanel to Album Title
            [_programServiceName setHidden:YES];
            // ChangeChanel to Song Title
            [_radioText setHidden:YES];
            [_bankPresetDown setHidden:YES];
            [_bankPresetUp setHidden:YES];
            [_presetBankLable setHidden:YES];
            
            // ** We need to change tghis to reflect the imput.  Current is Radio or not. **
            //Change CoverArt to reflect it is not radio
            [_coverArt setImage:[UIImage imageNamed:@"Music-Wooden"]];

            
        }
        if ([[_russController getValueForZone:_currentZone forKey: @"mute"] isEqualToString:@"ON"]) {
            [_volumeMute setBackgroundColor:[UIColor greenColor]];
        }
        else
        {
            [_volumeMute setBackgroundColor:[UIColor clearColor]];
            
        }
        
        
        [_volumeSlider setValue:[[_russController getValueForZone:_currentZone forKey:@"volume"] doubleValue]];
        [_volumeStepper setValue:[_volumeSlider value]];
        myVolume = [NSString stringWithFormat:@"%2.0ld",lround([_volumeSlider value])];
        
        
        if (_zoneSettingsView.isViewLoaded) {
            //DDLogError(@"%@:>>zoneSettingsView is loaded will update View",THIS_METHOD);
            [_zoneSettingsView updateViewData];
        }
    }
    
}

-(void)clearViewData
{
    [_channel setText:Nil];
    [_programServiceName setText:Nil];
    [_radioText setText:Nil];
    
}

-(void) hideViewElements:(BOOL)hidden
{
    [_channel setHidden:hidden];
    [_programServiceName setHidden:hidden];
    [_radioText setHidden:hidden];
    [_sourceName setHidden:hidden];
    [_volumeStepper setHidden:hidden];
    [_volumeSlider setHidden:hidden];
    [_volumeMute setHidden:hidden];
    [_tuneDownButton setHidden:hidden];
    [_tuneUpButton setHidden:hidden];
    [_tunePresetDown setHidden:hidden];
    [_tunePresetUp setHidden:hidden];
    [_sourceSelectButton setHidden:hidden];
    [_SleepTimer setHidden:hidden];
    [_bankPresetDown setHidden:hidden];
    [_bankPresetUp setHidden:hidden];
    [_presetBankLable setHidden:hidden];
    [_coverArt setHidden:hidden];
    
    
    
}

- (IBAction)stepVolume:(UIStepper *)sender
{
    //[_volumeSlider setValue:[_volumeStepper value]];
    if (lround([_volumeSlider value]) < 1)
    {
        myVolume = @"0";
    }
    else
    {
        //myVolume = [NSString stringWithFormat:@"%2.0ld",lround([_volumeSlider value])];
        myVolume = [NSString stringWithFormat:@"%2.0ld",lround([_volumeStepper value])];
    }
    [_russController setZone:_currentZone forKey:@"KeyPress" withValue:[NSString stringWithFormat:@"Volume %@",myVolume]];

}

-(IBAction)changeVolume:(id)sender
{
    if (lround([_volumeSlider value]) < 1)
    {
        myVolume = @"0";
    }
    else
    {
        myVolume = [NSString stringWithFormat:@"%2.0ld",lround([_volumeSlider value])];
    }
    [_volumeStepper setValue:[_volumeSlider value]];
    [_russController setZone:_currentZone forKey:@"KeyPress" withValue:[NSString stringWithFormat:@"Volume %@",myVolume]];
    
    
}

-(IBAction)powerOnZone:(id)sender
{
    if ([[_russController getValueForZone:_currentZone forKey:@"status"]  isEqual: @"OFF"]) {
        DDLogError(@"%@:>> Powered On Zone(%ld)",THIS_METHOD,_currentZone);
        [_russController setZone:_currentZone forKey:@"ZoneOn" withValue:@""];
        //[_russController setZoneWatch:_currentZone state:RUSSA_ON];

        
    }
    else
    {
        DDLogError(@"%@:>> Powered Off Zone(%ld)",THIS_METHOD,_currentZone);
        [_russController setZone:_currentZone forKey:@"ZoneOff" withValue:@""];
        //[_russController setZoneWatch:_currentZone state:RUSSA_OFF];
    }
    
}

-(IBAction)setiingsView:(id)sender
{
    _zoneSettingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"zoneSettingsView"];
    [_zoneSettingsView setRussController:_russController];
    [_zoneSettingsView setCurrentZone:_currentZone];
    
    [[self navigationController] pushViewController: (RussA_radioZoneViewController *)_zoneSettingsView animated:YES];
}

- (IBAction)muteVolue:(id)sender
{
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"Mute"];
}

- (IBAction)tuneDown:(UIButton *)sender
{
    //EVENT C[1].Z[5]!KeyRelease ChannelDown
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"ChannelDown"];

}

- (IBAction)tuneUp:(UIButton *)sender
{
    //EVENT C[1].Z[5]!KeyRelease ChannelUp
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"ChannelUp"];
}

- (IBAction)tunePresetDown:(UIButton *)sender
{
    //EVENT C[1].Z[5]!KeyRelease Previous
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"Previous"];
    
}

- (IBAction)tunePresetUp:(UIButton *)sender
{
    //EVENT C[1].Z[5]!KeyRelease Next
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"Next"];
}
- (IBAction)presetBankDown:(UIButton *)sender
{
    //EVENT C[1].Z[5]!KeyRelease Previous
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"PageDown"];
    
}

- (IBAction)presetBankUp:(UIButton *)sender
{
    //EVENT C[1].Z[5]!KeyRelease Next
    [_russController setZone:_currentZone forKey:@"KeyRelease" withValue:@"PageUp"];
}


- (IBAction)selectSource:(UIButton *)sender
{
    _sourceSelectView = [self.storyboard instantiateViewControllerWithIdentifier:@"sourceSelectView"];
    [_sourceSelectView setRussController:_russController];
    [_sourceSelectView setCurrentSource:_currentSource];
    [_sourceSelectView setCurrentZone:_currentZone];
    
    
    [[self navigationController] pushViewController: (RussA_radioZoneViewController *)_sourceSelectView animated:YES];

}

- (IBAction)setZoneSleepTimer:(UIButton *)sender
{
    _timePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"timePickerView"];
    [_timePicker setRussController:_russController];
    [_timePicker setCurrentZone:_currentZone];
    [[self navigationController] pushViewController: (RussA_timePickerViewController *)_timePicker animated:YES];
}

@end
