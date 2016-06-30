//
//  RussA_ZoneSettingsController.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/1/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_ZoneSettingsController.h"
#import "RussA_settingsSlider.h"
#import "RussA_languageSelectionViewController.h"

@interface RussA_ZoneSettingsController ()
@property (strong, nonatomic) id zoneSettings;

@property (weak, nonatomic) IBOutlet UISwitch *loudnessSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *doNotDisturbSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *allZonesOff;
@property (weak, nonatomic) IBOutlet UITableViewCell *allZonesOn;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutMyRussound;
@property (weak, nonatomic) IBOutlet UITableViewCell *loudnessCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bassCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *trebleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *balanceCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *turnOnVolumeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *partyModeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *doNotDisturbCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *allZonesOffCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *allZonesOnCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutMyRussoundCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *systemLanguageCell;

@property   IBOutlet UINavigationItem               *navigationTab;

@property RussA_settingsSlider                      *settingsSliderView;
@property RussA_languageSelectionViewController     *systemLanguageView;



@end

@implementation RussA_ZoneSettingsController

NSString    *bass;
NSString    *treble;
NSString    *balance;
NSString    *turnOnVolume;
NSString    *partyMode;
NSString    *doNotDisturb;
NSString    *systemLanguage;


static NSString *cellIdentifier = @"withSwitch";


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self updateViewData];
    
    [_navigationTab setTitle:@"Settings"];
    
    _bassCell.detailTextLabel.text = bass;
    _trebleCell.detailTextLabel.text = treble;
    _balanceCell.detailTextLabel.text = balance;
    _turnOnVolumeCell.detailTextLabel.text = turnOnVolume;
    _partyModeCell.detailTextLabel.text = partyMode;
    _systemLanguageCell.detailTextLabel.text = systemLanguage;
    
    [super viewWillAppear:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _settingsSliderView = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsSliderView"];
    [_settingsSliderView setRussController:_russController];
    [_settingsSliderView setCurrentZone:_currentZone];

   
    switch ((long)cell.tag) {
        case 0:     //Loudness
        {
            [cell setSelected:NO];
            DDLogInfo(@"%@:>> Setting Row %ld selected with tag: %ld",THIS_METHOD,(long)indexPath.row,(long)cell.tag);
            break;
        }
        case 1:     //Bass
        {
            [_settingsSliderView setMyKey:@"bass"];
            [_settingsSliderView setSliderInitialValue:[[_russController getNumberfromString:bass] doubleValue]];
            [_settingsSliderView setSliderMinValue: -10];
            [_settingsSliderView setSliderMaxValue:10];
            

            [[self navigationController] pushViewController: (RussA_settingsSlider *)_settingsSliderView animated:YES];
            
            DDLogInfo(@"%@:>> Setting bass to %f and number was %f",THIS_METHOD,[_settingsSliderView sliderInitialValue], [[_russController getNumberfromString:bass] floatValue]);
            
            break;
        }
        case 2:     //Treble
        {
            [_settingsSliderView setMyKey:@"treble"];
            [_settingsSliderView setSliderInitialValue:[[_russController getNumberfromString:treble] doubleValue]];
            [_settingsSliderView setSliderMinValue: -10];
            [_settingsSliderView setSliderMaxValue:10];
            
            
            [[self navigationController] pushViewController: (RussA_settingsSlider *)_settingsSliderView animated:YES];
            
            break;
        }
        case 3:     //Balance
        {
            [_settingsSliderView setMyKey:@"balance"];
            [_settingsSliderView setSliderInitialValue:[[_russController getNumberfromString:balance] doubleValue]];
            [_settingsSliderView setSliderMinValue: -10];
            [_settingsSliderView setSliderMaxValue:10];
            
            
            [[self navigationController] pushViewController: (RussA_settingsSlider *)_settingsSliderView animated:YES];

            break;
        }
        case 4:     //Turn-on Volume
        {
            [_settingsSliderView setMyKey:@"turnOnVolume"];
            [_settingsSliderView setSliderInitialValue:[[_russController getNumberfromString:turnOnVolume] doubleValue]];
            [_settingsSliderView setSliderMinValue: 0];
            [_settingsSliderView setSliderMaxValue:50];
            
            
            [[self navigationController] pushViewController: (RussA_settingsSlider *)_settingsSliderView animated:YES];

            break;
        }
        case 5:     //Party Mode
        {
            DDLogInfo(@"%@:>> Party Mode Selected",THIS_METHOD);
            break;
        }
        case 6:     //Do Not Disturb
        {
            [cell setSelected:NO];
            break;
        }
        case 7:     //All Zones Off
        {
            [cell setSelected:NO];
            [_russController setZone:_currentZone forKey:@"AllOff" withValue:@""];
            break;
        }
        case 8:     //All Zones On
        {
            [cell setSelected:NO];
            [_russController setZone:_currentZone forKey:@"AllOn" withValue:@""];
            break;
            
        }
        case 9:     //System Language
        {
            _systemLanguageView = [self.storyboard instantiateViewControllerWithIdentifier:@"languageSelectionView"];
            [_systemLanguageView setRussController:_russController];
            [[self navigationController] pushViewController:_systemLanguageView animated:YES];
            
            break;
        }
        case 10:    //About my Russound
        {
            _settingsSliderView = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutMyRussound"];
            [[self navigationController] pushViewController: (RussA_settingsSlider *)_settingsSliderView animated:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)changeLoudness:(id)sender
{
    //loudness
    if (_loudnessSwitch.on) {
        [_russController setZone:_currentZone forKey:@"loudness" withValue:@"ON"];
    }
    else
    {
        [_russController setZone:_currentZone forKey:@"loudness" withValue:@"OFF"];
    }
}
- (IBAction)changeDoNotDisturb:(id)sender
{
    //DoNotDisturb
    if (_doNotDisturbSwitch.on) {
        [_russController setZone:_currentZone forKey:@"DoNotDisturb" withValue:@"ON"];
    }
    else
    {
        [_russController setZone:_currentZone forKey:@"DoNotDisturb" withValue:@"OFF"];
    }

    
}

- (void) updateViewData
{
    /*
     bass -10 - 10
     treble -10 - 10
     balance -10 - 10
     turnOnVolume 0 - 50
     partyMode OFF/ON/MASTER (Party is OFF/ON and master is OFF/ON)
     doNotDisturb OFF/ON/SLAVE
     */
    
    //loudness OFF/ON
    if ([[_russController getValueForZone:_currentZone forKey:@"loudness"] isEqualToString:@"ON"]) {
        [_loudnessSwitch setOn:YES animated:YES];
    }
    else
    {
        [_loudnessSwitch setOn:NO animated:YES];
    }
    
    bass = [_russController getValueForZone:_currentZone forKey:@"bass"];
    if ([bass isEqualToString:@"0"])
    {
        bass = @"Flat";
    }
    
    treble = [_russController getValueForZone:_currentZone forKey:@"treble"];
    if ([treble isEqualToString:@"0"])
    {
        treble = @"Flat";
    }
    
    balance = [_russController getValueForZone:_currentZone forKey:@"balance"];
    if ([balance isEqualToString:@"0"])
    {
        balance = @"Center";
    }
    
    turnOnVolume = [_russController getValueForZone:_currentZone forKey:@"turnOnVolume"];
    partyMode = [_russController getValueForZone:_currentZone forKey:@"partyMode"];
    doNotDisturb = [_russController getValueForZone:_currentZone forKey:@"doNotDisturb"];
    systemLanguage = [_russController getSystemLanguage];
    

    _bassCell.detailTextLabel.text = bass;
    _trebleCell.detailTextLabel.text = treble;
    _balanceCell.detailTextLabel.text = balance;
    _turnOnVolumeCell.detailTextLabel.text = turnOnVolume;
    _partyModeCell.detailTextLabel.text = partyMode;
    _systemLanguageCell.detailTextLabel.text = systemLanguage;

    
}


@end
