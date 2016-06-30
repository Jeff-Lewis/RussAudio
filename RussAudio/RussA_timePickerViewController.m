//
//  RussA_timePickerViewController.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/9/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_timePickerViewController.h"
//#import "DDTTYLogger.h"

@interface RussA_timePickerViewController ()

@property   IBOutlet UINavigationItem   *navigationTab;
@property   IBOutlet UIDatePicker       *picker;
@property   IBOutlet UISwitch           *enableDisableTimmerSwitch;


@end

@implementation RussA_timePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_picker setDatePickerMode:UIDatePickerModeCountDownTimer];
    // Set the picker to 15 minutes by default
    [_picker setCountDownDuration:900];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
    [_navigationTab setTitle:@"Sleep Time"];
    //[_enableDisableTimmerSwitch setOn:[[_russController.zoneSleepTimer objectAtIndex:_currentZone] boolValue]];
    [_enableDisableTimmerSwitch setOn:[[[_russController.zoneSleepTimer objectAtIndex:_currentZone] objectForKey:@"timerEnabled"] boolValue]];
    
}

- (void)viewDidAppear:(BOOL)animated;     // Called when the view has been fully transitioned onto the screen. Default does nothing
{
    //DDLogError(@"%@:>> ",THIS_METHOD);
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)enableDisableTimer:(UISwitch *)sender
{
    
    if (_enableDisableTimmerSwitch.on)
    {
        [[_russController.zoneSleepTimer objectAtIndex:_currentZone] setObject:@"YES" forKey:@"timerEnabled"];
;
    }
    else
    {
        [[_russController.zoneSleepTimer objectAtIndex:_currentZone] setObject:@"NO" forKey:@"timerEnabled"];
    }
    
    [_russController sleepTimer:[_picker countDownDuration] forZone:_currentZone];
    
}

- (IBAction)setSleepTime:(UIDatePicker *)sender
{
    if (_enableDisableTimmerSwitch.on)
    {
        DDLogError(@"%@:>>  for Zone(%ld))",THIS_METHOD,_currentZone);
        [_russController sleepTimer:[_picker countDownDuration] forZone:_currentZone];
    }
}
@end



