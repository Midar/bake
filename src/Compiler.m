#import "Compiler.h"
#import "ObjCCompiler.h"

@implementation Compiler
+ (Compiler*)compilerForFile: (OFString*)file
		      target: (OFString*)target
{
	if ([file hasSuffix: @".m"])
		return [ObjCCompiler sharedCompiler];

	return nil;
}

- (OFString*)objectFileForSource: (OFString*)file
			  target: (Target*)target
{
	file = [file stringByAppendingString: @".o"];
	return [OFString stringWithPath: @"pastries", [target name], file, nil];
}

- (OFString*)outputFileForTarget: (Target*)target
{
	OFString *last = [[target name] lastPathComponent];
	return [OFString stringWithPath: @"pastries", [target name], last, nil];
}

- (void)compileFile: (OFString*)file
	     target: (Target*)target
{
	@throw [OFNotImplementedException exceptionWithClass: [self class]
						    selector: _cmd];
}

- (void)linkTarget: (Target*)target
	extraFlags: (OFString*)extraFlags
{
	@throw [OFNotImplementedException exceptionWithClass: [self class]
						    selector: _cmd];
}
@end
