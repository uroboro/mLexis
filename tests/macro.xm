#include <stdio.h>
#include "somefile.h"

#if 01
%hook SBApplicationController

- (void)uninstallApplication:(SBApplication *)application {
	NSLog(@"Hey, we're hooking uninstallApplication:!");
	%orig(application); // Call the original implementation of this method
	return;
}

%end
#else
%hook SBApplicationController2

- (void)uninstallApplication2:(SBApplication *)application {
	NSLog(@"Hey, we're hooking uninstallApplication:!");
	%orig(application); // Call the original implementation of this method
	return;
}

%end
#endif
