//
//  LGDocument.m
//  LV Konverter
//
//  Created by Luis Gerhorst on 11.02.14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import "LGDocument.h"
#import "LGServiceDirectory.h"

@implementation LGDocument

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"LGDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    [self saveDocument:nil];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (void)saveDocument:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"D83"]];
    [savePanel setExtensionHidden:NO];
    [savePanel setNameFieldStringValue:[[[[self fileURL] URLByDeletingPathExtension] URLByAppendingPathExtension:@"d83"] lastPathComponent]];
    [savePanel setDirectoryURL:[[self fileURL] URLByDeletingLastPathComponent]];
    [savePanel beginWithCompletionHandler:^(NSInteger result) {
        NSURL *url = [savePanel URL];
        NSLog(@"Panel ended with result %ld and URL %@", (long)result, url);
        if (result == NSFileHandlingPanelOKButton) {
            NSLog(@"Saving to url.");
            @try {
                [[serviceDirectory d83String] writeToURL:url atomically:YES encoding:NSASCIIStringEncoding error:nil];
            } @catch (NSException *exception) {
                NSLog(@"Error saving as D83: %@", exception);
            }
        }
        [savePanel orderOut:nil];
        [self close];
    }];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSLog(@"Open doc with type %@", typeName);
    if ([typeName isEqualToString:@"CSV"]) {
        @try {
            serviceDirectory = [LGServiceDirectory serviceDirectoryWithCSVString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]; // Set instance var problems to problems while parsing.
            return YES;
        } @catch (NSException *exception) {
            NSLog(@"Error parsing data: %@", exception);
            return NO;
        }
    }
    return NO;
}

@end
