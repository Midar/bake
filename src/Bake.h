#import <ObjFW/ObjFW.h>

#import "Recipe.h"
#import "Target.h"

@interface Bake: OFObject
{
	Recipe *recipe;
	BOOL verbose, rebake;
}

- (void)findRecipe;
- (BOOL)shouldRebuildFile: (OFString*)file
		   target: (Target*)target;
- (BOOL)verbose;
@end
