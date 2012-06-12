#import <ObjFW/ObjFW.h>

@interface IngredientMissingException: OFException
{
	OFString *ingredientName;
}

+ exceptionWithClass: (Class)class_
      ingredientName: (OFString*)ingredientName;
-  initWithClass: (Class)class_
  ingredientName: (OFString*)ingredientName;
- (OFString*)ingredientName;
@end
