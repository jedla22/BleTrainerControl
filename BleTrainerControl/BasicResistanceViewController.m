//
//  BasicResistanceViewController.m
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import "BasicResistanceViewController.h"

#import "AppDelegate.h"

@interface BasicResistanceViewController ()

@end

@implementation BasicResistanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [totalResistanceSlider setMinimumValue:0.0];
    [totalResistanceSlider setMaximumValue:100.0];
    
    //Default values
    [totalResistanceSlider setValue:0.0];
    
    //Display values
    [self onSliderValueChanged:totalResistanceSlider];
    
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(onCloseButton:)] autorelease]];
    
    Utils *utils = [[[Utils alloc] init] autorelease];
    NSArray *buttonsArray = [NSArray arrayWithObjects:sendButton, nil];
    for(UIButton *btn in buttonsArray)
    {
        [btn setBackgroundImage:[utils imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[utils imageWithColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]] forState:UIControlStateNormal];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onCloseButton:(id)sender
{
    [super dismissViewControllerAnimated:TRUE completion:nil];
}

-(IBAction)onSendButton:(id)sender
{
    //Send total resistance for basic resistance mode
    float totalResistanceValue = totalResistanceSlider.value;
    [appDelegate.btleTrainerManager sendBasicResistance:totalResistanceValue];
}


-(IBAction)onSliderValueChanged:(id)sender
{
    [totalResistanceValueLabel setText:[NSString stringWithFormat:@"%0.0f %%", totalResistanceSlider.value]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
