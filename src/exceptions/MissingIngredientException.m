#import "MissingIngredientException.h"

@implementation MissingIngredientException
+ exceptionWithClass: (Class)class
      ingredientName: (OFString*)ingredientName
{
	return [[[self alloc] initWithClass: class
			     ingredientName: ingredientName] autorelease];
}

-  initWithClass: (Class)class
  ingredientName: (OFString*)ingredientName_
{
	self = [super initWithClass: class];

	@try {
		ingredientName = [ingredientName_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- init
{
	Class c = [self class];
	[self release];
	@throw [OFNotImplementedException exceptionWithClass: c
						    selector: _cmd];
}

- (void)dealloc
{
	[ingredientName release];

	[super dealloc];
}

- (OFString*)ingredientName
{
	return ingredientName;
}
@end
