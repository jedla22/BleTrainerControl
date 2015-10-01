//
//  ViewController.h
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

#import <UIKit/UIKit.h>

#import "ConnectionViewController.h"

typedef enum
{
    DiscoveryStateStopped,
    DiscoveryStateStarted
} DiscoveryState;

@class AppDelegate;

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDelegate;
    
    NSUserDefaults *userDefaults;
    
    DiscoveryState discoveryState;
    
    IBOutlet UIButton *discoveryButton;
    IBOutlet UITableView *discoveryTableView;
    
    IBOutlet UISwitch *searchAllSwitch;
    
    NSTimer *discoveryTimer;
    
    NSMutableArray *discoveredDeviceArray;
    
    IBOutlet UILabel *versionLabel;
}

-(IBAction)onStartDiscovery:(id)sender;

-(IBAction)onSearchAllValueChanged:(id)sender;

@end

