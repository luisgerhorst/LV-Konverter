//
//  LGDocument.h
//  LV Konverter
//
//  Created by Luis Gerhorst on 11.02.14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LGServiceDirectory;
@class LGErrors;

@interface LGDocument : NSDocument {}

@property LGServiceDirectory *serviceDirectory;
@property LGErrors *errors;

- (IBAction)save:(id)sender;

@end
