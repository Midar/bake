#import "Recipe.h"
#import "Target.h"
#import "WrongVersionException.h"

@implementation Recipe
- init
{
	self = [super init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
		OFDictionary *recipe = [[OFString
		    stringWithContentsOfFile: @"Recipe"] JSONValue];
		id tmp;

		if (![recipe isKindOfClass: [OFDictionary class]])
			@throw [OFInvalidFormatException
			    exceptionWithClass: isa];

		if ((tmp = [recipe objectForKey: @"recipe"]) == nil)
			@throw [OFInvalidFormatException
			    exceptionWithClass: isa];

		if ((tmp = [tmp objectForKey: @"version"]) != nil) {
			if (![tmp isKindOfClass: [OFNumber class]] ||
			    [tmp intValue] != 1)
				// FIXME: Include file name
				@throw [WrongVersionException
				    exceptionWithClass: isa];
		} else
			[of_stderr writeLine: @"Warning: Recipe is lacking a "
					      @"version!"];

		[self populateFromDictionary: recipe];

		if ((tmp = [recipe objectForKey: @"targets"]) != nil &&
		    [tmp isKindOfClass: [OFDictionary class]]) {
			OFEnumerator *keyEnumerator, *objectEnumerator;
			OFString *name;
			OFDictionary *info;
			Target *target;

			targets = [[OFMutableDictionary alloc] init];
			keyEnumerator = [tmp keyEnumerator];
			objectEnumerator = [tmp objectEnumerator];

			while ((name = [keyEnumerator nextObject]) != nil &&
			    (info = [objectEnumerator nextObject]) != nil) {
				if (![info isKindOfClass: [OFDictionary class]])
					continue;

				target = [[[Target alloc] initWithName:
				    name] autorelease];
				[target populateFromDictionary: info];
				[target inheritBuildinfo: self];

				[targets setObject: target
					    forKey: name];
			}
		}

		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[targets release];

	[super dealloc];
}

- (OFDictionary*)targets
{
	return targets;
}
@end
