#include <assert.h>

#import "DependencySolver.h"

#import "MissingDependencyException.h"

@implementation DependencySolver
- init
{
	self = [super init];

	@try {
		nodes = [[OFMutableDictionary alloc] init];
		targetOrder = [[OFMutableArray alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[nodes release];
	[targetOrder release];

	[super dealloc];
}

- (void)addTarget: (Target*)target
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	DependencyNode *node;

	node = [[[DependencyNode alloc] initWithTarget: target] autorelease];

	[nodes setObject: node
		  forKey: [target name]];

	[pool release];
}

- (void)solveDependenciesForNode: (DependencyNode*)node
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *enumerator;
	OFString *dependencyName;

	[node visit];

	enumerator = [[[node target] dependencies] objectEnumerator];
	while ((dependencyName = [enumerator nextObject]) != nil) {
		DependencyNode *dependency;

		if ((dependency = [nodes objectForKey: dependencyName]) == nil)
			@throw [MissingDependencyException
			    exceptionWithClass: [self class]
				dependencyName: dependencyName];

		if (![dependency isInTargetOrder])
			[self solveDependenciesForNode: dependency];
	}

	[targetOrder addObject: [node target]];
	[node setInTargetOrder: YES];

	[pool release];
}

- (void)solve
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *enumerator = [nodes objectEnumerator];
	DependencyNode *node;

	while ((node = [enumerator nextObject]) != nil)
		if (![node isInTargetOrder])
			[self solveDependenciesForNode: node];

	[pool release];
}

- (OFArray*)targetOrder
{
	return [[targetOrder copy] autorelease];
}
@end
