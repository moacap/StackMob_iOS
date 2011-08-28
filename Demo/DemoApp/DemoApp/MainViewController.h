//
//  MainViewController.h
//  DemoApp
//
//  Created by Josh Stephenson on 8/27/11.
//  Copyright (c) 2011 StackMob Inc. All rights reserved.
//

#import "FlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)showInfo:(id)sender;

@end
