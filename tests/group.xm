%group iOS8
%hook IOS8_SPECIFIC_CLASS
- (void)does { return; }
%end // end hook
%end // end group ios8

%group iOS9
%hook IOS9_SPECIFIC_CLASS
- (void)doesNot {

}
%end // end hook
%end // end group ios9

%ctor {
	if (kCFCoreFoundationVersionNumber > 1200) {
		%init(iOS9);
	} else {
		%init(iOS8);
	}
}
