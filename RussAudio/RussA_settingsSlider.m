//
//  RussA_settingsSlider.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/3/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_settingsSlider.h"
//#import "DDTTYLogger.h"


@interface RussA_settingsSlider ()

@property  IBOutlet UINavigationItem    *navigationTab;
@property  IBOutlet UILabel             *currentSliderValue;

@end

@implementation RussA_settingsSlider


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_slider setContinuous:NO];
    [_slider setBackgroundColor:[UIColor clearColor]];
    [_slider setMinimumValue:_sliderMinValue];
    [_slider setMaximumValue:_sliderMaxValue];
    [_slider setValue:_sliderInitialValue];
    
    [_stepSlider setMinimumValue:_sliderMinValue];
    [_stepSlider setMaximumValue:_sliderMaxValue];
    [_stepSlider setStepValue:1];
    [_stepSlider setValue:[_slider value]];
    _currentSliderValue.text = [NSString stringWithFormat:@"%d",(int)[_slider value]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{

    [_navigationTab setTitle:_myKey];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sliderDidChange:(UISlider *)sender
{
    [_stepSlider setValue:[_slider value]];
    _currentSliderValue.text = [NSString stringWithFormat:@"%d",(int)[_slider value]];
    [_russController setZone:_currentZone forKey:_myKey withValue:[NSString stringWithFormat:@"%d",(int)[_slider value]]];
}

- (IBAction)incrementValue:(id)sender
{
    [_slider setValue:[_stepSlider value]];
    _currentSliderValue.text = [NSString stringWithFormat:@"%d",(int)[_stepSlider value]];
    [_russController setZone:_currentZone forKey:_myKey withValue:[NSString stringWithFormat:@"%d",(int)[_stepSlider value]]];

}
@end
