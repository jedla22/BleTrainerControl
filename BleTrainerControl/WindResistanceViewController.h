//
//  WindResistanceViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface WindResistanceViewController : UIViewController
{
    AppDelegate *appDelegate;
    
    IBOutlet UILabel *windResistanceCoefficientLabel;
    IBOutlet UISlider *windResistanceCoefficientSlider;
    IBOutlet UILabel *windResistanceCoefficientValueLabel;
    
    IBOutlet UILabel *windSpeedLabel;
    IBOutlet UISlider *windSpeedSlider;
    IBOutlet UILabel *windSpeedValueLabel;
    
    IBOutlet UILabel *draftingFactorLabel;
    IBOutlet UISlider *draftingFactorSlider;
    IBOutlet UILabel *draftingFactorValueLabel;
    
    IBOutlet UIButton *sendButton;
}

-(IBAction)onSendButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

-(IBAction)onSliderValueChanged:(id)sender;

@end
