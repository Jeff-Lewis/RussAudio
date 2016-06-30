//
//  RussA_FirstViewController.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 7/15/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_FirstViewController.h"
#import "RussA_radioZoneViewController.h"


@interface RussA_FirstViewController ()
@property   IBOutlet UINavigationItem   *navigationTab;

@property   long                selectedZone;


@end

@implementation RussA_FirstViewController



RussA_radioZoneViewController *zoneView;
BOOL            connected = NO;



- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
    [_navigationTab setTitle:@"Zones"];


}
- (void)viewDidAppear:(BOOL)animated;     // Called when the view has been fully transitioned onto the screen. Default does nothing
{
    DDLogError(@"%@:>>",THIS_METHOD);
}


#pragma mark - Table view delegate and data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_zoneNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"zoneData";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    [[cell textLabel] setText:[_zoneNames objectAtIndex:indexPath.row] ];
    
    if ([[_zonePowerStates objectAtIndex:indexPath.row]  isEqual: @"OFF"])
    {
        [[cell textLabel] setFont:[UIFont systemFontOfSize:16.0]];
        [[cell textLabel] setTextColor:[UIColor grayColor]];

        [[cell accessoryView] setFrame:CGRectMake(0,0,30,30)];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powerOff.png"]];
        //[[cell imageView] setImage:[UIImage imageNamed:@"powerOff.png"]];
    }
    else
    {
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
        [[cell textLabel] setTextColor:[UIColor blackColor]];

        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powerOn.png"]];
        [[cell accessoryView] setFrame:CGRectMake(0,0,30,30)];
        
        
        
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _selectedZone = indexPath.row +1;
    [self displayZone];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    /*
     There needs to be better information displayed for this.  Currently accessory button is not displayed
     */
    
    _selectedZone = indexPath.row +1;
    
    //long sourceID = [_russController getIntFromChar: [[_russController getValueForZone:_selectedZone forKey:@"currentSource"] characterAtIndex:0]];
    long sourceID = [[_russController getNumberfromString:[_russController getValueForZone:_selectedZone forKey:@"currentSource"]] longValue];
    
    NSString *sourceName = [_russController getValueforSource:sourceID forKey:@"name"];
    
    _russController.alert = [[UIAlertView alloc] initWithTitle:@"Detail Pushed"
                                                       message:[NSString stringWithFormat: @"Current Source is \"%@\"",sourceName]
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [_russController.alert show];
    
}


#pragma mark - Configuring Zone view cells

-(void)displayZone
{
    
    zoneView = [self.storyboard instantiateViewControllerWithIdentifier:@"radioZoneView"];
    
    [zoneView setRussController:_russController];   //Tell the zone view which controller it is using.
    [zoneView setCurrentZone:_selectedZone];        // Tell the zoneView which zone was selected
    
    
    // Tell the zoneView the current Source selected
    [zoneView setCurrentSource:[[_russController getNumberfromString:[_russController getValueForZone:_selectedZone forKey:@"currentSource"]] longValue]];
    
    [[self navigationController] pushViewController:zoneView animated:YES];
    
    
    
    
}

- (void) dismissZone
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)initZoneTables

{
    // Initialize table data
    //DDLogError(@"%@:>>",THIS_METHOD);

    
    if (_russController.zoneSourceCount != 0)
    {
        for (int i=1; i<=_russController.zoneSourceCount; i++) {
            [_zoneNames addObject:[_russController getValueForZone:i forKey:@"name"]];
            [_zonePowerStates addObject:[_russController getValueForZone:i forKey:@"status"]];
        }
        
        if (!connected) {
            [_russController.alert dismissWithClickedButtonIndex:1 animated:YES];
            connected = YES;
        }
        
        
    }
    else
    {
        for (int i=1; i<=_russController.zoneSourceCount; i++) {
            [_zoneNames addObject:[NSString stringWithFormat: @"Zone %d ",i]];
            [_zonePowerStates addObject:[NSString stringWithFormat: @"OFF"]];
        }
    }
}

- (void) updateViewData
{
    [_zoneNames removeAllObjects];
    [_zonePowerStates removeAllObjects];
    
    [self initZoneTables];
    
    if (!connected) {
        //[self showAlertWithTitle:@"Conecting"
        //                 message:[NSString stringWithFormat:@" Connecting to: \n%@ on port %hu",_russController.host,_russController.port]];
        [_russController.alert dismissWithClickedButtonIndex:1 animated:YES];
        [_russController showAlertWithTitle:@"Connected"
                                    message:[NSString stringWithFormat:@"Updating Data"]];
    }
    
    [myTableView reloadData];
    
    // Update our subview
    if ([zoneView isViewLoaded]) {
        DDLogError(@"%@:>>radioZoneView is loaded and will update",THIS_METHOD);
        [zoneView updateViewData];
    }
}

@end
