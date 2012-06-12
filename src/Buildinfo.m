#import "Buildinfo.h"

@implementation Buildinfo
- (void)populateFromDictionary: (OFDictionary*)info
{
	id tmp;

#define KEEP_IF_KIND_IS(var, name, keep, kind)		\
	if ((tmp = [info objectForKey: name]) != nil &&	\
	    [tmp isKindOfClass: [kind class]])		\
		var = [tmp keep];

	KEEP_IF_KIND_IS(ingredients, @"ingredients", retain, OFArray)
	debug = [[info objectForKey: @"debug"] boolValue];
	KEEP_IF_KIND_IS(objC, @"objc", copy, OFString)
	KEEP_IF_KIND_IS(objCFlags, @"objcflags", mutableCopy, OFArray)
	KEEP_IF_KIND_IS(includeDirs, @"includedirs", mutableCopy, OFArray)
	KEEP_IF_KIND_IS(defines, @"defines", mutableCopy, OFArray)
	KEEP_IF_KIND_IS(libs, @"libs", mutableCopy, OFArray)
	KEEP_IF_KIND_IS(libDirs, @"libdirs", mutableCopy, OFArray)
	KEEP_IF_KIND_IS(conditionals, @"conditional", mutableCopy, OFArray)

#undef KEEP_IF_KIND_IS
}

- (void)inheritBuildinfo: (Buildinfo*)info
{
	id tmp;

#define INHERIT_ARRAY(var)					\
	if ((tmp = [info var]) != nil) {			\
		if (var != nil)					\
			[var insertObjectsFromArray: tmp	\
					    atIndex: 0];	\
		else						\
			var = [tmp mutableCopy];		\
	}

	INHERIT_ARRAY(ingredients)

	debug |= [info debug];

	if ((tmp = [info objC]) != nil) {
		[objC release];
		objC = [tmp copy];
	}

	INHERIT_ARRAY(objCFlags)
	INHERIT_ARRAY(includeDirs)
	INHERIT_ARRAY(defines)
	INHERIT_ARRAY(libs)
	INHERIT_ARRAY(libDirs)
	INHERIT_ARRAY(conditionals)

#undef INHERIT_ARRAY
}

- (void)dealloc
{
	[ingredients release];
	[objC release];
	[objCFlags release];
	[includeDirs release];
	[defines release];
	[libs release];
	[libDirs release];
	[conditionals release];

	[super dealloc];
}

- (OFArray*)ingredients
{
	return ingredients;
}

- (BOOL)debug
{
	return debug;
}

- (OFString*)objC
{
	return objC;
}

- (OFArray*)objCFlags
{
	return objCFlags;
}

- (OFArray*)includeDirs
{
	return includeDirs;
}

- (OFArray*)defines
{
	return defines;
}

- (OFArray*)libs
{
	return libs;
}

- (OFArray*)libDirs
{
	return libDirs;
}

- (OFArray*)conditionals
{
	return conditionals;
}
@end
