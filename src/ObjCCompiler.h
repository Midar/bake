#import "Compiler.h"

@interface ObjCCompiler: Compiler
{
	OFString *program;
}

+ sharedCompiler;
@end
