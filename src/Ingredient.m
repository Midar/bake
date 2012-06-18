#import "Ingredient.h"

#import "MissingIngredientException.h"
#import "WrongVersionException.h"

// FIXME
#define INGREDIENTS_DIR @"/usr/local/libdata/bake/ingredients"

static OFMutableDictionary *ingredients = nil;

@implementation Ingredient
+ ingredientWithName: (OFString*)name
{
	OFAutoreleasePool *pool;
	Ingredient *ingredient;
	OFString *path;

	if (ingredients == nil)
		ingredients = [[OFMutableDictionary alloc] init];

	if ((ingredient = [ingredients objectForKey: name]) != nil)
		return ingredient;

	pool = [[OFAutoreleasePool alloc] init];

	if ((path = [Ingredient findIngredient: name]) == nil)
		@throw [MissingIngredientException exceptionWithClass: self
						       ingredientName: name];

	ingredient = [[[Ingredient alloc] initWithFile: path] autorelease];
	[ingredients setObject: ingredient
			forKey: name];

	[pool release];

	return ingredient;
}

+ findIngredient: (OFString*)name
{
	OFString *path;

	name = [name stringByAppendingString: @".ingredient"];

	path = [OFString stringWithPath: @"ingredients", name, nil];
	if ([OFFile fileExistsAtPath: path])
		return path;

	path = [OFString stringWithPath: INGREDIENTS_DIR, name, nil];
	if ([OFFile fileExistsAtPath: path])
		return path;

	return nil;
}

- initWithFile: (OFString*)file
{
	self = [super init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
		OFDictionary *ingredient = [[OFString
		    stringWithContentsOfFile: file] JSONValue];
		id tmp;

		if (![ingredient isKindOfClass: [OFDictionary class]])
			@throw [OFInvalidFormatException
			    exceptionWithClass: isa];

		if ((tmp = [ingredient objectForKey: @"ingredient"]) == nil)
			@throw [OFInvalidFormatException
			    exceptionWithClass: isa];

		if ((tmp = [tmp objectForKey: @"version"]) != nil) {
			if (![tmp isKindOfClass: [OFNumber class]] ||
			    [tmp intValue] != 1)
				// FIXME: Include file name
				@throw [WrongVersionException
				    exceptionWithClass: isa];
		} else
			[of_stderr writeFormat: @"Warning: Ingredient %@ is "
						@"lacking a version!", file];

		[self populateFromDictionary: ingredient];

		[pool release];
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

- (OFString*)name
{
	return name;
}
@end
