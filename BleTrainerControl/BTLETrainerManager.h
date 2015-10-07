//
//  BTLETrainerManager.h
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

#import <Foundation/Foundation.h>

#import "BTLEManager.h"

#import "Utils.h"

//Calibration status
#define CALIBRATION_STATUS_NOT_REQUESTED 0
#define CALIBRATION_STATUS_PENDING 1

//Calibration conditions
#define TEMPERATURE_CONDITION_NOT_APPLICABLE 0
#define TEMPERATURE_CONDITION_CURRENT_TEMPERATURE_TOO_LOW 1
#define TEMPERATURE_CONDITION_TEMPERATURE_OK 10
#define TEMPERATURE_CONDITION_CURRENT_TEMPERATURE_TOO_HIGH 11

#define SPEED_CONDITION_NOT_APPLICABLE 0
#define SPEED_CONDITION_CURRENT_SPEED_TOO_LOW 1
#define SPEED_CONDITION_SPEED_OK 10
#define SPEED_CONDITION_RESERVED 11

//Calibration response
#define CALIBRATION_RESPONSE_FAILURE_NOT_ATTEMPTED 0
#define CALIBRATION_RESPONSE_SUCCESS 1

@interface BTLETrainerManager : NSObject <BTLEManagerDelegate>
{
    BTLEManager *manager;
    
    Utils *utils;
    
    BOOL calibrationStarted;

    //Page 1
    NSInteger zeroOffsetCalibrationResponse;
    NSInteger spinDownCalibrationResponse;
    float temperatureResponseDegC;
    NSInteger zeroOffsetResponse;
    float spinDownTimeResponseSeconds;
    
    //Page 2
    NSInteger zeroOffsetCalibrationStatus;
    NSInteger spinDownCalibrationStatus;
    NSInteger temperatureCondition;
    NSInteger speedCondition;
    float currentTemperatureDegC;
    float targetSpeedKmH;
    float targetSpinDownTimeSeconds;
    
    //Page 16
    float elapsedTimeSeconds;
    NSInteger distanceTraveledMeters;
    float speedKmH;
    NSInteger heartRateBPM;
    NSInteger equipmentType;
    NSString *equipmentTypeString;
    BOOL virtualSpeed;
    
    //Page 17
    float cycleLengthM;
    float inclinePercent;
    float resistanceLevelPercent;
    
    //Page 25
    NSInteger updateEventCount;
    NSInteger cadenceRPM;
    NSInteger accumulatedPowerW;
    NSInteger powerW;
    
    //Page 48
    float totalResistancePercent;
    
    //Page 49
    float targetPowerW;
    
    //Page 50
    float windResistanceCoefficientKgM;
    float windSpeedKmH;
    float draftingFactor;
    
    //Page 51
    float gradePercent;
    float rollingResistanceCoefficient;
    
    //Page 54
    NSInteger maximumResistanceN;
    NSString *supportedMode;
    
    //Page 55
    float userWeightKg;
    NSInteger bicycleWheelDiameterOffsetMm;
    float bicycleWeightKg;
    float bicycleWheelDiameterM;
    float gearRatio;
    
    //Page 71
    NSInteger lastReceivedCommandID;
    NSInteger sequence;
    NSInteger commandStatus;
    NSString *commandStatusString;
    NSString *dataString;
    
    //Page 80
    NSInteger hwRevision;
    NSInteger manufacturerID;
    NSInteger modelNumber;
    
    //Page 81
    NSInteger swRevisionSupplemental;
    NSInteger swRevisionMain;
    NSInteger serialNumber;
}

@property BOOL calibrationStarted;

//Page 1
@property NSInteger zeroOffsetCalibrationResponse;
@property NSInteger spinDownCalibrationResponse;
@property float temperatureResponseDegC;
@property NSInteger zeroOffsetResponse;
@property float spinDownTimeResponseSeconds;

//Page 2
@property NSInteger zeroOffsetCalibrationStatus;
@property NSInteger spinDownCalibrationStatus;
@property NSInteger temperatureCondition;
@property NSInteger speedCondition;
@property float currentTemperatureDegC;
@property float targetSpeedKmH;
@property float targetSpinDownTimeSeconds;

//Page 16
@property float elapsedTimeSeconds;
@property NSInteger distanceTraveledMeters;
@property float speedKmH;
@property NSInteger heartRateBPM;
@property NSInteger equipmentType;
@property (nonatomic, retain) NSString *equipmentTypeString;
@property BOOL virtualSpeed;

//Page 17
@property float cycleLengthM;
@property float inclinePercent;
@property float resistanceLevelPercent;

//Page 25
@property NSInteger updateEventCount;
@property NSInteger cadenceRPM;
@property NSInteger accumulatedPowerW;
@property NSInteger powerW;

//Page 48
@property float totalResistancePercent;

//Page 49
@property float targetPowerW;

//Page 50
@property float windResistanceCoefficientKgM;
@property float windSpeedKmH;
@property float draftingFactor;

//Page 51
@property float gradePercent;
@property float rollingResistanceCoefficient;

//Page 54
@property NSInteger maximumResistanceN;
@property (nonatomic, retain) NSString *supportedMode;

//Page 55
@property float userWeightKg;
@property NSInteger bicycleWheelDiameterOffsetMm;
@property float bicycleWeightKg;
@property float bicycleWheelDiameterM;
@property float gearRatio;

//Page 71
@property NSInteger lastReceivedCommandID;
@property NSInteger sequence;
@property NSInteger commandStatus;
@property (nonatomic, retain) NSString *commandStatusString;
@property (nonatomic, retain) NSString *dataString;

//Page 80
@property NSInteger hwRevision;
@property NSInteger manufacturerID;
@property NSInteger modelNumber;

//Page 81
@property NSInteger swRevisionSupplemental;
@property NSInteger swRevisionMain;
@property NSInteger serialNumber;







-(void)startScanningAll;
-(void)startScanning;
-(void)stopScanning;

-(NSMutableArray *)getDiscoveredPeripheralArray;
-(NSInteger)getScanningState;
-(BOOL)isConnected;

-(void)connectWithUUID:(NSString *)UUIDToConnect;
-(void)disconnect;



//Control data pages
-(void)sendBasicResistance:(float)totalResistancePercentValue;
-(void)sendTargetPower:(float)targetPowerWValue;
-(void)sendWindResistanceCoefficient:(float)windResistanceCoefficientKgMValue windSpeed:(float)windSpeedKmHValue draftingFactor:(float)draftingFactorValue;
-(void)sendTrackResistanceWithGrade:(float)gradePercentValue rollingResistanceCoefficient:(float)rollingResistanceCoefficienValuet;

//Request page
-(void)sendRequestPage:(NSInteger)page;

//Calibration
-(void)sendCalibrationRequestForSpinDown:(BOOL)forSpinDown forZeroOffset:(BOOL)forZeroOffset;

@end
