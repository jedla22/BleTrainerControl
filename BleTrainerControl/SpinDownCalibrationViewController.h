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
    
    IBOutlet UITableView *calibrationTableView;
}

-(IBAction)onStartSpinDownCalibrationButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

@end
