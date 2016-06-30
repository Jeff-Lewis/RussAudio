//
//  RussA_FirstViewController.h
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/15/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RussA_Controler.h"


@class RussA_Controler;


@interface RussA_FirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPageViewControllerDelegate>


{

    IBOutlet UITableView        *myTableView;
    IBOutlet UIViewController   *radioZoneView;

    
}
@property   RussA_Controler         *russController;
@property   NSMutableArray          *zoneNames;
@property   NSMutableArray          *zonePowerStates;


- (void) initZoneTables;
- (void) updateViewData;

@end

