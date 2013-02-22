#import "DependencyNode.h"

#import "CircularDependencyException.h"

@implementation DependencyNode
- initWithTarget: (Target*)target_
{
	self = [super init];

	@try {
		target = [target_ retain];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)visit
{
	if (++visited > 1)
		@throw [CircularDependencyException
		    exceptionWithClass: [self class]];
}

- (Target*)target
{
	return target;
}

- (BOOL)isInTargetOrder
{
	return inTargetOrder;
}

- (void)setInTargetOrder: (BOOL)inTargetOrder_
{
	inTargetOrder = inTargetOrder_;
}
@end
