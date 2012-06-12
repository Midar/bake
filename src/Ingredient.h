#import "Buildinfo.h"

@interface Ingredient: Buildinfo
{
	OFString *name;
}

+ ingredientWithName: (OFString*)name;
+ (OFString*)findIngredient: (OFString*)name;
- initWithFile: (OFString*)file;
- (OFString*)name;
@end
