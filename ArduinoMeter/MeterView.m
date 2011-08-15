//
//  MeterView.m
//  Meter
//
/*
 Meters for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Meters for Arduino Copyright (c) 2011, RobotGrrl.com. All rights reserved.
 */

#import "MeterView.h"

@implementation MeterView

@synthesize stick, xPos, xPos2, yPos;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        xPos = 0.0;
        yPos = 0.0;
        
        middle = (frame.size.width/2);
        scale = (frame.size.height/2);
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    float h = dirtyRect.size.height;
    //float w = dirtyRect.size.width;
    
    middle = (dirtyRect.size.width/2);
    scale = h;//sqrt((h*h) + (w*w))/2;
    
    xPos *= scale;
    yPos *= scale;
    
    stick = [NSBezierPath bezierPath];
    [stick setLineWidth:2];
    [stick setLineCapStyle:NSRoundLineCapStyle];
    
    [stick moveToPoint:NSMakePoint(middle, 0.0)];
    [stick lineToPoint:NSMakePoint(middle+xPos, yPos)];
    
    [[NSColor grayColor] set]; 
    [stick stroke];
    
}

- (void) refreshEverything {
    [self setNeedsDisplay:YES];
}

@end
