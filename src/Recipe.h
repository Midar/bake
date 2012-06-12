#import "Buildinfo.h"

@interface Recipe: Buildinfo
{
	OFMutableDictionary *targets;
}

- (OFDictionary*)targets;
@end
