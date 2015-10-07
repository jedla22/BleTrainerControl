//
//  TargetPowerViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface TargetPowerViewController : UIViewController
{
    AppDelegate *appDelegate;
    
    IBOutlet UILabel *targetPowerLabel;
    IBOutlet UISlider *targetPowerSlider;
    IBOutlet UILabel *targetPowerValueLabel;
    
    IBOutlet UIButton *sendButton;
}

-(IBAction)onSendButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

-(IBAction)onSliderValueChanged:(id)sender;

@end
