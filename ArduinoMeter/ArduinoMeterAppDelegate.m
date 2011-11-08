//
//  ArduinoMeterAppDelegate.m
//  ArduinoMeter
//
/*
 Meters for Arduino is licensed under the BSD 3-Clause License
 http://www.opensource.org/licenses/BSD-3-Clause
 
 Meters for Arduino Copyright (c) 2011, RobotGrrl.com. All rights reserved.
 */

#import "ArduinoMeterAppDelegate.h"
#import "MeterWindowController.h"
#import "Wijourno_tags.h"

#define SERVICE_NAME @"MetersForArduino"

@interface ArduinoMeterAppDelegate (Private)
- (void) setButtonsEnabled;
- (void) setButtonsDisabled;
- (void) sendInitialInfo;
- (void) initWijourno;
- (void) resetSetupDict;
- (void) sendSetupData:(NSString *)clientName;
@end

@implementation ArduinoMeterAppDelegate

@synthesize window = _window;
@synthesize setupDict;

- (void)dealloc
{
    [wijourno closeSocket];
    [wijourno release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Init
    [self initWijourno];
    arduino = [[Matatino alloc] initWithDelegate:self];
    allMeters = [[NSMutableArray alloc] initWithCapacity:6];
    debug = NO;
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Setup Dict
    setupDict = [[NSMutableDictionary alloc] initWithCapacity:7];
    [self resetSetupDict];
    
    // Debug
    [arduino setDebug:YES];
    
    // Setup the window
    [serialSelectMenu addItemsWithTitles:[arduino deviceNames]];
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self.window frame];
    [self.window setFrame:NSMakeRect((visibleFrame.size.width - windowFrame.size.width) * 0.5,
                                     (visibleFrame.size.height - windowFrame.size.height) * (9.0/10.0),
                                     windowFrame.size.width, windowFrame.size.height) display:YES];
    
    // Number formatter (for the data)
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if([userDefaults objectForKey:@"Version"] == nil) { // Then it is 1.0!
        NSLog(@"1.0!");
        [userDefaults setObject:[NSNumber numberWithFloat:1.1] forKey:@"Version"];
        [userDefaults setBool:YES forKey:@"Popup"];
    }
    
    BOOL toPopup = [userDefaults boolForKey:@"Popup"];
    
    if(toPopup) {
        // TODO: Display popup here
        [popup makeKeyAndOrderFront:self];
    }
    
}

- (void) initWijourno {
    NSString *serverName = @"MetersServer";
    NSMutableDictionary *serverInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    [serverInfo setObject:serverName forKey:@"name"];
    
    wijourno =  [[Wijourno alloc] init];
    wijourno.delegate = self;
    [wijourno initServerWithServiceName:SERVICE_NAME dictionary:serverInfo];
    
    [serverInfo release];
}

- (void) resetSetupDict {
    
    [self.setupDict setObject:@"0" forKey:@"A0"];
    [self.setupDict setObject:@"0" forKey:@"A1"];
    [self.setupDict setObject:@"0" forKey:@"A2"];
    [self.setupDict setObject:@"0" forKey:@"A3"];
    [self.setupDict setObject:@"0" forKey:@"A4"];
    [self.setupDict setObject:@"0" forKey:@"A5"];
    [self.setupDict setObject:@"0" forKey:@"ArduinoConnected"];
    
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender {
    
    //NSLog(@"Disconnecting...");
    
    // Safely disconnect
    [arduino disconnect];
    [wijourno closeSocket];
    return NSTerminateNow;
}

#pragma mark - Buttons

- (IBAction) donePopupPressed:(id)sender {
    //NSLog([popupEnabled state] ? @"YES" : @"NO");
    [userDefaults setBool:[popupEnabled state] forKey:@"Popup"];    
    [popup close];
}

- (IBAction) learnMorePressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://robotgrrl.com/apps4arduino/meters.php"]];
}

- (IBAction) forIOSPressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://robotgrrl.com/apps4arduino/meters.php"]];
}

- (IBAction) connectPressed:(id)sender {
    
    if(![arduino isConnected]) { // Pressing GO!
        
        if([arduino connect:[serialSelectMenu titleOfSelectedItem] withBaud:B115200]) {
            
            if([pinA0 state] == NSOnState) {
                [self createMeterWithPin:0 andName:@"Analog In - 0"];
                [self.setupDict setObject:@"1" forKey:@"A0"];
            }
            if([pinA1 state] == NSOnState) {
                [self createMeterWithPin:1 andName:@"Analog In - 1"];
                [self.setupDict setObject:@"1" forKey:@"A1"];
            }
            if([pinA2 state] == NSOnState) {
                [self createMeterWithPin:2 andName:@"Analog In - 2"];
                [self.setupDict setObject:@"1" forKey:@"A2"];
            }
            if([pinA3 state] == NSOnState) {
                [self createMeterWithPin:3 andName:@"Analog In - 3"];
                [self.setupDict setObject:@"1" forKey:@"A3"];
            }
            if([pinA4 state] == NSOnState) {
                [self createMeterWithPin:4 andName:@"Analog In - 4"];
                [self.setupDict setObject:@"1" forKey:@"A4"];
            }
            if([pinA5 state] == NSOnState) {
                [self createMeterWithPin:5 andName:@"Analog In - 5"];
                [self.setupDict setObject:@"1" forKey:@"A5"];
            }
            
            [self.setupDict setObject:@"1" forKey:@"ArduinoConnected"];
            [wijourno sendCommand:SETUP dictionary:setupDict];
            
            [self setButtonsDisabled];
            [self.window orderOut:self];
            
        } else {
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:@"Connection Error"];
            [alert setInformativeText:@"Connection failed to start"];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        }
        
    } else { // Pressing Stop
        
        [self resetSetupDict];
        [wijourno sendCommand:SETUP dictionary:setupDict];
        
        [arduino disconnect];
        [self setButtonsEnabled];
        
    }
    
}

- (IBAction) showPrefs:(id)sender {
    
    if([arduino isConnected]) { // Show the buttons as disabled
        [self setButtonsDisabled];
    } else { // Show the buttons as enabled
        [self setButtonsEnabled];
    }
    
    [self.window makeKeyAndOrderFront:self];
    
}

- (IBAction) launchWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://robotgrrl.com/apps4arduino/meters.php"]];
}

- (void) setButtonsEnabled {
    [serialSelectMenu setEnabled:YES];
    [connectButton setTitle:@"GO!"];
    
    [pinA0 setEnabled:YES];
    [pinA1 setEnabled:YES];
    [pinA2 setEnabled:YES];
    [pinA3 setEnabled:YES];
    [pinA4 setEnabled:YES];
    [pinA5 setEnabled:YES];
}

- (void) setButtonsDisabled {
    [serialSelectMenu setEnabled:NO];
    [connectButton setTitle:@"Stop"];
    
    [pinA0 setEnabled:NO];
    [pinA1 setEnabled:NO];
    [pinA2 setEnabled:NO];
    [pinA3 setEnabled:NO];
    [pinA4 setEnabled:NO];
    [pinA5 setEnabled:NO];
}


#pragma mark - Arduino Delegate Methods

- (void) receivedString:(NSString *)rx {
    
    NSArray *dataArray = [[[NSArray alloc] initWithObjects:nil] autorelease];
    NSRange aRange = [rx rangeOfString:@"-"];
    
    // Split the data (after checking that the data is good)
    // --> For some reason there is a bunch of garbled data
    //     that shows up after uploading a sketch to the 
    //     board, so we have to account for that
    if(aRange.location != NSNotFound) {
        dataArray = [rx componentsSeparatedByString:@"-"];
    }
    
    // Make sure there's enough in the array
    if([dataArray count] > 0) {
        
        // Trim the pin value
        NSString *trimmedPinValue = [[dataArray objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Prepare the numbers
        NSNumber *pinNum = [numFormatter numberFromString:[dataArray objectAtIndex:0]];
        NSNumber *pinValue = [numFormatter numberFromString:trimmedPinValue];
        
        // Make sure the data is good, send it to the meter
        if([pinNum intValue] >= 0 && [pinNum intValue] < 6 && [pinValue intValue] >= 0 && [pinValue intValue] <= 1023) {
            [self sendData:pinNum value:pinValue];
        }
        
    }
    
}

- (void) portAdded:(NSArray *)ports {
    
    for(NSString *portName in ports) {
        [serialSelectMenu addItemWithTitle:portName];
    }
    
}

- (void) portRemoved:(NSArray *)ports {
    
    for(NSString *portName in ports) {
        [serialSelectMenu removeItemWithTitle:portName];
    }
    
}

- (void) portClosed {
    
    [self resetSetupDict];
    [wijourno sendCommand:SETUP dictionary:setupDict];
    
    [self setButtonsEnabled];
    [self.window makeKeyAndOrderFront:self];
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Disconnected"];
    [alert setInformativeText:@"Apparently the Arduino was disconnected!"];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
    
}

#pragma makr - Meters

- (void) sendData:(NSNumber *)pinNum value:(NSNumber *)pinValue {
    
    for(MeterWindowController *m in allMeters) {
        if([m.pin intValue] == [pinNum intValue]) {
            m.value = pinValue;
            [m refreshEverything];
            break;
        }
    }

    if(pinValue != nil) {
        NSString *meterKey = [NSString stringWithFormat:@"pin%d", [pinNum intValue]];
        NSMutableDictionary *meterDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        [meterDict setObject:[NSString stringWithFormat:@"%d", [pinValue intValue]] forKey:meterKey];
        [wijourno sendCommand:TEXT dictionary:meterDict];
        [meterDict release];
    }
    
}

- (void) createMeterWithPin:(int)pin andName:(NSString *)name {
    
    BOOL needToCreate = YES;
    
    for(MeterWindowController *m in allMeters) {
        if([m.pin intValue] == pin) { // Then we already have it, no need to create it! Woot!
            needToCreate = NO;
            break;
        }
    }
    
    if(needToCreate) {
        
        // Setup & parameters
        MeterWindowController *newMeter = [[MeterWindowController alloc] initWithWindowNibName:@"MeterWindow"];
        newMeter.pin = [NSNumber numberWithInt:pin];
        newMeter.title = name;
        
        // Positioning
        int count = (int)[allMeters count];
        int row = count%3;
        int col = 0;
        if(count > 2) col = 1;
        
        NSRect windowFrame = [newMeter.window frame];
        int xPos = 100+(windowFrame.size.width*col);
        int yPos = 100+(windowFrame.size.height*row);
        
        [newMeter.window setFrame:NSMakeRect(xPos, yPos, windowFrame.size.width, windowFrame.size.height) display:YES];
        
        // Showtime!
        [newMeter showWindow:self];
        [newMeter.window makeKeyAndOrderFront:self];
        [allMeters addObject:newMeter];
    }
    
}

- (void) closedMeter:(int)pin {
    for(MeterWindowController *m in allMeters) {
        if([m.pin intValue] == pin) {
            // Get rid of it!
            [allMeters removeObject:m];
            break;
        }
    }
}


#pragma mark - Wijourno Data

- (void) sendInitialInfo {
    
    NSMutableDictionary *clientInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    [clientInfo setObject:@"iMac" forKey:@"name"];
    
    [wijourno sendCommand:DATA dictionary:clientInfo];
    [clientInfo release];
}

#pragma mark - Wijourno Delegate

- (void) connectionStarted:(NSString *)host {
    NSLog(@"We connected to host: %@", host);
}

- (void) connectionFinished:(NSString *)details {
    NSLog(@"The connection finished: %@", details);
}

- (void) readTimedOut {
    
}

- (void) didReadCommand:(NSString *)command dictionary:(NSDictionary *)dictionary isServer:(BOOL)isServer {
    
    if(debug) NSLog(@"The server received a command: %@ and dict: %@", command, dictionary);
    
    if([command isEqualToString:DATA]) {
        if(debug) NSLog(@"It was data");
        
        NSString *clientName = [dictionary objectForKey:@"name"];
        [self sendSetupData:clientName];
        
    } else if([command isEqualToString:SETUP]) {
        if(debug) NSLog(@"It was setup");

    } else if([command isEqualToString:ACTION]) {
        if(debug) NSLog(@"It was an action");
        
    } else if([command isEqualToString:TEXT]) {
        if(debug) NSLog(@"It was text");
        
    }
    
}

- (void) sendSetupData:(NSString *)clientName {
    
    if(debug) NSLog(@"Sending setup data to: %@", clientName);
    if(debug) NSLog(@"Setup dict: %@", setupDict);
    
    [wijourno sendCommand:SETUP dictionary:setupDict toClient:clientName];
    
}

@end
