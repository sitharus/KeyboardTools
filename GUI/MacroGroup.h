//
//  MacroGroup.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MacroSet;

@interface MacroGroup :  NSManagedObject  
{
}

@property (retain) NSString * name;
@property (retain) NSSet* macroSets;
@property (retain) NSSet* applications;

@end

// coalesce these into one @interface MacroGroup (CoreDataGeneratedAccessors) section
@interface MacroGroup (CoreDataGeneratedAccessors)
- (void)addApplicationsObject:(NSManagedObject *)value;
- (void)removeApplicationsObject:(NSManagedObject *)value;
- (void)addApplications:(NSSet *)value;
- (void)removeApplications:(NSSet *)value;

- (void)addMacroSetsObject:(MacroSet *)value;
- (void)removeMacroSetsObject:(MacroSet *)value;
- (void)addMacroSets:(NSSet *)value;
- (void)removeMacroSets:(NSSet *)value;

@end

