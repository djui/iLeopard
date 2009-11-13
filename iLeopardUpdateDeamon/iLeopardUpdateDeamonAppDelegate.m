//
//  iLeopardUpdateDeamonAppDelegate.m
//  iLeopardUpdateDeamon
//
//  Created by Guillaume Campagna on 09-09-26.
//  Copyright 2009 LittleKiwi. All rights reserved.
//

#import "iLeopardUpdateDeamonAppDelegate.h"
#import <Sparkle/Sparkle.h>

@implementation iLeopardUpdateDeamonAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	SUUpdater* updater;
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/PreferencePanes/iLeopard.prefPane"]) {
		updater = [SUUpdater updaterForBundle:[NSBundle bundleWithPath:@"/Library/PreferencePanes/iLeopard.prefPane"]];
	}	
	else {
		updater = [SUUpdater updaterForBundle:[NSBundle bundleWithPath:[@"~/Library/PreferencePanes/iLeopard.prefPane" stringByExpandingTildeInPath]]];
	}
	updater.delegate = self;
	[updater checkForUpdates:self];
}

#pragma mark SUUpdaterDelegate

- (void)updaterDidNotFindUpdate:(SUUpdater *)update {
	[NSApp terminate:self];
}

- (void)updaterWillRelaunchApplication:(SUUpdater *)updater {
	NSMutableDictionary* pref = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/Library/Preferences/com.guillaumecampagna.ileopard.plist"];
	[pref setObject:[NSNumber numberWithBool:YES] forKey:@"reinstallAtLauch"];
	[pref writeToFile:@"/Library/Preferences/com.guillaumecampagna.ileopard.plist" atomically:YES];
	
	NSArray* arrayOfSysPref = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.systempreferences"];
	NSRunningApplication* sysPref = nil;
	if ([arrayOfSysPref count] != 0) sysPref = [arrayOfSysPref objectAtIndex:0];
	[sysPref terminate];
}


@end
