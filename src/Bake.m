#import "Bake.h"
#import "Compiler.h"
#import "DependencySolver.h"
#import "ObjCCompiler.h"
#import "Target.h"
#import "IngredientProducer.h"

#import "CompilationFailedException.h"
#import "LinkingFailedException.h"
#import "MissingDependencyException.h"
#import "MissingIngredientException.h"
#import "WrongVersionException.h"

OF_APPLICATION_DELEGATE(Bake)

@implementation Bake
- (void)applicationDidFinishLaunching
{
	OFArray *arguments;
	OFSet *conditions;
	DependencySolver *dependencySolver;
	OFEnumerator *enumerator;
	Target *target;
	OFArray *targetOrder;
	BOOL install;
	OFString *prefix = @"/usr/local";
	OFString *bindir = [prefix stringByAppendingString: @"/bin"];

	arguments = [OFApplication arguments];
	install = [arguments containsObject: @"--install"];

	if ([arguments containsObject: @"--produce-ingredient"]) {
		IngredientProducer *producer;
		OFEnumerator *enumerator;
		OFString *argument;

		producer = [[IngredientProducer alloc] init];

		arguments = [arguments
		    arrayByRemovingObject: @"--produce-ingredient"];
		enumerator = [arguments objectEnumerator];
		while ((argument = [enumerator nextObject]) != nil)
			[producer parseArgument: argument];

		[of_stdout writeLine:
		    [[producer ingredient] JSONRepresentation]];

		[OFApplication terminate];
	}

	[self findRecipe];

	@try {
		recipe = [[Recipe alloc] init];
	} @catch (OFOpenFileFailedException *e) {
		[of_stderr writeLine: @"Error: Could not find Recipe!"];
		[OFApplication terminateWithStatus: 1];
	} @catch (OFInvalidJSONException *e) {
		[of_stderr writeFormat: @"Error: Malformed Recipe in line "
					@"%zd!\n", [e line]];
		[OFApplication terminateWithStatus: 1];
	} @catch (WrongVersionException *e) {
		[of_stderr writeLine: @"Error: Recipe version too new!"];
		[OFApplication terminateWithStatus: 1];
	}

	// FIXME
	conditions = [OFSet setWithObjects: @"objc_gcc_compatible",
					    @"true",
					    nil];

	verbose = ([arguments containsObject: @"--verbose"] ||
	    [arguments containsObject: @"-v"]);
	rebake = ([arguments containsObject: @"--rebake"] ||
	    [arguments containsObject: @"-r"]);

	dependencySolver = [[[DependencySolver alloc] init] autorelease];

	enumerator = [[recipe targets] objectEnumerator];
	while ((target = [enumerator nextObject]) != nil)
		[dependencySolver addTarget: target];

	@try {
		[dependencySolver solve];
	} @catch (MissingDependencyException *e) {
		[of_stderr writeFormat: @"Error: Target %@ is missing, but "
					@"specified as dependency!\n",
					[e dependencyName]];
		[OFApplication terminateWithStatus: 1];
	}

	targetOrder = [dependencySolver targetOrder];

	enumerator = [targetOrder objectEnumerator];
	while ((target = [enumerator nextObject]) != nil) {
		OFEnumerator *fileEnumerator;
		OFString *file;
		size_t i = 0;
		BOOL link = NO;

		[target resolveConditionals: conditions];

		@try {
			[target addIngredients];
		} @catch (MissingIngredientException *e) {
			[of_stderr writeFormat: @"Error: Ingredient %@ "
						@"missing!\n",
						[e ingredientName]];
			[OFApplication terminateWithStatus: 1];
		}

		fileEnumerator = [[target files] objectEnumerator];
		while ((file = [fileEnumerator nextObject]) != nil) {
			if (![self shouldRebuildFile: file
					      target: target]) {
				i++;
				continue;
			}

			link = YES;

			if (!verbose)
				[of_stdout writeFormat: @"\r%@: %zd/%zd",
							[target name], i,
							[[target files] count]];

			@try {
				Compiler *compiler =
				    [Compiler compilerForFile: file
						       target: target];

				[compiler compileFile: file
					       target: target];
			} @catch (CompilationFailedException *e) {
				[of_stdout writeString: @"\n"];
				[of_stderr writeFormat:
				    @"Failed to compile file %@!\n"
				    @"Command was:\n%@\n", file, [e command]];
				[OFApplication terminateWithStatus: 1];
			}

			i++;

			if (!verbose)
				[of_stdout writeFormat: @"\r%@: %zd/%zd",
							[target name], i,
							[[target files] count]];
		}

		if (link || ([[target files] count] > 0 &&
		    ![OFFile fileExistsAtPath: [[ObjCCompiler sharedCompiler]
		    outputFileForTarget: target]])) {
			if (!verbose)
				[of_stdout writeFormat:
				    @"\r%@: %zd/%zd (linking)",
				    [target name], i, [[target files] count]];

			@try {
				/*
				 * FIXME: Need to find out which compiler a
				 *	  target needs to link!
				 */
				[[ObjCCompiler sharedCompiler]
				    linkTarget: target
				    extraFlags: nil];
			} @catch (LinkingFailedException *e) {
				[of_stdout writeString: @"\n"];
				[of_stderr writeFormat:
				    @"Failed to link target %@!"
				    @"Command was:\n%@\n",
				    [target name], [e command]];
				[OFApplication terminateWithStatus: 1];
			}

			if (!verbose)
				[of_stdout writeFormat:
				    @"\r%@: %zd/%zd (successful)\n",
				    [target name], i, [[target files] count]];
		} else
			[of_stdout writeFormat: @"%@: Already up to date\n",
						[target name]];

		if (install && [[target files] count] > 0) {
			OFString *file = [[ObjCCompiler sharedCompiler]
			    outputFileForTarget: target];
			OFString *destination = [OFString stringWithPath:
			    bindir, [file lastPathComponent], nil];


			[of_stdout writeFormat: @"Installing: %@ -> %@\n",
						file, destination];

			if (![OFFile directoryExistsAtPath: bindir])
				[OFFile createDirectoryAtPath: bindir
						createParents: YES];

			[OFFile copyFileAtPath: file
					toPath: destination];
		}
	}

	[OFApplication terminate];
}

- (void)findRecipe
{
	OFString *oldPath = [OFFile currentDirectoryPath];

	while (![OFFile fileExistsAtPath: @"Recipe"]) {
		[OFFile changeToDirectoryAtPath: OF_PATH_PARENT_DIRECTORY];

		/* We reached the file system root */
		if ([[OFFile currentDirectoryPath] isEqual: oldPath])
			break;

		oldPath = [OFFile currentDirectoryPath];
	}
}

- (BOOL)shouldRebuildFile: (OFString*)file
		   target: (Target*)target
{
	Compiler *compiler;
	OFString *objectFile;
	OFDate *sourceDate, *objectDate;

	if (rebake)
		return YES;

	compiler = [Compiler compilerForFile: file
				      target: target];
	objectFile = [compiler objectFileForSource: file
					    target: target];

	if (![OFFile fileExistsAtPath: objectFile])
		return YES;

	sourceDate = [OFFile modificationDateOfFileAtPath: file];
	objectDate = [OFFile modificationDateOfFileAtPath: objectFile];

	return ([objectDate compare: sourceDate] == OF_ORDERED_ASCENDING);
}

- (BOOL)verbose
{
	return verbose;
}
@end
