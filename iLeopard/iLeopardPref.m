//
//  iLeopardPref.m
//  iLeopard
//
//  Created by Guillaume Campagna on 09-09-22.
//  Copyright (c) 2009 LittleKiwi. All rights reserved.
//

#import "iLeopardPref.h"
#import "WhiteIntermProgIndicator.h"
#import "NSTask+OneLineTasksWithOutput.h"
#import <SecurityFoundation/SFAuthorization.h>

@implementation iLeopardPref

@synthesize pref;
@synthesize checkBoxUpdate;
@synthesize progressIndicatorUpdate;
@synthesize checkForUpdateTextFeild;
@synthesize authorization;
@synthesize isInstalling;
@synthesize indicatorMatrix;
@synthesize progressIndicator;
@synthesize progressTextField;
@synthesize titleTextField;
@synthesize imageOne;
@synthesize imageTwo;
@synthesize options;
@synthesize choseTwo;
@synthesize choseOne;
@synthesize choosedOption;
@synthesize presentOption;
@synthesize installButton;
@synthesize installBox;

- (void)dealloc
{
	[pref release];
	pref = nil;
	
	[super dealloc];
}

- (void) mainViewDidLoad
{
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
		if ([self.pref objectForKey:@"checkForUpdate"] != nil) [self.pref setObject:[NSNumber numberWithBool:YES] forKey:@"checkForUpdate"];
		else if ([[self.pref objectForKey:@"checkForUpdate"] boolValue]) [self.checkBoxUpdate setState:NSOnState];
		else [self.checkBoxUpdate setState:NSOffState];
		
		self.isInstalling = NO;
		
		if ([[self.pref objectForKey:@"installed"] boolValue]) self.installButton.title = NSLocalizedString(@"Uninstall...",);
		else self.installButton.title = NSLocalizedString(@"Install...",);
		
		[self.installBox setAlphaValue:0];
		
		[self.progressIndicator setAnimationDelay:5.0/60.0];
		self.progressIndicator.parentControl = self.indicatorMatrix;
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSLocalDomainMask, YES);
		NSString* applicationSupportPath = [paths objectAtIndex:0];
		
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if ((![fileManager fileExistsAtPath:[applicationSupportPath stringByAppendingPathComponent:@"iLeopard/iLeopardUpdateDeamon.app"]]) || [[self.pref objectForKey:@"reinstallAtLauch"] boolValue]){
			[fileManager createDirectoryAtPath:[applicationSupportPath stringByAppendingPathComponent:@"iLeopard"] withIntermediateDirectories:YES attributes:nil error:nil];
			[fileManager copyItemAtPath:[[NSBundle bundleWithIdentifier:@"com.guillaumecampagna.ileopard"] pathForResource:@"iLeopardUpdateDeamon" ofType:@"app"] 
								 toPath:[applicationSupportPath stringByAppendingPathComponent:@"iLeopard/iLeopardUpdateDeamon.app"] 
								  error:nil];
		}
		
		if ((![fileManager fileExistsAtPath:@"/Library/LaunchAgents/iLeopard.plist"])  && [[self.pref objectForKey:@"checkForUpdate"] boolValue]){
			NSDictionary* lauchdPlist = [[NSDictionary alloc] initWithObjectsAndKeys:@"com.guillaumecampagna.ileopardupdatedeamon", @"label", 
										 [NSNumber numberWithInteger:86400], @"StartInterval", 
										 [NSArray arrayWithObject:@"iLeopard/iLeopardUpdateDeamon.app/Contents/MacOS/iLeopardUpdateDeamon"], @"ProgramArguments", nil];
			[lauchdPlist writeToFile:@"/Library/LaunchAgents/iLeopard.plist" atomically:YES];
			[lauchdPlist release];
		}
		
		[self performSelector:@selector(showUpdateAlert) withObject:nil afterDelay:0.2];
		
		self.presentOption = 0;
	}
	else {
		NSBeginAlertSheet(NSLocalizedString(@"iLeopard required Snow Leopard",), NSLocalizedString(@"OK",), nil, nil, [[self mainView] window]
						  , self, @selector(closePrefPane), nil, nil, NSLocalizedString(@"Please use Snow Leopard",));
		
	}
}

- (void) showUpdateAlert {
	if ([[self.pref objectForKey:@"reinstallAtLauch"] boolValue]) {
		NSBeginAlertSheet(NSLocalizedString(@"iLeopard has been updated",), NSLocalizedString(@"Reinstall",), NSLocalizedString(@"Cancel",), nil, [[self mainView] window]
						  , self, @selector(reinstallConfirmDidEnd:returnCode:contextInfo:), nil, nil, NSLocalizedString(@"Do you want to reinstall iLeopard to take advantage of the new version? All your settings will be kept.",));
	}
}

#pragma mark Actions

- (IBAction) openDonate:(id) sender {
	NSURL* url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7993998"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction) checkForUpdate :(id) sender {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSLocalDomainMask, YES);
	NSString* applicationSupportPath = [paths objectAtIndex:0];
	
	[[NSWorkspace sharedWorkspace] openFile:[applicationSupportPath stringByAppendingPathComponent:@"iLeopard/iLeopardUpdateDeamon.app"]];
	
	[self.progressIndicatorUpdate startAnimation:self];
	[self.checkForUpdateTextFeild setHidden:NO];
	
	[self performSelectorInBackground:@selector(checkFinishUpdate) withObject:nil];
}

- (IBAction) openCredits:(id) sender {
	NSURL* url = [NSURL URLWithString:@"http://littlekiwi.co.cc/LittleKiwi/iLeopard_Credits.html"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction) install:(id) sender {	
	if (![[self.pref objectForKey:@"installed"] boolValue]){
		[self showInstalling:NO];
		[self continueInstall:nil];
	}
	else [self setUninstall];
	
	[[self.installBox animator] setAlphaValue:1];
}

- (IBAction) changeUpdateShedule:(id) sender {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([sender state] == NSOnState) {
		[self.pref setObject:[NSNumber numberWithBool:YES] forKey:@"checkForUpdate"];
		
		if (![fileManager fileExistsAtPath:@"/Library/LaunchAgents/iLeopard.plist"]) {
			NSDictionary* lauchdPlist = [[NSDictionary alloc] initWithObjectsAndKeys:@"com.guillaumecampagna.ileopardupdatedeamon", @"label", 
										 [NSNumber numberWithInteger:86400], @"StartInterval", 
										 [NSArray arrayWithObject:@"iLeopard/iLeopardUpdateDeamon.app/Contents/MacOS/iLeopardUpdateDeamon"], @"ProgramArguments", nil];
			[lauchdPlist writeToFile:@"/Library/LaunchAgents/iLeopard.plist" atomically:YES];
			[lauchdPlist release];
		}
	}
	else {
		[self.pref setObject:[NSNumber numberWithBool:NO] forKey:@"checkForUpdate"];
		if ([fileManager fileExistsAtPath:@"/Library/LaunchAgents/iLeopard.plist"]) [fileManager removeItemAtPath:@"/Library/LaunchAgents/iLeopard.plist" error:nil];
	}
}

- (void) reinstallConfirmDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {
		self.choosedOption = [self.pref objectForKey:@"themeOption"];
		
		for (NSDictionary* option in self.options) {
			NSString* path = [option objectForKey:@"choseOneDestination"];
			NSString* pathTwo = [option objectForKey:@"choseTwoDestination"];
			
			for (NSDictionary* choosed in self.choosedOption) {
				NSString* destination = [choosed objectForKey:@"destination"];
				if (!([path isEqualToString:destination] || [pathTwo isEqualToString:destination])) {
					[self.choosedOption addObject:[NSDictionary dictionaryWithObjectsAndKeys:[option objectForKey:@"choseTwoFileName"], @"fileName", 
												   [option objectForKey:@"choseTwoDestination"], @"destination", nil]];
				}
			}
		}
		
		if ([[self.pref objectForKey:@"installed"] boolValue]) [self setUninstall];
		else [self finishInstall];
	}
	else [self.pref setObject:[NSNumber numberWithBool:NO] forKey:@"reinstallAtLauch"];
}

- (void) logOutConfirmDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {
		NSAppleScript* logoutScript = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to log out"];
		[logoutScript executeAndReturnError:nil];
		[logoutScript release];
	}
}

#pragma mark Getter 

- (NSArray*) options {
	if (options == nil) {
		options = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"com.guillaumecampagna.ileopard"] pathForResource:@"Options" ofType:@"plist"]];
	}
	return options;
}

- (NSMutableArray*) choosedOption {
	if (choosedOption == nil) {
		choosedOption = [[NSMutableArray alloc] initWithCapacity:[self.options count]];
	}
	return choosedOption;
}

#pragma mark Installation

- (IBAction) continueInstall:(id) sender {
	NSDictionary* option = [self.options objectAtIndex:self.presentOption];
	if (sender == self.choseOne) {
		[self.choosedOption addObject:[NSDictionary dictionaryWithObjectsAndKeys:[option objectForKey:@"choseOneFileName"], @"fileName", 
									   [option objectForKey:@"choseOneDestination"], @"destination", nil]];
	}
	else if (sender == self.choseTwo) {
		[self.choosedOption addObject:[NSDictionary dictionaryWithObjectsAndKeys:[option objectForKey:@"choseTwoFileName"], @"fileName", 
									   [option objectForKey:@"choseTwoDestination"], @"destination", nil]];
	}
	
	if (sender != nil) self.presentOption ++;
	if (self.presentOption < [self.options count]) {
		NSDictionary* optionDict = [self.options objectAtIndex:self.presentOption];
		
		self.choseOne.title = [optionDict objectForKey:@"choseOneDescription"];
		self.choseTwo.title = [optionDict objectForKey:@"choseTwoDescription"];
		
		NSString* resourcePath = [[NSBundle bundleWithIdentifier:@"com.guillaumecampagna.ileopard"] resourcePath];
		NSImage* image = [[NSImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:[optionDict objectForKey:@"choseOneImage"]]];
		self.imageOne.image = image;
		[image release];
		
		image = [[NSImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:[optionDict objectForKey:@"choseTwoImage"]]];
		self.imageTwo.image = image;
		[image release];
	}
	
	else {
		[self.pref setObject:[[self.choosedOption copy] autorelease] forKey:@"themeOption"];
		
		[self finishInstall];
	}
}

- (void) finishInstall {
	self.isInstalling = YES;
	
	self.progressTextField.stringValue = NSLocalizedString(@"Installing...",);
	[self showInstalling:YES];
	
	[self performSelectorInBackground:@selector(doInstall) withObject:nil];
}

- (void) doInstall {
	[self autorizeSelf];
	NSError* error = nil;
	
	if (self.authorization != nil) {
		NSString* resourcePath = [[NSBundle bundleWithIdentifier:@"com.guillaumecampagna.ileopard"] resourcePath];
		
		for (NSDictionary* oneOption in self.choosedOption) {			
			NSArray* destinationComponent = [[oneOption objectForKey:@"destination"] componentsSeparatedByString:@","];
			NSArray* pathComponent = [[oneOption objectForKey:@"fileName"] componentsSeparatedByString:@","];
			
			for (NSString* path in pathComponent) {
				NSString* destination = [destinationComponent objectAtIndex:[pathComponent indexOfObject:path]];
				NSString* pathOfResource = [resourcePath stringByAppendingPathComponent:path];
				
				NSArray* arguments = [NSArray arrayWithObjects:@"-f", destination, [destination stringByAppendingString:@".backup"], nil];
				[NSTask stringByLaunchingPath:@"/bin/mv" withArguments:arguments authorization:self.authorization error:&error];
				
				if ([self checkForError: error]) break;
				
				arguments = [NSArray arrayWithObjects: @"-f", pathOfResource, destination, nil];
				[NSTask stringByLaunchingPath:@"/bin/cp" withArguments:arguments authorization:self.authorization error:&error];
				
				if ([self checkForError: error]) break;
			}
			if ([error code] != 0) break;
		}
		
		if ([error code] != 0) [self performSelectorOnMainThread:@selector(installationFailed) withObject:nil waitUntilDone:NO];
		else [self performSelectorOnMainThread:@selector(installationIsFinnished) withObject:nil waitUntilDone:NO];
	}
	else  [self performSelectorOnMainThread:@selector(installationFailed) withObject:nil waitUntilDone:NO];
}

- (void) installationIsFinnished {
	self.isInstalling = NO;
	self.presentOption = 0;
	[self.choosedOption removeAllObjects];
	
	self.installButton.title = NSLocalizedString(@"Uninstall...",);
	[self.pref setObject:[NSNumber numberWithBool:YES] forKey:@"installed"];
	
	[[self.installBox animator] setAlphaValue:0];
	
	NSBeginAlertSheet(NSLocalizedString(@"Do you want to logout?",), NSLocalizedString(@"Log out",), NSLocalizedString(@"Cancel",), nil, [[self mainView] window]
					  , self, @selector(logOutConfirmDidEnd:returnCode:contextInfo:), nil, nil, NSLocalizedString(@"It is recommened to logout after the installation.",));
	
	if ([[self.pref objectForKey:@"reinstallAtLauch"] boolValue]) [self.pref setObject:[NSNumber numberWithBool:NO] forKey:@"reinstallAtLauch"];
}

- (void) installationFailed {
	self.isInstalling = NO;
	[[self.installBox animator] setAlphaValue:0];
	
	self.presentOption = 0;
}

- (void) setUninstall {
	self.isInstalling = YES;
	
	self.progressTextField.stringValue = NSLocalizedString(@"Uninstalling...",);
	[self showInstalling:YES];
	
	[self performSelectorInBackground:@selector(doUninstall) withObject:nil];
}

- (void) doUninstall {
	[self autorizeSelf];
	NSError* error = nil;
	
	if (self.authorization != nil) {
		NSArray* themeOption = [self.pref objectForKey:@"themeOption"];
		
		for (NSDictionary* oneOption in themeOption) {
			NSLog(@"Uninstalling %@", [oneOption objectForKey:@"name"]);
			
			NSArray* destinationComponent = [[oneOption objectForKey:@"destination"] componentsSeparatedByString:@","];
			NSArray* pathComponent = [[oneOption objectForKey:@"fileName"] componentsSeparatedByString:@","];
			
			for (NSString* path in pathComponent) {
				NSString* destination = [destinationComponent objectAtIndex:[pathComponent indexOfObject:path]];
				
				NSArray* arguments = [NSArray arrayWithObjects: @"-f", [destination stringByAppendingString:@".backup"], destination, nil];
				[NSTask stringByLaunchingPath:@"/bin/mv" withArguments:arguments authorization:self.authorization error:&error];
				
				if ([error code] != 0) break;
				
				arguments = [NSArray arrayWithObjects: @"-f", [destination stringByAppendingString:@".backup"], nil];
				[NSTask stringByLaunchingPath:@"/bin/rm" withArguments:arguments authorization:self.authorization error:&error];
				
				if ([error code] != 0) break;
			}
			if ([error code] != 0) break;
		}
		
		if ([error code] != 0) [self performSelectorOnMainThread:@selector(installationFailed) withObject:nil waitUntilDone:NO];
		else [self performSelectorOnMainThread:@selector(uninstallIsFinished) withObject:nil waitUntilDone:NO];
	}
	else  [self performSelectorOnMainThread:@selector(installationFailed) withObject:nil waitUntilDone:NO];
}

- (void) installOrUninstall:(BOOL
bool
- (void) uninstallIsFinished {
	self.isInstalling = NO;
	self.presentOption = 0;
	[self.choosedOption removeAllObjects];
	
	self.installButton.title = NSLocalizedString(@"Install...",);
	[self.pref setObject:[NSNumber numberWithBool:NO] forKey:@"installed"];
	
	if ([[self.pref objectForKey:@"reinstallAtLauch"] boolValue]) [self finishInstall];
	else [[self.installBox animator] setAlphaValue:0];
	
	NSBeginAlertSheet(NSLocalizedString(@"Do you want to logout?",), NSLocalizedString(@"Log out",), NSLocalizedString(@"Cancel",), nil, [[self mainView] window]
					  , self, @selector(logOutConfirmDidEnd:returnCode:contextInfo:), nil, nil, NSLocalizedString(@"It is recommened to logout after the installation.",));
}

#pragma mark Helper

- (void) closePrefPane {
	[self shouldUnselect];
}

- (void) showInstalling:(BOOL) installing {
	[self.progressTextField setHidden:!installing];
	[self.progressIndicator setSpinning:installing];
	[self.indicatorMatrix setHidden:!installing];
	
	[self.choseOne setHidden:installing];
	[self.choseTwo setHidden:installing];
	[self.imageOne setHidden:installing];
	[self.imageTwo setHidden:installing];
	[self.titleTextField setHidden:installing];
}

- (BOOL) autorizeSelf {
	if (self.authorization == nil){
		NSError* error = nil;
		self.authorization = [SFAuthorization authorization];
		[authorization obtainWithRights:NULL flags:kAuthorizationFlagExtendRights environment:NULL authorizedRights:NULL error:&error];
		
		if ([error code] != 0) {
			[[[self mainView] window] presentError:error];
			return NO;
		}
		return YES;
	}
	return YES;
}

- (NSMutableDictionary*) pref {
	if (pref == nil) {
		[self addObserver:self forKeyPath:@"pref" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
		pref = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/Library/Preferences/com.guillaumecampagna.ileopard.plist"];
		if (pref == nil) pref = [[NSMutableDictionary alloc] init];
	}
	return pref;
}

- (void) checkFinishUpdate {
	while ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.guilaumecampagna.ileopardupdatedeamon"] count] != 0) {
		sleep(1);
	}
	[self performSelectorOnMainThread:@selector(finishedUpdateChecking) withObject:nil waitUntilDone:NO];
}

- (BOOL) checkForError: (NSError *) error  {
	if ([error code] != 0) {
		[[[self mainView] window] presentError:error];
		return YES;
	}
	return NO;
}

- (void) finishedUpdateChecking {
	[self.progressIndicatorUpdate stopAnimation:self];
	[self.checkForUpdateTextFeild setHidden:YES];
}

#pragma mark PrefPane

- (NSPreferencePaneUnselectReply)shouldUnselect {
	NSPreferencePaneUnselectReply result = NSUnselectNow;
	
	[self.pref writeToFile:@"/Library/Preferences/com.guillaumecampagna.ileopard.plist" atomically:YES];
	
	if (self.isInstalling) {
		NSBeginAlertSheet(NSLocalizedString(@"iLeopard is installing.",), @"OK", nil, nil, [[self mainView] window] , nil, nil, nil, nil,NSLocalizedString(@"Please close iLeopard after the install.",));
		
		result = NSUnselectLater;
	}
	
	return result;
}

@end