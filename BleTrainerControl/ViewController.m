//
//  ViewController.m
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Tacx B.V. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "ViewController.h"

#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Home";
    
    //App delegate
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Table view delegates
    [discoveryTableView setDelegate:self];
    [discoveryTableView setDataSource:self];
    
    //Cells height
    [discoveryTableView setRowHeight:75.0];
    
    //Update discovery button with state stopped by default
    [self updateDiscoveryStateAndButtonWithState:DiscoveryStateStopped];
    
    //Fonts
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        [discoveryButton.titleLabel setFont:[UIFont boldSystemFontOfSize:50.0]];
    else
        [discoveryButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30.0]];
    
    //Version
    [versionLabel setText:[NSString stringWithFormat:@"v%@(%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
}

-(void)viewWillAppear:(BOOL)animated
{
    searchAllSwitch.on = [userDefaults boolForKey:@"keySearchAll"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //Stop discovery
    [self stopDiscovery];
}

-(void)updateDiscoveryStateAndButtonWithState:(DiscoveryState)newDiscoveryState
{
    discoveryState = newDiscoveryState;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        if(discoveryState == DiscoveryStateStopped)
        {
            [discoveryButton setTitle:@"START DISCOVERY" forState:UIControlStateNormal];
            [discoveryButton setBackgroundColor:[UIColor whiteColor]];
            [discoveryButton setTitleColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0] forState:UIControlStateNormal];
        }
        else
        {
            [discoveryButton setTitle:@"STOP DISCOVERY" forState:UIControlStateNormal];
            [discoveryButton setBackgroundColor:[UIColor redColor]];
            [discoveryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
    } completion:^(BOOL finished) {
        
        
        
    }];
    
    
}


-(IBAction)onStartDiscovery:(id)sender
{
    if(discoveryState == DiscoveryStateStopped)
    {
        //Start discovery
        [self startDiscovery];
    }
    else
    {
        //Stop discovery
        [self stopDiscovery];
    }
}


-(void)startDiscovery
{
    //Remove all object from array
    if(discoveredDeviceArray != nil)
        [discoveredDeviceArray removeAllObjects];
    
    //Reload to clear old results
    [discoveryTableView reloadData];
    
    //Discovery state started
    [self updateDiscoveryStateAndButtonWithState:DiscoveryStateStarted];
    
    if([userDefaults boolForKey:@"keySearchAll"] == FALSE)
    {
        //Start scanning
        [appDelegate.btleTrainerManager startScanning];
    }
    else
    {
        //Start scanning for all devices
        [appDelegate.btleTrainerManager startScanningAll];
    }
    
    //Start discovery timer
    [self startDiscoveryTimer];
}

-(void)stopDiscovery
{
    //Discovery state started
    [self updateDiscoveryStateAndButtonWithState:DiscoveryStateStopped];
    
    //Stop scanning
    [appDelegate.btleTrainerManager stopScanning];
    
    //Start discovery timer
    [self stopDiscoveryTimer];
}


-(void)startDiscoveryTimer
{
    if(discoveryTimer == nil)
    {
        //Start discovery timer
        discoveryTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDiscoveredDevices) userInfo:nil repeats:TRUE];
    }
}

-(void)stopDiscoveryTimer
{
    if(discoveryTimer != nil)
    {
        //Stop discovery timer
        if([discoveryTimer isValid] == TRUE)
            [discoveryTimer invalidate];
        
        discoveryTimer = nil;
    }
}


-(void)checkDiscoveredDevices
{
    //Get peripherals discovered array
    discoveredDeviceArray = [appDelegate.btleTrainerManager getDiscoveredPeripheralArray];
    
    //Reload table view
    [discoveryTableView reloadData];
}




//TABLE VIEW DELEGATE

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(discoveredDeviceArray != nil)
        return [discoveredDeviceArray count];
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Discovered devices";
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    [view setTintColor:[UIColor darkGrayColor]];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

//For iOS 6
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Background color
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:0.5]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    //Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        //Init cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //Background color
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:0.5]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
    
    //Disclosure indicator
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    //Background color label
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    
    //Fonts
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:30.0]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:20.0]];
    }
    else
    {
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0]];
    }
    
    //Peripheral discovered
    CBPeripheral *peripheral = [discoveredDeviceArray objectAtIndex:indexPath.row];
    
    //Name
    [cell.textLabel setText:peripheral.name];
    
    //UUID
    if([peripheral respondsToSelector:@selector(identifier)])
        [cell.detailTextLabel setText:[peripheral.identifier UUIDString]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Peripheral discovered
    CBPeripheral *peripheral = [discoveredDeviceArray objectAtIndex:indexPath.row];
    
    
    //ConnectionViewController *connectionViewController = [[[ConnectionViewController alloc] initWithPeripheral:peripheral] autorelease];
    
    ConnectionViewController *connectionViewController = nil;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        connectionViewController = [[[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil] autorelease];
    else
        connectionViewController = [[[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController_iPhone" bundle:nil] autorelease];
    
    [connectionViewController setPeripheralSelected:peripheral];
    
    if(connectionViewController != nil)
        [self.navigationController pushViewController:connectionViewController animated:TRUE];
}





-(IBAction)onSearchAllValueChanged:(id)sender
{
    [userDefaults setBool:searchAllSwitch.on forKey:@"keySearchAll"];
    [userDefaults synchronize];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
