%hookf(FILE *, fopen, const char *path, const char *mode) {
	NSLog(@"Hey, we're hooking fopen to deny relative paths!");
	if (path[0] != '/') {
		return NULL;
	}
	return %orig; // Call the original implementation of this function
}
%end
