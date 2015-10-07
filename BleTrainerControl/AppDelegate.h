//
//  AppDelegate.h
//  BleTrainerControl
//
//  Created by William Minol on 23/09/2015.
//  Copyright © 2015 Kinomap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ViewController.h"

#import "BTLETrainerManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BTLETrainerManager *btleTrainerManager;
}

@property (nonatomic, retain) BTLETrainerManager *btleTrainerManager;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

