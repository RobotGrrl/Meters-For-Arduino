//
//  MeterWindowController.h
//  ArduinoMeter
//
/*
 Meters for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Meters for Arduino Copyright (c) 2011, RobotGrrl.com. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class MeterView, ArduinoMeterAppDelegate;

@interface MeterWindowController : NSWindowController <NSWindowDelegate> {
    
    // App Delegate
    ArduinoMeterAppDelegate *appDelegate;
    
    // Window
    IBOutlet MeterView *mv;
    
    // Variables
    NSNumber *pin;
    NSString *title;
    NSNumber *value;
    
}

@property (nonatomic, retain) NSNumber *pin;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *value;

- (void) refreshEverything;

@end
