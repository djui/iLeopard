//
//  iLeopardUpdateDeamonAppDelegate.h
//  iLeopardUpdateDeamon
//
//  Created by Guillaume Campagna on 09-09-26.
//  Copyright 2009 LittleKiwi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iLeopardUpdateDeamonAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
