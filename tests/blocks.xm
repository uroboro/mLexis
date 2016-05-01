%hook AwesomeClass

- (void)AwesomeMethod:(void (^)(void))awesomeBlock { %orig(^{ NSLog(@"Hello"); }); }

- (void)AwesomeMethod2:(void (^)(void))awesomeBlock
{
    %orig(^{
        NSLog(@"Hello");
    });
}

%end
