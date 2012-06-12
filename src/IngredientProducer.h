#import <ObjFW/ObjFW.h>

@interface IngredientProducer: OFObject
{
	OFMutableDictionary *ingredient;
}

- (void)parseArgument: (OFString*)argument;
- (OFDictionary*)ingredient;
@end
