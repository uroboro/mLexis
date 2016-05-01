%subclass MyObject : NSObject

- (id)init {
	self = %orig;
	[self setSomeValue:@"value"];
	return self;
}

//the following two new methods act as `@property (nonatomic, retain) id someValue;`
%new
- (id)someValue {
	return objc_getAssociatedObject(self, @selector(someValue));
}

%new
- (void)setSomeValue:(id)value {
	objc_setAssociatedObject(self, @selector(someValue), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

%ctor {
	@autoreleasepool {
		MyObject *myObject = [[%c(MyObject) alloc] init];
		NSLog(@"myObject: %@", [myObject someValue]);
		[myObject release];
	}
}
