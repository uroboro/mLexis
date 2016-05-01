%group SomeGroup
%hook SomeClass
- (id)init {
    return %orig;
}
%end
%end

%ctor {
    %init(SomeGroup, SomeClass = objc_getClass("class with spaces in the name"));
}
