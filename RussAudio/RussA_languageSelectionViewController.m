//
//  RussA_languageSelectionViewController.m
//  RussAudio
//
//  Created by Kamau Wanguhgu on 8/6/14.
//  Copyright (c) 2014 BORGcube Inc. All rights reserved.
//

#import "RussA_languageSelectionViewController.h"


@interface RussA_languageSelectionViewController ()

@property   IBOutlet UINavigationItem   *navigationTab;
@property   NSArray                     *supportedLanguages;

@end

@implementation RussA_languageSelectionViewController


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
    [_navigationTab setTitle:@"Select Language"];

    _supportedLanguages = [[NSArray alloc]initWithObjects:@"Chinese",@"English",@"Russian", nil];
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DDLogError(@"%@:>>Selected a language is %@",THIS_METHOD, _supportedLanguages[indexPath.row]);
    [_russController setSystemKey:@"language" withValue:_supportedLanguages[indexPath.row]];
     
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Table view data source


@end
