#import "Buildinfo.h"

@interface Target: Buildinfo
{
	OFString *name;
	OFMutableArray *files;
	OFMutableArray *dependencies;
	BOOL sharedLib, staticLib;
	unsigned sharedLibMajor, sharedLibMinor;
	BOOL install;
	OFDictionary *installHeaders;
}

- initWithName: (OFString*)name;
- (void)resolveConditionals: (OFSet*)conditions;
- (void)addIngredients;
- (OFString*)name;
- (OFArray*)files;
- (OFArray*)dependencies;
@end
