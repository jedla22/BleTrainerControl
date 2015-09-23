//
//  BasicResistanceViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface BasicResistanceViewController : UIViewController
{
    AppDelegate *appDelegate;
    
    IBOutlet UILabel *totalResistanceLabel;
    IBOutlet UISlider *totalResistanceSlider;
    IBOutlet UILabel *totalResistanceValueLabel;
    
    IBOutlet UIButton *sendButton;
}

-(IBAction)onSendButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

-(IBAction)onSliderValueChanged:(id)sender;

@end
