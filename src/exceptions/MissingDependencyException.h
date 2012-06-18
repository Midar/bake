#import <ObjFW/ObjFW.h>

@interface MissingDependencyException: OFException
{
	OFString *dependencyName;
}

+ exceptionWithClass: (Class)class_
      dependencyName: (OFString*)dependencyName;
-  initWithClass: (Class)class_
  dependencyName: (OFString*)dependencyName;
- (OFString*)dependencyName;
@end
