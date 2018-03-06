%subclass MyObject : NSObject
%property (nonatomic, copy) id someValue;

- (id)init {
	self = %orig;
	[self setSomeValue:@"value"];
	return self;
}

%end

%ctor {
	@autoreleasepool {
		MyObject *myObject = [[%c(MyObject) alloc] init];
		NSLog(@"myObject: %@", [myObject someValue]);
		[myObject release];
	}
}
