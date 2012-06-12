#import <ObjFW/ObjFW.h>

#import "Target.h"

@interface Compiler: OFObject
+ (Compiler*)compilerForFile: (OFString*)file
		      target: (Target*)target;
- (OFString*)objectFileForSource: (OFString*)file
			  target: (Target*)target;
- (OFString*)outputFileForTarget: (Target*)target;
- (void)compileFile: (OFString*)file
	     target: (Target*)target;
- (void)linkTarget: (Target*)target
	extraFlags: (OFString*)extraFlags;
@end
