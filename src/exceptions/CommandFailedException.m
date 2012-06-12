#import "CommandFailedException.h"

@implementation CommandFailedException
+ exceptionWithClass: (Class)class
	     command: (OFString*)command
{
	return [[[self alloc] initWithClass: class
				    command: command] autorelease];
}

- initWithClass: (Class)class
	command: (OFString*)command_
{
	self = [super initWithClass: class];

	@try {
		command = [command_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- init
{
	Class c = isa;
	[self release];
	@throw [OFNotImplementedException exceptionWithClass: c
						    selector: _cmd];
}

- (void)dealloc
{
	[command release];

	[super dealloc];
}

- (OFString*)command
{
	return command;
}
@end
