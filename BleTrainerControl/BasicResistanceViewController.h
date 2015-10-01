//
//  BasicResistanceViewController.h
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
