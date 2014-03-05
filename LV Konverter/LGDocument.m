//
//  LGDocument.m
//  LV Konverter
//
//  Created by Luis Gerhorst on 11.02.14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import "LGDocument.h"
#import "LGServiceDirectory.h"
#import "LGErrors.h"


@interface LGDocument ()

@property IBOutlet NSWindow *errorSheet;
@property IBOutlet NSWindow *editWindow;

@property NSFileManager *fileManager;
@property NSDate *fileModificationDateAtLastOpen;

@end


@implementation LGDocument

- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"LGDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    [self.editWindow setTitle:[[self fileURL] lastPathComponent]];
    
    if ([self.errors errorsExist]) {
        
        if (!self.errorSheet) {
            BOOL success = [[NSBundle mainBundle] loadNibNamed:@"ErrorSheet" owner:self topLevelObjects:nil];
            if (!success) {
                NSLog(@"Error loading ErrorSheet nib from mainBundle.");
                return;
            }
        }
        
        [self.editWindow beginSheet:self.errorSheet completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"Errors sheet returned NSModalResponse %ld", (long)returnCode);
        }];
        
    }
    
}

- (IBAction)openFileWithDefaultApp:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[self fileURL]];
}

- (IBAction)reload:(id)sender
{
    NSDate *oldModificationDate = self.fileModificationDateAtLastOpen;
    
    NSError *error;
    BOOL success = [self openFile:[self fileURL] error:&error];
    if (!success) [[NSAlert alertWithError:error] beginSheetModalForWindow:self.editWindow completionHandler:nil];
    
    if (![self.errors errorsExist]) [self.editWindow endSheet:self.errorSheet];
    
    if ([self.fileModificationDateAtLastOpen isEqualToDate:oldModificationDate]) {
        NSLog(@"Old date %@ new date %@", oldModificationDate, self.fileModificationDateAtLastOpen);
        [[NSAlert alertWithMessageText:@"Sie müssen die Datei speichern damit Änderungen in anderen Programmen hier sichtbar werden."
                         defaultButton:@"OK"
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:@""] runModal];
    }
}

- (IBAction)cancelErrorSheet:(id)sender
{
    [self.editWindow endSheet:self.errorSheet];
    [self close];
    [NSApp terminate:nil];
}

- (IBAction)endErrorSheet:(id)sender
{
    NSError *error;
    BOOL success = [self openFile:[self fileURL] error:&error];
    if (!success) [[NSAlert alertWithError:error] beginSheetModalForWindow:self.editWindow completionHandler:nil];
    
    if ([self.errors errorsExist]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Sind Sie sicher das Sie fortfahren wollen ohne alle Probleme zu beheben?"
                                         defaultButton:@"Fortfahren"
                                       alternateButton:@"Abbrechen"
                                           otherButton:nil
                             informativeTextWithFormat:@"Vor allem als \"Fehler\" eingestufte Probleme sollten Sie unbedingt beheben da sie zu unvollständigen Leistungsverzeichnissen führen können."];
        NSInteger choice = [alert runModal];
        if (NSAlertAlternateReturn == choice) return;
    }
    
    [self.editWindow endSheet:self.errorSheet];
}

- (IBAction)save:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"D83"]];
    [savePanel setExtensionHidden:NO];
    [savePanel setNameFieldStringValue:[[[[self fileURL] URLByDeletingPathExtension] URLByAppendingPathExtension:@"d83"] lastPathComponent]];
    [savePanel setDirectoryURL:[[self fileURL] URLByDeletingLastPathComponent]];
    [savePanel beginSheetModalForWindow:self.editWindow completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSError *saveError;
            BOOL success = [[self.serviceDirectory d83StringAndErrors:nil] writeToURL:[savePanel URL] atomically:YES encoding:NSASCIIStringEncoding error:&saveError];
            if (!success) [[NSAlert alertWithError:saveError] runModal];
        }
        [savePanel orderOut:nil];
        [self close];
        [NSApp terminate:nil];
    }];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

// Fully overrides the instance variables with the data of the file. Parses and converts the file to D83, saves problems.
// Return value indicates if there was a problem with the file, not if there were problems parsing the file.
// Problems are presented in -saveDocument:
- (BOOL)openFile:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    self.fileModificationDateAtLastOpen = [self.fileManager attributesOfItemAtPath:[url path] error:nil][NSFileModificationDate];
    
    // Read file into string.
    NSString *csvString = [NSString stringWithContentsOfURL:url usedEncoding:nil error:outError];
    if (!csvString) return NO;
    
    // Create Model.
    LGErrors *parsingErrors = [[LGErrors alloc] init];
    self.serviceDirectory = [LGServiceDirectory serviceDirectoryWithCSVString:csvString errors:parsingErrors]; // Return nil and save problem on fatal error.
    self.errors = parsingErrors;
    
    if (self.serviceDirectory) { // May be nil if fatal problem occured.
        // Get errors when saving model as D83 string.
        LGErrors *exportErrors = [[LGErrors alloc] init];
        [self.serviceDirectory d83StringAndErrors:exportErrors];
        [self.errors addErrors:exportErrors];
    }
    
    return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if ([typeName isEqualToString:@"CSV"]) return [self openFile:url error:outError];
    else return NO;
}

@end
