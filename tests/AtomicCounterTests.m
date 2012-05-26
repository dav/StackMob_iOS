//
//  AtomicCounterTests.m
//  StackMobiOS
//
//  Created by Matt Vaznaian on 5/25/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#import "AtomicCounterTests.h"

#define SCHEMA_TO_TEST @"YOUR_SCHEMA_TO_TEST"
#define FIELD_TO_UPDATE @"FIELD_WITH_INTEGER_VALUES"
#define OBJECT_ID @"OBJECT_ID"


@implementation AtomicCounterTests

- (void)testNSMutableDictionaryAddition
{
    __block int originalValue = 0;
    
    StackMobRequest *request1 = [[StackMob stackmob] get:[NSString stringWithFormat:@"%@/%@", SCHEMA_TO_TEST, OBJECT_ID] withCallback:^(BOOL success, id result){
        if(success){
            NSDictionary *info = (NSDictionary *)result;
            originalValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
            NSLog(@"originalValue is %d", originalValue);
        }
        else{
            STFail(@"getting the value from the given objectID failed");
        }
    }];
    
    NSDictionary *result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request1];
    NSDictionary *info = (NSDictionary *)result;
    originalValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args updateCounterForField:FIELD_TO_UPDATE by:1];
    
    StackMobRequest *request2 = [[StackMob stackmob] put:SCHEMA_TO_TEST withId:OBJECT_ID andArguments:args andCallback:^(BOOL success, id result){
        if(success){
            NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
            NSDictionary *info = (NSDictionary *)result;
            int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
            NSLog(@"updated value is %d", updateValue);
            STAssertTrue(updateValue == (originalValue + 1), nil);
        }
        else{
            STFail(@"updating the value failed");
        }
    }];
    
	//we need to loop until the request comes back, its just a test its OK
    result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request2];
    NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
    info = (NSDictionary *)result;
    int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    STAssertTrue(updateValue == (originalValue + 1), nil);
	request1 = nil;
    request2 = nil;
    [args release];
    
    
    
}

- (void)testStackMobUpdateCounterMethod
{
    __block int originalValue = 0;
    
    StackMobRequest *request1 = [[StackMob stackmob] get:[NSString stringWithFormat:@"%@/%@", SCHEMA_TO_TEST, OBJECT_ID] withCallback:^(BOOL success, id result){
        if(success){
            NSDictionary *info = (NSDictionary *)result;
            originalValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
            NSLog(@"originalValue is %d", originalValue);
        }
        else{
            STFail(@"getting the value from the given objectID failed");
        }
    }];
    
    NSDictionary *result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request1];
    NSDictionary *info = (NSDictionary *)result;
    originalValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    
    StackMobRequest *request2 = [[StackMob stackmob] put:SCHEMA_TO_TEST withId:OBJECT_ID updateCounterForField:FIELD_TO_UPDATE by:1 andCallback: ^(BOOL success, id result){
        if(success){
            NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
            NSDictionary *info = (NSDictionary *)result;
            int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
            NSLog(@"updated value is %d", updateValue);
            STAssertTrue(updateValue == (originalValue + 1), nil);
        }
        else{
            STFail(@"updating the value failed");
        }
    }];
    
	//we need to loop until the request comes back, its just a test its OK
    result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:request2];
    NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
    info = (NSDictionary *)result;
    int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    STAssertTrue(updateValue == (originalValue + 1), nil);
	request1 = nil;
    request2 = nil;
}

@end

