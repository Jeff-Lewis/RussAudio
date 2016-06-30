//
//  RussA_ sourceSelectViewController.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/4/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_Controler.h"


@interface RussA__sourceSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPageViewControllerDelegate>

@property   RussA_Controler     *russController;
@property   NSMutableArray      *sourceNames;

@property long   currentZone;
@property long   currentSource;

@end
 