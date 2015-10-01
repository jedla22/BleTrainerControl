//
//  ConnectionViewController.h
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

#import <CoreBluetooth/CoreBluetooth.h>

#import "BasicResistanceViewController.h"
#import "TargetPowerViewController.h"
#import "WindResistanceViewController.h"
#import "TrackResistanceViewController.h"

#import "CalibrationViewController.h"

@class AppDelegate;

@interface ConnectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDelegate;
    
    NSTimer *getDataTimer;
    
    CBPeripheral *peripheralSelected;
    
    IBOutlet UITableView *dataPagesTableView;
    
    IBOutlet UILabel *statusValueLabel;
    
    BOOL isDisplayingModalView;
}

@property (nonatomic, retain) CBPeripheral *peripheralSelected;


-(IBAction)onBasicResistance:(id)sender;
-(IBAction)onTargetPower:(id)sender;
-(IBAction)onWindResistance:(id)sender;
-(IBAction)onTrackResistance:(id)sender;

-(IBAction)onCalibration:(id)sender;


-(IBAction)requestPage1:(id)sender;
-(IBAction)requestPage2:(id)sender;
-(IBAction)requestPage17:(id)sender;
-(IBAction)requestPage54:(id)sender;
-(IBAction)requestPage55:(id)sender;

@end
