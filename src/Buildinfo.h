#import <ObjFW/ObjFW.h>

@interface Buildinfo: OFObject
{
	OFMutableArray *ingredients;
	BOOL debug;
	OFString *objC;
	OFMutableArray *objCFlags, *includeDirs, *defines, *libs, *libDirs;
	OFMutableArray *conditionals;
}

- (void)populateFromDictionary: (OFDictionary*)info;
- (void)inheritBuildinfo: (Buildinfo*)info;
- (OFArray*)ingredients;
- (BOOL)debug;
- (OFString*)objC;
- (OFArray*)objCFlags;
- (OFArray*)includeDirs;
- (OFArray*)defines;
- (OFArray*)libs;
- (OFArray*)libDirs;
- (OFArray*)conditionals;
@end
