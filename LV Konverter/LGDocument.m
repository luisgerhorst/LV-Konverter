//
//  LGDocument.m
//  LV Konverter
//
//  Created by Luis Gerhorst on 11.02.14.
/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Luis Gerhorst
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "LGDocument.h"
#import "LGServiceDirectory.h"
#import "LGErrors.h"


@interface LGDocument ()

@property IBOutlet NSWindow *errorSheet;
@property IBOutlet NSWindow *editWindow;

@property NSFileManager *fileManager;
@property NSDate *fileModificationDateAtLastOpen;

@property NSOpenPanel *chooseApplicationPanel;
@property NSPopUpButton *allowedApplicationsPullDownButton;
@property NSArray *fileURLHandlerURLs;

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

- (IBAction)openFileWith:(id)sender
{
    self.chooseApplicationPanel = [NSOpenPanel openPanel];
    
    self.allowedApplicationsPullDownButton = [[NSPopUpButton alloc] init];
    [self.allowedApplicationsPullDownButton addItemsWithTitles:@[@"Empfohlene Programme", @"Alle Programme"]];
    [self.allowedApplicationsPullDownButton sizeToFit];
    [self.allowedApplicationsPullDownButton setAction:@selector(updateChooseApplicationPanelEnabledURLs)];
    [self.chooseApplicationPanel setAccessoryView:self.allowedApplicationsPullDownButton];
    
    [self.chooseApplicationPanel setDelegate:self];
    [self.chooseApplicationPanel setAllowsMultipleSelection:NO];
    [self.chooseApplicationPanel setAllowedFileTypes:@[@"app"]];
    [self.chooseApplicationPanel setCanChooseDirectories:NO];
    [self.chooseApplicationPanel setDirectoryURL:[self.fileManager URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask][0]];
    NSString *title = [NSString stringWithFormat:@"%@ öffnen mit...", [[self fileURL] lastPathComponent]];
    [self.chooseApplicationPanel setTitle:title];
    [self.chooseApplicationPanel runModal];
    NSURL *choosenApplicationURL = [self.chooseApplicationPanel URLs][0];
    [[NSWorkspace sharedWorkspace] openFile:[[self fileURL] path]
                            withApplication:[choosenApplicationURL path]
                              andDeactivate:YES];
}

- (void)updateChooseApplicationPanelEnabledURLs
{
    // Better way to make the panel recall it's delegate to endable the URLs.
    NSURL *directoryURL = [self.chooseApplicationPanel directoryURL];
    [self.chooseApplicationPanel setDirectoryURL:[NSURL URLWithString:@"/"]];
    [self.chooseApplicationPanel setDirectoryURL:directoryURL];
}

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    if (sender == self.chooseApplicationPanel) { // Comes from chooseApplicationPanel.
        
        // Activate all if "all applications" is selected.
        if (1 == [self.allowedApplicationsPullDownButton indexOfSelectedItem]) {
            return YES;
        }
        
        if (![[NSWorkspace sharedWorkspace] isFilePackageAtPath:[url path]]) {
            return YES;
        }
        
        // Fill known handlers for file type array.
        if (!self.fileURLHandlerURLs) {
            self.fileURLHandlerURLs = (__bridge NSArray *)(LSCopyApplicationURLsForURL((__bridge CFURLRef)([self fileURL]), kLSRolesAll));
        }
        
        // Check if given app is handler for file type.
        for (NSURL *handlerURL in self.fileURLHandlerURLs) {
            if ([url isEqual:handlerURL]) {
                return YES;
            }
        }
        
        return NO;
        
    } else { // If not throw exception.
        @throw [NSException exceptionWithName:@"LGDocument_panel:shouldEnableURL:_Call"
                                       reason:@"Unexpected call with unknown sender to panel:shouldEnableURL:"
                                     userInfo:nil];
        return NO;
    }
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
    [savePanel setAllowedFileTypes:@[@"d83"]];
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
