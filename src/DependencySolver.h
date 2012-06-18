#import <ObjFW/ObjFW.h>

#import "DependencyNode.h"
#import "Target.h"

@interface DependencySolver: OFObject
{
	OFMutableDictionary *nodes;
	OFMutableArray *targetOrder;
}

- (void)addTarget: (Target*)target;
- (void)solve;
- (OFArray*)targetOrder;
@end
