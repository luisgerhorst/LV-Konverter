//
//  LGDocument.h
//  LV Konverter
//
//  Created by Luis Gerhorst on 11.02.14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LGServiceDirectory;

@interface LGDocument : NSDocument
{
    LGServiceDirectory *serviceDirectory;
}

@end
