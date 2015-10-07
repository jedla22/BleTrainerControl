//
//  TrackResistanceViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface TrackResistanceViewController : UIViewController
{
    AppDelegate *appDelegate;
    
    IBOutlet UILabel *gradeLabel;
    IBOutlet UISlider *gradeSlider;
    IBOutlet UILabel *gradeValueLabel;
    
    IBOutlet UILabel *coefficentOfRollingResistanceLabel;
    IBOutlet UISlider *coefficentOfRollingResistanceSlider;
    IBOutlet UILabel *coefficentOfRollingResistanceValueLabel;
    
    IBOutlet UIButton *sendButton;
    
    IBOutlet UISwitch *maxRangeSwitch;
}

-(IBAction)onSendButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

-(IBAction)onSliderValueChanged:(id)sender;

-(IBAction)onMaxRangeSwitchValueChanged:(id)sender;

@end
