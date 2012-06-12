#import <ObjFW/ObjFW.h>

@interface CommandFailedException: OFException
{
	OFString *command;
}

+ exceptionWithClass: (Class)class_
	     command: (OFString*)command;
- initWithClass: (Class)class_
	command: (OFString*)command;
- (OFString*)command;
@end
