%hook SBApplicationController

- (void)uninstallApplication:(SBApplication *)application {
	NSLog(@"Hey, we're hooking uninstallApplication:!");
	%orig(application); // Call the original implementation of this method
	return;
}

%end
