//
//  AppDelegate.h
//  Stomatick
//
//  Created by TiBounise on 30/12/12.
//  Copyright (c) 2012 TiBounise. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QTKit/QTKit.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    QTMovie *movie;
    NSURL *path;
    NSString *fileName;
    NSImage *image;
    NSDictionary *imageAttributes;
    NSString *savePath;
    int build;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *pathLabel;
@property (assign) IBOutlet NSSlider *fpsSlider;
@property (assign) IBOutlet NSTextField *fpsLabel;
@property (assign) IBOutlet QTMovieView *player;
@property (assign) IBOutlet NSPanel *playerWindow;
@property (assign) IBOutlet NSPanel *progressWindow;
@property (assign) IBOutlet NSProgressIndicator *progressBar;

- (IBAction)pathChoose:(id)sender;
- (IBAction)runAnimation:(id)sender;
- (IBAction)buildAnimation:(id)sender;
- (IBAction)saveAnimation:(id)sender;
- (IBAction)moveFpsSlider:(id)sender;
- (IBAction)cancelBuild:(id)sender;

@end
