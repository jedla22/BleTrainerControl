//
//  SpinDownCalibrationViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 04/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface SpinDownCalibrationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDelegate;
    
    NSTimer *getDataTimer;
    
    IBOutlet UIButton *spinDownButton;
    
    IBOutlet UILabel *targetSpeedLabel;
    IBOutlet UILabel *targetSpinDownTimeLabel;
    IBOutlet UILabel *currentSpeedLabel;
    IBOutlet UILabel *currentTemperatureLabel;
    IBOutlet UILabel *speedConditionLabel;
    IBOutlet UILabel *spinDownCalibrationStatusLabel;
    
    IBOutlet UILabel *spinDownCalibrationResponseLabel;
    IBOutlet UILabel *temperatureResponseLabel;
    IBOutlet UILabel *spinDownTimeResponseLabel;
    
    IBOutlet UITableView *calibrationTableView;
}

-(IBAction)onStartSpinDownCalibrationButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

@end
