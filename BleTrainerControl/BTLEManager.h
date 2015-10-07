//
//  BTLEManager.h
//  KinomapTrainer
//
//  Created by William Minol on 28/10/2014.
//  Copyright (c) 2014 Excellance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "BTLEConstants.h"

@protocol BTLEManagerDelegate;

@interface BTLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    id <BTLEManagerDelegate> btleManagerDelegate;
    
    CBCentralManager *centralManager;
    NSInteger scanningState;
    NSMutableArray *discoveredPeripheralArray;
    
    CBPeripheral *peripheralSelected;
    
    BOOL needToBeDisconnected;
    
    //NSMutableArray *characteristicsArrayForPeripheral;
}

@property (nonatomic, assign) id <BTLEManagerDelegate> btleManagerDelegate;

@property (nonatomic, retain) CBCentralManager *centralManager;
@property (nonatomic) NSInteger scanningState;
@property (nonatomic, retain) NSMutableArray *discoveredPeripheralArray;
@property (nonatomic, retain) CBPeripheral *peripheralSelected;

-(void)startScanning;
-(void)startScanningWithServicesUUIDArray:(NSArray *)servicesUUIDArray;
-(void)stopScanning;

-(void)addPeripheralToArray:(CBPeripheral *)peripheral;

-(void)retrievePeripheralAndConnectWithUUID:(NSString *)peripheralUUID;
-(void)disconnectPeripheral;

-(void)writeValue:(NSData *)data toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)writeType;
-(void)writeValue:(NSData *)data toCharacteristicUUIDString:(NSString *)characteristicUUIDString;

@end


@protocol BTLEManagerDelegate

@optional
-(void)peripheralIsConnected:(BOOL)isConnected;
-(void)characteristicIsDiscovered:(CBCharacteristic *)characteristic;
-(void)dataReceivedFromPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end