// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


#import "APIRequestTests.h"

NSString * const kAPIKey = @"TEST_APP_PUB_KEY";
NSString * const kAPISecret = @"TEST_APP_PUB_KEY";
NSString * const kSubDomain = @"TEST_APP_SUBDOMAIN";
NSString * const kAppName = @"TEST_APP_NAME";
NSInteger  const kVersion = 0;

StackMobSession *mySession = nil;

@implementation APIRequestTests

- (void) setUp
{
	NSLog(@"In setup");
	if (!mySession) 
	{
        [StackMob setApplication:kAPIKey secret:kAPISecret appName:kAppName subDomain:kSubDomain userObjectName:@"user" apiVersionNumber:[NSNumber numberWithInt:kVersion]];
		NSLog(@"Created new session");
	}
}

- (void) tearDown
{
	NSLog(@"In teardown");
	mySession = nil;
}

- (void) testGet {
    StackMobQuery *q = [StackMobQuery query];
    [q field:@"username" mustEqualValue:@"ty"];
    [q field:@"createddate" mustBeGreaterThanOrEqualToValue:[NSNumber numberWithInt:2]];
    
	
	StackMobRequest *request = [StackMobRequest requestForMethod:@"user" 
                                                       withQuery:q
												  withHttpVerb:GET];
	[request sendRequest];
	//we need to loop until the request comes back, its just a test its OK
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
	    
    STAssertTrue([[request result] isKindOfClass:[NSArray class]], @"Did not get a valid GET result");
	request = nil;

}

- (void) testPost {
	NSLog(@"IN TEST POST");
    NSMutableDictionary* userArgs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
										@"Ty", @"firstname",
										@"Amell", @"lastname",
										@"ty@stackmob.com", @"email",
										nil];
	
    StackMobRequest *request = [[StackMob stackmob] post:@"user" withArguments:userArgs andCallback:^(BOOL success, id result){
        if(success){
            NSLog(@"testPost result was: %@", result);
            NSDictionary *info = (NSDictionary *)result;
            NSString *userId = [info objectForKey:@"username"];
            STAssertNotNil(userId, @"Returned value for POST is not correct");
        }
        else{
            STFail(@"creating a user failed");
        }
    }];

	//we need to loop until the request comes back, its just a test its OK
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	do {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		[runLoop acceptInputForMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		[loopPool drain];
	} while(![request finished]);
	
	NSDictionary *result = [request result];
    NSLog(@"result %@", result);
	NSString *userId = [result objectForKey:@"username"];
	STAssertNotNil(userId, @"Returned value for POST is not correct");
	request = nil;
	[userArgs release];
}


- (void) testURLGeneration {

	StackMobRequest *request = [StackMobRequest requestForMethod: @"user"];
	NSURL *testURL = [NSURL URLWithString: @"http://stackmob.stackmob.com/api/0/iossdktest/user"];
    NSLog(@"expected %@", [testURL absoluteString]),
    NSLog(@"actual %@", [request.url absoluteString]);
	STAssertTrue([[testURL absoluteString] isEqualToString: 
				  [request.url absoluteString]], @"User get URLs do not match" );
	testURL = nil;
	request = nil;
	
}

- (void) testSecureURLGeneration {
    StackMobRequest *request = [StackMobRequest requestForMethod:@"user"];
    request.isSecure = YES;
    NSURL *expectedURL = [NSURL URLWithString:@"https://stackmob.stackmob.com/api/0/iossdktest/user"];
    STAssertTrue([[expectedURL absoluteString] isEqualToString:[request.url absoluteString]], @"%@ Does Not Match Expected Secure URL", [request.url absoluteString]);
    expectedURL = nil;
    request = nil;
}

- (void) testAPIList {
	
	StackMobRequest *request = [StackMobRequest requestForMethod: @"listapi"];
	NSLog(@"Calling sendSynchronousRequest");
    NSError *error = nil;
	NSDictionary *result = [request sendSynchronousRequestProvidingError:&error];
    STAssertNotNil([result objectForKey:@"user"], @"No User Object in List API, Fail");
	request = nil;		
}

- (void) testRequestsThatDefaultToSecure {
    StackMobRequest *r;
    StackMobCallback emptyCallback = ^(BOOL success, id result) {};
    
    r = [[StackMob stackmob] loginWithArguments:[NSDictionary dictionary] andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Login Request Should Default to SSL");
                    
    r = [[StackMob stackmob] loginWithFacebookToken:@"WHOCARES" andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Login w/ Facebook Request Should Default to SSL");
    
    r = [[StackMob stackmob] loginWithTwitterToken:@"WHOCARES" secret:@"WHOCARES2" andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Login w/ Twitter Request Should Default to SSL");
    
    r = [[StackMob stackmob] linkUserWithFacebookToken:@"ASD" withCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Link With Facebook Token Should Default to SSL");
    
    r = [[StackMob stackmob] linkUserWithTwitterToken:@"WHOCARES" secret:@"WHOCARES" andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Link With Twitter Token Should Default to SSL");

    r = [[StackMob stackmob] registerWithArguments:[NSDictionary dictionary] andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Register User Should Default to SSL");
    
    r = [[StackMob stackmob] registerWithFacebookToken:@"TOKEN" username:@"UNAME" andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Register With Facebook Token Should Default to SSL");
    
    r = [[StackMob stackmob] registerWithTwitterToken:@"TOKEN" secret:@"SECRET" username:@"UNAME" andCallback:emptyCallback];
    STAssertTrue(r.isSecure, @"Register With Twitter Token Should Defult to SSL");
        
}


@end
