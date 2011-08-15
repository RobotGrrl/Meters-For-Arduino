//
//  MeterWindowController.m
//  ArduinoMeter
//
/*
 Meters for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Meters for Arduino Copyright (c) 2011, RobotGrrl.com. All rights reserved.
 */

#import "MeterWindowController.h"

#import "MeterView.h"
#import "ArduinoMeterAppDelegate.h"

@implementation MeterWindowController

@synthesize pin, title, value;

- (id)initWithWindow:(NSWindow *)window 
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    
    return self;
}

- (void)windowDidLoad {
    appDelegate = (ArduinoMeterAppDelegate *)[[NSApplication sharedApplication] delegate];
    [self.window setTitle:title];
    [super windowDidLoad];
}

- (void) windowWillClose:(NSNotification *)notification {
    [appDelegate closedMeter:[pin intValue]];
}

- (void) refreshEverything {
    
    // Get reading
    int reading = [value intValue];
    
    // Change from linear to angular
    float adjusted = ( (120.0*(1023-reading))/1023.0 ) + 30;
    
    // Convert from deg to rad
    float radians = adjusted*(pi/180);
    
    // Compute x&y locations
    float x = cos(radians);
    float y = sin(radians);
    
    // Update view
    mv.xPos = x;
    mv.yPos = y;
    [mv setNeedsDisplay:YES];
    
}

@end
