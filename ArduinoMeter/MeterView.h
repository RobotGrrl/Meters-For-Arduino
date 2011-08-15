//
//  MeterView.h
//  Meter
//
/*
 Meters for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Meters for Arduino Copyright (c) 2011, RobotGrrl.com. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

@interface MeterView : NSView {
    
    NSBezierPath *stick;
    float middle;
    float scale;
    
    float xPos;
    float xPos2;
    float yPos;
    
}

@property (nonatomic, retain) NSBezierPath *stick;

@property (assign) float xPos;
@property (assign) float xPos2;
@property (assign) float yPos;

- (void) refreshEverything;

@end
