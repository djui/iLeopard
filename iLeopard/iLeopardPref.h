//
//  iLeopardPref.h
//  iLeopard
//
//  Created by Guillaume Campagna on 09-09-22.
//  Copyright (c) 2009 LittleKiwi. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
@class WhiteIntermProgIndicator;
@class SFAuthorization;

@interface iLeopardPref : NSPreferencePane 
{
	NSMutableArray* choosedOption;
	NSArray* options;
	NSUInteger presentOption;
	BOOL isInstalling;
	
	NSButton* installButton;
	NSButton* choseOne;
	NSButton* choseTwo;
	NSButton* checkBoxUpdate;
	NSImageView* imageOne;
	NSImageView* imageTwo;
	NSTextField* titleTextField;
	NSTextField* progressTextField;
	WhiteIntermProgIndicator* progressIndicator;
	NSMatrix* indicatorMatrix;
	NSBox* installBox;
	
	NSTextField* checkForUpdateTextFeild;
	NSProgressIndicator* progressIndicatorUpdate;
	
	SFAuthorization* authorization;
	
	NSMutableDictionary* pref;
}

@property (nonatomic, retain) NSMutableDictionary *pref;
@property (nonatomic, retain) IBOutlet NSButton *checkBoxUpdate;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progressIndicatorUpdate;
@property (nonatomic, retain) IBOutlet NSTextField *checkForUpdateTextFeild;
@property (nonatomic, retain) SFAuthorization *authorization;
@property BOOL isInstalling;
@property (nonatomic, retain) IBOutlet NSMatrix *indicatorMatrix;
@property (nonatomic, retain) IBOutlet WhiteIntermProgIndicator *progressIndicator;
@property (nonatomic, retain) IBOutlet NSTextField *progressTextField;
@property (nonatomic, retain) IBOutlet NSTextField *titleTextField;
@property (nonatomic, retain) IBOutlet NSImageView *imageOne;
@property (nonatomic, retain) IBOutlet NSImageView *imageTwo;
@property (nonatomic, retain) NSArray *options;
@property (nonatomic, retain) IBOutlet NSButton *choseTwo;
@property (nonatomic, retain) IBOutlet NSButton *choseOne;
@property (nonatomic, retain) NSMutableArray *choosedOption;
@property NSUInteger presentOption;
@property (nonatomic, retain) IBOutlet NSBox *installBox;
@property (nonatomic, retain) IBOutlet NSButton *installButton;

- (void) mainViewDidLoad;

//Actions
- (IBAction) openDonate:(id) sender;
- (IBAction) checkForUpdate :(id) sender;
- (IBAction) openCredits:(id) sender;
- (IBAction) install:(id) sender;
- (IBAction) continueInstall:(id) sender;
- (IBAction) changeUpdateShedule:(id) sender;

- (void) reinstallConfirmDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (void) finishInstall;
- (void) installationIsFinnished;
- (void) setUninstall;

- (void) doUninstall;

- (BOOL) autorizeSelf;
- (void) showInstalling:(BOOL) installing;

- (BOOL) checkForError: (NSError *) error;

@end


















