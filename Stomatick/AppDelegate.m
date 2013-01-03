//
//  AppDelegate.m
//  Stomatick
//
//  Created by TiBounise on 30/12/12.
//  Copyright (c) 2012 TiBounise. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize pathLabel;
@synthesize fpsSlider;
@synthesize fpsLabel;
@synthesize player;
@synthesize playerWindow;
@synthesize progressWindow;
@synthesize progressBar;
@synthesize runButton;
@synthesize buildButton;
@synthesize saveButton;
@synthesize pathButton;

- (void)dealloc {
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    path = nil;
    [saveButton setEnabled:NO];
    [runButton setEnabled:NO];
    [buildButton setEnabled:YES];
    [fpsSlider setEnabled:YES];
    [pathButton setEnabled:YES];
}

- (IBAction)pathChoose:(id)sender {
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanCreateDirectories:NO];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
        path = [[[openDlg URLs] objectAtIndex: 0] retain];
        [pathLabel setStringValue:[path path]];
    }
}

- (IBAction)runAnimation:(id)sender {
    if (movie != nil) {
        [player setMovie:movie];
        [player setNeedsDisplay:YES];
        [playerWindow makeKeyAndOrderFront:0];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:@"No animation built"];
        [alert setInformativeText:@"No animation has been built. Please build it."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    }
}

- (IBAction)buildAnimation:(id)sender {
    buildThread = [[NSThread alloc] initWithTarget:self selector:@selector(buildProcess) object:nil];
    [buildThread start];
}

-(void)buildProcess {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Disable some buttons that may interfere during the build
    [buildButton setEnabled:NO];
    [saveButton setEnabled:NO];
    [runButton setEnabled:NO];
    [fpsSlider setEnabled:NO];
    [pathButton setEnabled:NO];

    NSError *error = nil;
    
    if (movie != nil) {
        [movie release];
        movie = nil;
    }
    
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMan contentsOfDirectoryAtPath:[path path] error:&error];
    
    if (error != nil) {
        [[NSAlert alertWithError:error] runModal];
    } else {
    
        NSArray *allowedExtension = [NSImage imageTypes];
        NSMutableArray *usedFiles = [NSMutableArray array];
        
        // Verify all files, we must only use files that can be loaded to a NSImage 
        for (NSString *fileName in fileArray) {
            NSString *identifier = (NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(CFStringRef)[fileName pathExtension],NULL);
            
            if([allowedExtension indexOfObject:identifier] != NSNotFound) {
                [usedFiles addObject:fileName];
            } else {
                NSLog(@"Deny %@",fileName);
            }
            [identifier release];
        }
        
        // We need at least 1 file
        if (usedFiles.count == 0) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Close"];
            [alert setMessageText:@"Not enough files"];
            [alert setInformativeText:@"Not enough files have been provided to build an animation."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
        } else {
        
            // Show the progress window
            [progressWindow makeKeyAndOrderFront:0];
            
            // Initialize the progress bar
            [progressBar startAnimation:0];
            [progressBar setUsesThreadedAnimation:YES];
            [progressBar setMinValue:0];
            [progressBar setMaxValue:usedFiles.count];
            [progressBar setDoubleValue:0];
            
            [usedFiles sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            movie = [[QTMovie alloc] initToWritableData:[NSMutableData data] error:&error];
            
            imageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:@"jpeg",QTAddImageCodecType, nil];
            
            QTTime time = QTMakeTime(1,[fpsSlider integerValue]);
            
            int i = 0;
            
            while (![buildThread isCancelled] && i < usedFiles.count) {
                NSString *fileLocation = [NSString stringWithFormat:@"%@/%@",[path path],[usedFiles objectAtIndex:i]];
                image = [[[NSImage alloc] initByReferencingFile:fileLocation] autorelease];
                [movie addImage:image forDuration:time withAttributes:imageAttributes];
                [progressBar setDoubleValue:i];
                i++;
            }
            
            // If we have cancelled the build
            if ([buildThread isCancelled]) {
                [movie release];
                movie = nil;
            } else {
                [movie setCurrentTime:[movie duration]];
                [saveButton setEnabled:YES];
                [runButton setEnabled:YES];
            }

        }
        
    }
   
    // Closes the progress window
    [progressBar stopAnimation:0];
    [progressWindow close];

    // Re-activate some buttons & sliders
    [buildButton setEnabled:YES];
    [fpsSlider setEnabled:YES];
    [pathButton setEnabled:YES];
    
    [pool release];
}

- (IBAction)saveAnimation:(id)sender {
    if (movie == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:@"No animation built"];
        [alert setInformativeText:@"No animation has been built. Please build it."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    } else {
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        [savePanel setRequiredFileType:@"mov"];
        if ([savePanel runModal] == NSOKButton) {
            [movie writeToFile:[savePanel filename] withAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:QTMovieFlatten] error:nil];
        }
    }
}

- (IBAction)moveFpsSlider:(id)sender {
    [fpsLabel setStringValue:[NSString stringWithFormat:@"%d fps",[fpsSlider integerValue]]];
}

- (IBAction)cancelBuild:(id)sender {
    [buildThread cancel];
}
@end
