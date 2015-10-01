//
//  BTLEConstants.h
//  KinomapTrainer
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

#ifndef KinomapTrainer_BTLEConstants_h
#define KinomapTrainer_BTLEConstants_h

//Scanning state
#define BTLE_SCANNING_STATE_STOPPED 0
#define BTLE_SCANNING_STATE_STARTED 1




////////////////////////////////////////////////
//////BTLE SERVICE AND CHARACTERISTICS////////
////////////////////////////////////////////

//BTLE services and characteristics
#define SERVICE_CYCLING_POWER @"1818"
#define CHARACTERISTIC_CYCLING_POWER_MEASUREMENT @"2A63"
#define CHARACTERISTIC_CYCLING_POWER_FEATURE @"2A65"
#define CHARACTERISTIC_CYCLING_POWER_CONTROL_POINT @"2A66"
#define CHARACTERISTIC_SENSOR_LOCATION @"2A5D"

#define SERVICE_DEVICE_INFORMATION @"180A"
#define CHARACTERISTIC_MODEL_NUMBER_STRING @"2A24"
#define CHARACTERISTIC_FIRMWARE_REVISION_STRING @"2A26"
#define CHARACTERISTIC_HARDWARE_REVISTION_STRING @"2A27"
#define CHARACTERISTIC_SOFTWARE_REVISTION_STRING @"2A28"
#define CHARACTERISTIC_MANUFACTURER_NAME_STRING @"2A29"
#define CHARACTERISTIC_PNP_ID @"2A50"

////////////////////////////////////////////
//////BTLE SERVICE AND CHARACTERISTICS////////
////////////////////////////////////////////////



///////////////////////////////////
////////////TAXC FE-C///////////
/////////////////////////////

//Tacx FE-C service and characteristics
#define TACX_FEC_PRIMARY_SERVICE @"6E40FEC1-B5A3-F393-E0A9-E50E24DCCA9E"
//Pour détecter le Vortex
//#define TACX_FEC_PRIMARY_SERVICE @"669AA305-0C08-969E-E211-86AD5062675F"


#define TACX_FEC_READ_CHARACTERISTIC @"6E40FEC2-B5A3-F393-E0A9-E50E24DCCA9E"
#define TACX_FEC_WRITE_CHARACTERISTIC @"6E40FEC3-B5A3-F393-E0A9-E50E24DCCA9E"

/////////////////////////////
////////////TAXC FE-C///////////
///////////////////////////////////


#endif
