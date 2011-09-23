//
//  MacroApplication.h
//  KeyboardTools
//
//  Created by Phillip Hutchings on 20/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MacroGroup;

@interface MacroApplication : NSManagedObject {

}
@property (nonatomic, retain) MacroGroup * macroGroup;
@property (nonatomic, retain) NSSet* applications;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* identifier;
@property (readonly) NSImage * appIcon;
@end