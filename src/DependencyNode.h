#import <ObjFW/ObjFW.h>

#import "Target.h"

@interface DependencyNode: OFObject
{
	Target *target;
	unsigned visited;
	BOOL inTargetOrder;
}

- initWithTarget: (Target*)target;
- (void)visit;
- (Target*)target;
- (BOOL)isInTargetOrder;
- (void)setInTargetOrder: (BOOL)inList;
@end
