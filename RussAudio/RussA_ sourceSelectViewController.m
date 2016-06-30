//
//  RussA_ sourceSelectViewController.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/4/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_ sourceSelectViewController.h"
//#import "DDTTYLogger.h"


@interface RussA__sourceSelectViewController ()

@property   IBOutlet UINavigationItem   *navigationTab;

@property   IBOutlet UIImageView        *flagImageView;
@property   IBOutlet UITableView        *myTableView;
@property   long                        selectedSource;

@end

@implementation RussA__sourceSelectViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _sourceNames = [[NSMutableArray alloc] init];

    [super viewDidLoad];
    [self updateViewData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [_navigationTab setTitle:@"Sources"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [_sourceNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"sourceName";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    [[cell textLabel] setText:[_sourceNames objectAtIndex:indexPath.row] ];

    if (indexPath.row == (_currentSource - 1) ) {
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
        [[cell textLabel] setTextColor:[UIColor blackColor]];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volumeUp.png"]];
        [[cell accessoryView] setFrame:CGRectMake(0,0,30,30)];
    }
    else {
        [[cell textLabel] setFont:[UIFont systemFontOfSize:16.0]];
        [[cell textLabel] setTextColor:[UIColor grayColor]];

    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _selectedSource = indexPath.row + 1;
    [_russController setZone:_currentZone forKey:@"SelectSource" withValue:[NSString stringWithFormat:@"%lu",_selectedSource]];

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) updateViewData
{
    [_sourceNames removeAllObjects];
    NSString *tempSourceName;
    NSString *tempSourceType;
    if (_russController.zoneSourceCount != 0)
    {
        for (int i=1; i<=_russController.zoneSourceCount; i++) {
            
            tempSourceName = [_russController getValueforSource:i forKey:@"name"];
            tempSourceType = [_russController getValueforSource:i forKey:@"type"];
            if (![tempSourceType isEqualToString:@""]) {
                [_sourceNames addObject: tempSourceName];
                
            }
        }
        
    }
    [_myTableView reloadData];
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

@end
