//
//  MacroSet.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MacroGroup.h"
#import "Macro.h"

@interface MacroSet : NSManagedObject {
	
}
@property (nonatomic, retain) MacroGroup * macroGroup;
@property (nonatomic, retain) NSSet* macroSets;
@property (nonatomic, retain) MacroSet * macroSet;
@property (nonatomic, retain) NSSet* macros;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSNumber* macroIndex;

- (NSComparisonResult)compareSetToSet:(MacroSet *)other;
@end

// coalesce these into one @interface MacroSet (CoreDataGeneratedAccessors) section
@interface MacroSet (CoreDataGeneratedAccessors)
- (void)addMacroSetsObject:(MacroSet *)value;
- (void)removeMacroSetsObject:(MacroSet *)value;
- (void)addMacroSets:(NSSet *)value;
- (void)removeMacroSets:(NSSet *)value;

- (void)addMacrosObject:(Macro *)value;
- (void)removeMacrosObject:(Macro *)value;
- (void)addMacros:(NSSet *)value;
- (void)removeMacros:(NSSet *)value;

@end



