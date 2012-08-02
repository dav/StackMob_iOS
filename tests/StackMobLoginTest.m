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

#import <UIKit/UIKit.h>
#import "NSData+Base64.h"
#import "StackMobLoginTest.h"
#import "StackMobTestUtils.h"

//#import "application_headers" as required

@implementation StackMobLoginTest
- (void)setUp {
    [super setUp];
    [self createUser];
}

- (void)tearDown
{
    [self deleteUser];
}

- (void)createUser
{
    NSDictionary *createArgs = [NSDictionary dictionaryWithObjectsAndKeys:USER_NAME, @"username", USER_PASSWORD, @"password", nil];
    StackMobRequest *createRequest = [[StackMob stackmob] post:@"user" withArguments:createArgs andCallback:^(BOOL success, id result) {
        STAssertTrue(success, @"user not created");
        
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:createRequest];
}

- (void)deleteUser
{
    NSDictionary *destroyArgs = [NSDictionary dictionaryWithObjectsAndKeys:USER_NAME, @"username", nil];
    StackMobRequest *deleteRequest = [[StackMob stackmob] destroy:@"user" withArguments:destroyArgs andCallback:^(BOOL success, id result) {
        STAssertTrue(success, @"object not deleted");
    }];
    
    [StackMobTestUtils runRunLoop:[NSRunLoop currentRunLoop] untilRequestFinished:deleteRequest];
}


- (void)testSetCookieLoginLogout {
    NSMutableDictionary *loginRequest = [[NSMutableDictionary alloc] init];
    [loginRequest setValue:USER_NAME forKey:@"username"];
    [loginRequest setValue:USER_PASSWORD forKey:@"password"];
    [[StackMob stackmob] loginWithArguments:loginRequest andCallback:^(BOOL success, id result) {
        STAssertTrue(success == YES, @"login failed");
        STAssertTrue([[[[StackMob stackmob] cookieStore] cookieHeader] length] != 0, @"Auth cookie was not set");
    }];
    
    [[StackMob stackmob] logoutWithCallback:^(BOOL success, id result) {
        STAssertTrue(success == YES, @"logout failed");
    }];
}


@end