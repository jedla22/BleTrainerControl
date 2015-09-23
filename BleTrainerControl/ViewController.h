//
//  ViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 27/08/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

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

