#import "Target.h"
#import "Ingredient.h"

@implementation Target
- init
{
	Class c = [self class];
	[self release];
	@throw [OFNotImplementedException exceptionWithClass: c
						    selector: _cmd];
}

- initWithName: (OFString*)name_
{
	self = [super init];

	@try {
		name = [name_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[name release];

	[super dealloc];
}

- (void)populateFiles: (id)fileList
{
	if ([fileList isKindOfClass: [OFArray class]]) {
		if (files != nil)
			[files addObjectsFromArray: fileList];
		else
			files = [fileList mutableCopy];
	} else if ([fileList isKindOfClass: [OFDictionary class]]) {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
		OFEnumerator *keyEnumerator, *objectEnumerator;
		OFString *dir;
		OFArray *filesInDir;

		if (files == nil)
			files = [[OFMutableArray alloc] init];

		keyEnumerator = [fileList keyEnumerator];
		objectEnumerator = [fileList objectEnumerator];

		while ((dir = [keyEnumerator nextObject]) != nil &&
		    (filesInDir = [objectEnumerator nextObject]) != nil) {
			OFEnumerator *fileEnumerator;
			OFString *file;

			if (![dir isKindOfClass: [OFString class]] ||
			    ![filesInDir isKindOfClass: [OFArray class]])
				continue;

			if ([dir isEqual: @""]) {
				[files addObjectsFromArray: filesInDir];
				continue;
			}

			fileEnumerator = [filesInDir objectEnumerator];

			while ((file = [fileEnumerator nextObject]) != nil) {
				OFString *path = [OFString stringWithPath:
				    dir, file, nil];

				[files addObject: path];
			}
		}

		[pool release];
	}
}

- (void)populateFromDictionary: (OFDictionary*)info
{
	id tmp;

	[super populateFromDictionary: info];

	if ((tmp = [info objectForKey: @"files"]) != nil)
		[self populateFiles: tmp];

	if ((tmp = [info objectForKey: @"dependencies"]) != nil &&
	    [tmp isKindOfClass: [OFArray class]])
		dependencies = [tmp mutableCopy];
}

- (void)resolveConditionals: (OFSet*)conditions
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *enumerator = [conditionals objectEnumerator];
	OFDictionary *dict;

	while ((dict = [enumerator nextObject]) != nil) {
		OFString *condition = [dict objectForKey: @"if"];
		OFDictionary *info = [dict objectForKey: @"then"];

		if (condition == nil || info == nil)
			continue;

		if (![condition isKindOfClass: [OFString class]] ||
		    ![info isKindOfClass: [OFDictionary class]])
			continue;

		if ([conditions containsObject: condition]) {
			Buildinfo *buildinfo;
			OFArray *extraFiles;

			buildinfo = [[[Buildinfo alloc] init] autorelease];
			[buildinfo populateFromDictionary: info];
			[self inheritBuildinfo: buildinfo];

			extraFiles = [info objectForKey: @"files"];
			if (extraFiles != nil)
				[self populateFiles: extraFiles];
		}
	}

	[pool release];
}

- (void)addIngredients
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *enumerator = [ingredients objectEnumerator];
	OFString *ingredientName;

	while ((ingredientName = [enumerator nextObject]) != nil)
		[self inheritBuildinfo:
		    [Ingredient ingredientWithName: ingredientName]];

	[pool release];
}

- (OFString*)name
{
	return name;
}

- (OFArray*)files
{
	return files;
}

- (OFArray*)dependencies
{
	return dependencies;
}
@end
