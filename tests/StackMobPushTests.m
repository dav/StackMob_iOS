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

#import "StackMobPushTests.h"

#import <UIKit/UIKit.h>
//#import "application_headers" as required

@implementation StackMobPushTests

- (void)assertResultIsQueued:(NSDictionary *)result {
    STAssertNotNil([result objectForKey:@"queued"], @"no queued value returned");
}

- (void)registerToken {
    StackMobRequest * request = [[StackMob stackmob] registerForPushWithUser:pushUser token:pushToken andCallback:emptyCallback];
    [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
}

- (void)setUp {
    [super setUp];

    if(!pushUser) pushUser = @"IOS_TEST_PUSH_USER";
    if(!pushToken) pushToken = @"DEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF";
    if(!pushPayload) pushPayload = [NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"key1", nil];
    if(!pushUserTargets) pushUserTargets = [NSArray arrayWithObject:pushUser];
    if(!pushTokenTargets) pushTokenTargets = [NSArray arrayWithObject:pushToken];

    StackMobRequest * request = [[StackMob stackmob] deletePushToken:pushToken andCallback:emptyCallback];
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
}

- (void)tearDown {
    StackMobRequest * request = [[StackMob stackmob] deletePushToken:pushToken andCallback:emptyCallback];
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:request];
    [super tearDown];
}

- (void)testRegisterDeviceToken {
    StackMobRequest * request = [[StackMob stackmob] registerForPushWithUser:pushUser token:pushToken andCallback:emptyCallback];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertNotNSError:result];
    STAssertTrue((BOOL)[result objectForKey:@"registered"], @"token not reported as registered");
}

- (void)testGetDeviceTokens {
    StackMobRequest * request = [[StackMob stackmob] getPushTokensForUsers:[NSArray arrayWithObject:pushUser] andCallback:emptyCallback];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertNotNSError:result];
    STAssertNotNil([result objectForKey:@"tokens"], @"no tokens value returned");
}


- (void)testSendPushBroadcastWithArguments {
    StackMobRequest * request = [[StackMob stackmob] sendPushBroadcastWithArguments:pushPayload andCallback:emptyCallback];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertNotNSError:result];
    [self assertResultIsQueued:result];
}

- (void)testSendPushToUsersWithArguments {
    [self registerToken];
    
    StackMobRequest * request = [[StackMob stackmob] sendPushToUsersWithArguments:pushPayload withUserIds:pushUserTargets andCallback:emptyCallback];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertNotNSError:result];
    [self assertResultIsQueued:result];
}

- (void)testSendPushToTokensWithArguments {
    [self registerToken];
    
    StackMobRequest * request = [[StackMob stackmob] sendPushToTokensWithArguments:pushPayload withTokens:pushTokenTargets andCallback:emptyCallback];
    NSDictionary * result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request];
    NSLog(@"result: %@", result);
    [self assertNotNSError:result];
    [self assertResultIsQueued:result];
}

@end