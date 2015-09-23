//
//  CalibrationViewController.h
//  BleTrainerControl
//
//  Created by William Minol on 04/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface CalibrationViewController : UIViewController
{
    AppDelegate *appDelegate;
    
    IBOutlet UIButton *sendButton;
}

-(IBAction)onSendButton:(id)sender;
-(IBAction)onCloseButton:(id)sender;

@end
