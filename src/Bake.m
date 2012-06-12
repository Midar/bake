#import "Bake.h"
#import "Compiler.h"
#import "ObjCCompiler.h"
#import "Target.h"
#import "IngredientProducer.h"

#import "CompilationFailedException.h"
#import "LinkingFailedException.h"
#import "IngredientMissingException.h"
#import "WrongVersionException.h"

OF_APPLICATION_DELEGATE(Bake)

@implementation Bake
- (void)applicationDidFinishLaunching
{
	OFArray *arguments;
	OFSet *conditions;
	OFEnumerator *keyEnumerator, *objectEnumerator;
	OFString *name;
	Target *target;

	arguments = [OFApplication arguments];

	if ([arguments containsObject: @"--produce-ingredient"]) {
		IngredientProducer *producer;
		OFMutableArray *tmp;
		OFEnumerator *enumerator;
		OFString *argument;

		producer = [[IngredientProducer alloc] init];

		// FIXME: arrayByRemovingObject?
		tmp = [[arguments mutableCopy] autorelease];
		[tmp removeObject: @"--produce-ingredient"];

		enumerator = [tmp objectEnumerator];
		while ((argument = [enumerator nextObject]) != nil)
			[producer parseArgument: argument];

		[of_stdout writeLine:
		    [[producer ingredient] JSONRepresentation]];

		return;
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

	keyEnumerator = [[recipe targets] keyEnumerator];
	objectEnumerator = [[recipe targets] objectEnumerator];
	while ((name = [keyEnumerator nextObject]) != nil &&
	    (target = [objectEnumerator nextObject]) != nil) {
		OFEnumerator *fileEnumerator;
		OFString *file;
		size_t i = 0;
		BOOL link = NO;

		[target resolveConditionals: conditions];

		@try {
			[target addIngredients];
		} @catch (IngredientMissingException *e) {
			[of_stderr writeFormat: @"Error: Ingredient %@ "
						@"missing!\n",
						[e ingredientName]];
			[OFApplication terminateWithStatus: 1];
		}

		if ([target files] == nil || [[target files] count] == 0)
			continue;

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

		if (link) {
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
	}
}

- (void)findRecipe
{
	OFString *oldPath = [OFFile currentDirectoryPath];

	while (![OFFile fileExistsAtPath: @"Recipe"]) {
		[OFFile changeToDirectory: OF_PATH_PARENT_DIR];

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

	sourceDate = [OFFile modificationDateOfFile: file];
	objectDate = [OFFile modificationDateOfFile: objectFile];

	return ([objectDate compare: sourceDate] == OF_ORDERED_ASCENDING);
}

- (BOOL)verbose
{
	return verbose;
}
@end
