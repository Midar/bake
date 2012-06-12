#import "IngredientProducer.h"

@implementation IngredientProducer
- init
{
	self = [super init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
		OFDictionary *info;

		info = [OFDictionary
		    dictionaryWithObject: [OFNumber numberWithInt: 1]
				  forKey: @"version"];
		ingredient = [[OFMutableDictionary alloc]
		    initWithObject: info
			    forKey: @"ingredient"];

		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[ingredient release];

	[super dealloc];
}

- (void)parseArgument: (OFString*)argument
{
	argument = [argument stringByDeletingEnclosingWhitespaces];

#define ADD_TO_ARRAY(array, object)					\
	do {								\
		id tmp;							\
									\
		if ((tmp = [ingredient objectForKey: array]) != nil)	\
			[tmp addObject: object];			\
		else {							\
			tmp = [OFMutableArray arrayWithObject: object];	\
			[ingredient setObject: tmp			\
				       forKey: array];			\
		}							\
	} while(0);

	if ([argument hasPrefix: @"-I"])
		ADD_TO_ARRAY(@"includedirs", [argument substringWithRange:
		    of_range(2, [argument length] - 2)])
	else if ([argument hasPrefix: @"-D"])
		ADD_TO_ARRAY(@"defines", [argument substringWithRange:
		    of_range(2, [argument length] - 2)])
	else if ([argument hasPrefix: @"-L"])
		ADD_TO_ARRAY(@"libdirs", [argument substringWithRange:
		    of_range(2, [argument length] - 2)])
	else if ([argument hasPrefix: @"-l"])
		ADD_TO_ARRAY(@"libs", [argument substringWithRange:
		    of_range(2, [argument length] - 2)])
	else if ([argument isEqual: @"-g"])
		[ingredient setObject: [OFNumber numberWithBool: YES]
			    forKey: @"debug"];
	else
		ADD_TO_ARRAY(@"objcflags", argument)

#undef ADD_TO_ARRAY
}

- (OFDictionary*)ingredient
{
	return ingredient;
}
@end
