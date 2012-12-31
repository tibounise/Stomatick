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

- (void)dealloc {
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    path = nil;
    build = 1;
}

- (IBAction)pathChoose:(id)sender {
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanCreateDirectories:NO];
    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton) {
        path = [[[openDlg URLs] objectAtIndex: 0] retain];
    }
    [pathLabel setStringValue:[path path]];
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
    }
}

- (IBAction)buildAnimation:(id)sender {
    build = 1;
    NSError *error = nil;
    if (movie != nil) {
        [movie release];
        movie = nil;
    }
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMan contentsOfDirectoryAtPath:[path path] error:&error];
    if (error != nil) {
        [[NSAlert alertWithError:error] runModal];
        return;
    }
    NSArray *allowedExtension = [NSImage imageTypes];
    NSMutableArray *usedFiles = [NSMutableArray array];
    for(int index=0;index < fileArray.count;index++) {
        fileName = [fileArray objectAtIndex:index];
        
        if([allowedExtension indexOfObject:(NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(CFStringRef)[fileName pathExtension],NULL)] != NSNotFound) {
            [usedFiles addObject:fileName];
        } else {
            NSLog(@"Deny %@",fileName);
        }
    }
    if (usedFiles.count == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:@"Not enough files"];
        [alert setInformativeText:@"Not enough files have been provided to build an animation."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    [progressWindow makeKeyAndOrderFront:0];
    [progressBar startAnimation:0];
    [progressBar setUsesThreadedAnimation:YES];
    [progressBar setMinValue:0];
    [progressBar setMaxValue:usedFiles.count];
    [progressBar setDoubleValue:0];
    [usedFiles sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    movie = [[QTMovie alloc] initToWritableData:[NSMutableData data] error:&error];
    QTTime time = QTMakeTime(1,[fpsSlider integerValue]);
    imageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:@"jpeg",QTAddImageCodecType, nil];
    for (int i = 0; i < usedFiles.count; i++) {
        if (build == 0) {
            [progressBar stopAnimation:0];
            [progressWindow close];
            [movie release];
            movie = nil;
            return;
        }
        NSString *fileLocation = [NSString stringWithFormat:@"%@/%@",[path path],[usedFiles objectAtIndex:i]];
        image = [[[NSImage alloc] initByReferencingFile:fileLocation] autorelease];
        [movie addImage:image forDuration:time withAttributes:imageAttributes];
        [movie setCurrentTime:[movie duration]];
        [progressBar setDoubleValue:i];
    }
    [progressBar stopAnimation:0];
    [progressWindow close];
}

- (IBAction)saveAnimation:(id)sender {
    if (movie == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:@"No animation built"];
        [alert setInformativeText:@"No animation has been built. Please build it."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setRequiredFileType:@"mov"];
    if ([savePanel runModal] == NSOKButton) {
        [movie writeToFile:[savePanel filename] withAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:QTMovieFlatten] error:nil];
    }
}

- (IBAction)moveFpsSlider:(id)sender {
    [fpsLabel setStringValue:[NSString stringWithFormat:@"%d fps",[fpsSlider integerValue]]];
}

- (IBAction)cancelBuild:(id)sender {
    build = 0;
}
@end
