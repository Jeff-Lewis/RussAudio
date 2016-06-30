//
//  RussA_AppDelegate.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/15/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_Controler.h"

@class RussA_Controler;

@interface RussA_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property RussA_Controler   *russController;


@end
