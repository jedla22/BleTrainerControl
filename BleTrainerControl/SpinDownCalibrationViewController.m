//
//  SpinDownCalibrationViewController.m
//  BleTrainerControl
//
//  Created by William Minol on 04/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import "SpinDownCalibrationViewController.h"

#import "AppDelegate.h"

@interface SpinDownCalibrationViewController ()

@end

@implementation SpinDownCalibrationViewController


#define NB_SECTIONS 3

#define SECTION_PAGE_16 0
#define NB_ROWS_SECTION_PAGE_16 1
#define ROW_PAGE_16_CURRENT_SPEED 0

#define SECTION_PAGE_2 1
#define NB_ROWS_SECTION_PAGE_2 6
#define ROW_PAGE_2_TARGET_SPEED 0
#define ROW_PAGE_2_SPEED_CONDITION 1
#define ROW_PAGE_2_TARGET_SPIN_DOWN_TIME 2
#define ROW_PAGE_2_CURRENT_TEMPERATURE 3
#define ROW_PAGE_2_SPIN_DOWN_CALIBRATION_STATUS 4
#define ROW_PAGE_2_TEMPERATURE_CONDITIONS 5

#define SECTION_PAGE_1 2
#define NB_ROWS_SECTION_PAGE_1 3
#define ROW_PAGE_1_SPIN_DOWN_CALIBRATION_RESPONSE 0
#define ROW_PAGE_1_TEMPERATURE_RESPONSE 1
#define ROW_PAGE_1_SPIN_DOWN_TIME_RESPONSE 2


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(onCloseButton:)] autorelease]];
    
    [calibrationTableView setDelegate:self];
    [calibrationTableView setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    getDataTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshData) userInfo:nil repeats:TRUE];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(getDataTimer != nil)
    {
        //Stop discovery timer
        if([getDataTimer isValid] == TRUE)
            [getDataTimer invalidate];
        
        getDataTimer = nil;
    }
}

-(void)refreshData
{
    if(appDelegate.btleTrainerManager.calibrationStarted == TRUE)
    {
        [spinDownButton setBackgroundColor:[UIColor lightGrayColor]];
        [spinDownButton setEnabled:FALSE];
    }
    else
    {
        [spinDownButton setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [spinDownButton setEnabled:TRUE];
    }
    
    [calibrationTableView reloadData];
    
    /*
    //Calibration in progress
    
    if(appDelegate.btleTrainerManager.targetSpeedKmH == -1)
        [targetSpeedLabel setText:@"-"];
    else
        [targetSpeedLabel setText:[NSString stringWithFormat:@"%0.1f km/h", appDelegate.btleTrainerManager.targetSpeedKmH]];
    
    if(appDelegate.btleTrainerManager.targetSpinDownTimeSeconds == -1)
        [targetSpinDownTimeLabel setText:@"-"];
    else
        [targetSpinDownTimeLabel setText:[NSString stringWithFormat:@"%0.3f s", appDelegate.btleTrainerManager.targetSpinDownTimeSeconds]];
    
    if(appDelegate.btleTrainerManager.speedKmH == -1)
        [currentSpeedLabel setText:@"-"];
    else
        [currentSpeedLabel setText:[NSString stringWithFormat:@"%0.1f km/h", appDelegate.btleTrainerManager.speedKmH]];
    
    if(appDelegate.btleTrainerManager.currentTemperatureDegC == -1)
        [currentTemperatureLabel setText:@"-"];
    else
        [currentTemperatureLabel setText:[NSString stringWithFormat:@"%0.1f °C", appDelegate.btleTrainerManager.currentTemperatureDegC]];
    
    
    if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_NOT_APPLICABLE)
    {
        [speedConditionLabel setText:@"Not applicable"];
        
        [currentSpeedLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [speedConditionLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_CURRENT_SPEED_TOO_LOW)
    {
        [speedConditionLabel setText:@"Current speed too low"];
        
        [currentSpeedLabel setTextColor:[UIColor redColor]];
        [speedConditionLabel setTextColor:[UIColor redColor]];
    }
    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_SPEED_OK)
    {
        [speedConditionLabel setText:@"Speed OK"];
        
        [currentSpeedLabel setTextColor:[UIColor greenColor]];
        [speedConditionLabel setTextColor:[UIColor greenColor]];
    }
    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_RESERVED)
    {
        [speedConditionLabel setText:@"Reserved"];
        
        [currentSpeedLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [speedConditionLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
    else
    {
        [spinDownCalibrationStatusLabel setText:@"-"];
        
        [currentSpeedLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [speedConditionLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
    
    if(appDelegate.btleTrainerManager.spinDownCalibrationStatus == CALIBRATION_STATUS_NOT_REQUESTED)
    {
        [spinDownCalibrationStatusLabel setText:@"Not requested"];
    }
    else if(appDelegate.btleTrainerManager.spinDownCalibrationStatus == CALIBRATION_STATUS_PENDING)
    {
        [spinDownCalibrationStatusLabel setText:@"Pending"];
    }
    else
    {
        [spinDownCalibrationStatusLabel setText:@"-"];
    }
    
    
    //Calibration response
    
    if(appDelegate.btleTrainerManager.spinDownCalibrationResponse == CALIBRATION_RESPONSE_FAILURE_NOT_ATTEMPTED)
    {
        [spinDownCalibrationResponseLabel setText:@"Failure / Not attempted"];
    }
    else if(appDelegate.btleTrainerManager.spinDownCalibrationResponse == CALIBRATION_RESPONSE_SUCCESS)
    {
        [spinDownCalibrationResponseLabel setText:@"Success"];
    }
    else
    {
        [spinDownCalibrationResponseLabel setText:@"-"];
    }
    
    
    if(appDelegate.btleTrainerManager.temperatureResponseDegC == -1)
        [temperatureResponseLabel setText:@"-"];
    else
        [temperatureResponseLabel setText:[NSString stringWithFormat:@"%0.1f °C", appDelegate.btleTrainerManager.temperatureResponseDegC]];
    
    
    if(appDelegate.btleTrainerManager.spinDownTimeResponseSeconds == -1)
        [spinDownTimeResponseLabel setText:@"-"];
    else
        [spinDownTimeResponseLabel setText:[NSString stringWithFormat:@"%0.3f s", appDelegate.btleTrainerManager.spinDownTimeResponseSeconds]];*/
}


-(IBAction)onCloseButton:(id)sender
{
    [super dismissViewControllerAnimated:TRUE completion:nil];
}

-(IBAction)onStartSpinDownCalibrationButton:(id)sender
{
    //Send request for spin-down calibration
    [appDelegate.btleTrainerManager sendCalibrationRequestForSpinDown:TRUE forZeroOffset:FALSE];
}






//TABLE VIEW DELEGATE

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NB_SECTIONS;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_PAGE_16:
            return NB_ROWS_SECTION_PAGE_16;
            break;
        case SECTION_PAGE_2:
            return NB_ROWS_SECTION_PAGE_2;
            break;
        case SECTION_PAGE_1:
            return NB_ROWS_SECTION_PAGE_1;
            break;
        default:
            break;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_PAGE_16:
            return @"Page 16 - General FE data";
            break;
        case SECTION_PAGE_2:
            return @"Page 2 - Calibration in progress";
            break;
        case SECTION_PAGE_1:
            return @"Page 1 - Calibration request and response";
            break;
        default:
            break;
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    [view setTintColor:[UIColor darkGrayColor]];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

//For iOS 6
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Background color
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:0.5]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    //Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        //Init cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    
    //Background color
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:0.5]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    }
    
    
    //Background color label
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    
    
    //No indicator
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    //No selection
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    
    switch (indexPath.section)
    {
        case SECTION_PAGE_16:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_16_CURRENT_SPEED:
                {
                    [cell.textLabel setText:@"Speed"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.1f km/h", appDelegate.btleTrainerManager.speedKmH]];
                    
                    if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_NOT_APPLICABLE)
                    {
                        //[cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_CURRENT_SPEED_TOO_LOW)
                    {
                        [cell.detailTextLabel setTextColor:[UIColor redColor]];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_SPEED_OK)
                    {
                        [cell.detailTextLabel setTextColor:[UIColor greenColor]];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_RESERVED)
                    {
                        //[cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_2:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_2_TARGET_SPEED:
                {
                    [cell.textLabel setText:@"Target speed"];
                    
                    if(appDelegate.btleTrainerManager.targetSpeedKmH == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.1f km/h", appDelegate.btleTrainerManager.targetSpeedKmH]];
                }
                    break;
                case ROW_PAGE_2_SPEED_CONDITION:
                {
                    [cell.textLabel setText:@"Speed conditions"];
                    
                    if(appDelegate.btleTrainerManager.speedCondition == -1)
                    {
                        [cell.detailTextLabel setText:@"-"];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_NOT_APPLICABLE)
                    {
                        [cell.detailTextLabel setText:@"Not applicable"];
                        //[cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_CURRENT_SPEED_TOO_LOW)
                    {
                        [cell.detailTextLabel setText:@"Current speed too low"];
                        [cell.detailTextLabel setTextColor:[UIColor redColor]];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_SPEED_OK)
                    {
                        [cell.detailTextLabel setText:@"Speed OK"];
                        [cell.detailTextLabel setTextColor:[UIColor greenColor]];
                    }
                    else if(appDelegate.btleTrainerManager.speedCondition == SPEED_CONDITION_RESERVED)
                    {
                        [cell.detailTextLabel setText:@"Reserved"];
                        //[cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
                    }
                }
                    break;
                case ROW_PAGE_2_TARGET_SPIN_DOWN_TIME:
                {
                    [cell.textLabel setText:@"Target spin down time"];
                    
                    if(appDelegate.btleTrainerManager.targetSpinDownTimeSeconds == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.3f s", appDelegate.btleTrainerManager.targetSpinDownTimeSeconds]];
                }
                    break;
                case ROW_PAGE_2_CURRENT_TEMPERATURE:
                {
                    [cell.textLabel setText:@"Current temperature"];
                    
                    if(appDelegate.btleTrainerManager.currentTemperatureDegC == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.1f °C", appDelegate.btleTrainerManager.currentTemperatureDegC]];
                }
                    break;
                case ROW_PAGE_2_SPIN_DOWN_CALIBRATION_STATUS:
                {
                    [cell.textLabel setText:@"Spin-down calibration status"];
                    
                    if(appDelegate.btleTrainerManager.spinDownCalibrationStatus == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else if(appDelegate.btleTrainerManager.spinDownCalibrationStatus == CALIBRATION_STATUS_NOT_REQUESTED)
                        [cell.detailTextLabel setText:@"Not requested"];
                    else if(appDelegate.btleTrainerManager.spinDownCalibrationStatus == CALIBRATION_STATUS_PENDING)
                        [cell.detailTextLabel setText:@"Pending"];
                }
                    break;
                case ROW_PAGE_2_TEMPERATURE_CONDITIONS:
                {
                    [cell.textLabel setText:@"Temperature conditions"];
                    
                    if(appDelegate.btleTrainerManager.temperatureCondition == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else if(appDelegate.btleTrainerManager.temperatureCondition == TEMPERATURE_CONDITION_NOT_APPLICABLE)
                        [cell.detailTextLabel setText:@"Not applicable"];
                    else if(appDelegate.btleTrainerManager.temperatureCondition == TEMPERATURE_CONDITION_CURRENT_TEMPERATURE_TOO_LOW)
                        [cell.detailTextLabel setText:@"Current temperature too low"];
                    else if(appDelegate.btleTrainerManager.temperatureCondition == TEMPERATURE_CONDITION_TEMPERATURE_OK)
                        [cell.detailTextLabel setText:@"Temperature OK"];
                    else if(appDelegate.btleTrainerManager.temperatureCondition == TEMPERATURE_CONDITION_CURRENT_TEMPERATURE_TOO_HIGH)
                        [cell.detailTextLabel setText:@"Current temperature too high"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_1:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_1_SPIN_DOWN_CALIBRATION_RESPONSE:
                {
                    [cell.textLabel setText:@"Spin-down calibration request/response"];
                    
                    if(appDelegate.btleTrainerManager.spinDownCalibrationResponse == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else if(appDelegate.btleTrainerManager.spinDownCalibrationResponse == CALIBRATION_RESPONSE_FAILURE_NOT_ATTEMPTED)
                    {
                        [cell.detailTextLabel setTextColor:[UIColor redColor]];
                        [cell.detailTextLabel setText:@"Failure / Not attempted"];
                    }
                    else if(appDelegate.btleTrainerManager.spinDownCalibrationResponse == CALIBRATION_RESPONSE_SUCCESS)
                    {
                        [cell.detailTextLabel setTextColor:[UIColor greenColor]];
                        [cell.detailTextLabel setText:@"Success"];
                    }
                    else
                        [cell.detailTextLabel setText:@"-"];
                }
                    break;
                case ROW_PAGE_1_TEMPERATURE_RESPONSE:
                {
                    [cell.textLabel setText:@"Temperature"];
                    
                    if(appDelegate.btleTrainerManager.temperatureResponseDegC == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.1f °C", appDelegate.btleTrainerManager.temperatureResponseDegC]];
                }
                    break;
                case ROW_PAGE_1_SPIN_DOWN_TIME_RESPONSE:
                {
                    [cell.textLabel setText:@"Spin-down time"];
                    
                    if(appDelegate.btleTrainerManager.spinDownTimeResponseSeconds == -1)
                        [cell.detailTextLabel setText:@"-"];
                    else
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.3f s", appDelegate.btleTrainerManager.spinDownTimeResponseSeconds]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
