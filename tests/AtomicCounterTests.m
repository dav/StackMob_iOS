//
//  AtomicCounterTests.m
//  StackMobiOS
//
//  Created by Matt Vaznaian on 5/25/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#import "AtomicCounterTests.h"

#define SCHEMA_TO_TEST @"testschema1"
#define FIELD_TO_UPDATE @"likes"


@implementation AtomicCounterTests

- (void)testNSMutableDictionaryAddition
{
    __block int originalValue = 1;
    __block NSString *objectId;
    
    NSDictionary *initArgs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], FIELD_TO_UPDATE, nil];
    
    StackMobRequest *postRequest = [[StackMob stackmob] post:SCHEMA_TO_TEST withArguments:initArgs andCallback:^(BOOL success, id result){
        if (success){
            
        }
        else {
            STFail(@"did not initialize original value");
        }
        
    }];
    
    NSDictionary *result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:postRequest];
    NSDictionary *info = (NSDictionary *)result;
    objectId = [info objectForKey:[NSString stringWithFormat:@"%@_id", SCHEMA_TO_TEST]];
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args updateCounterForField:FIELD_TO_UPDATE by:1];
    
    StackMobRequest *updateRequest = [[StackMob stackmob] put:SCHEMA_TO_TEST withId:objectId andArguments:args andCallback:^(BOOL success, id result){
        if(success){
            
        }
        else{
            STFail(@"updating the value failed");
        }
    }];
    
	//we need to loop until the request comes back, its just a test its OK
    result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:updateRequest];
    NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
    info = (NSDictionary *)result;
    int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    STAssertTrue(updateValue == (originalValue + 1), nil);
	postRequest = nil;
    updateRequest = nil;
    [args release];
    
}

- (void)testNSDictionaryAddition
{
    __block int originalValue = 1;
    __block NSString *objectId;
    
    NSDictionary *initArgs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], FIELD_TO_UPDATE, nil];
    
    StackMobRequest *postRequest = [[StackMob stackmob] post:SCHEMA_TO_TEST withArguments:initArgs andCallback:^(BOOL success, id result){
        if (success){
            
        }
        else {
            STFail(@"did not initialize original value");
        }
        
    }];
    
    NSDictionary *result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:postRequest];
    NSDictionary *info = (NSDictionary *)result;
    objectId = [info objectForKey:[NSString stringWithFormat:@"%@_id", SCHEMA_TO_TEST]];
    
    NSDictionary *args = [[NSDictionary alloc] init];
    args = [args updateCounterForFieldAndReturnDictionary:FIELD_TO_UPDATE by:1];
    
    StackMobRequest *updateRequest = [[StackMob stackmob] put:SCHEMA_TO_TEST withId:objectId andArguments:args andCallback:^(BOOL success, id result){
        if(success){
            
        }
        else{
            STFail(@"updating the value failed");
        }
    }];
    
	//we need to loop until the request comes back, its just a test its OK
    result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:updateRequest];
    NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
    info = (NSDictionary *)result;
    int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    STAssertTrue(updateValue == (originalValue + 1), nil);
	postRequest = nil;
    updateRequest = nil;
    [args release];
    
}


- (void)testStackMobUpdateCounterMethod
{
    __block int originalValue = 1;
    __block NSString *objectId;
    
    NSDictionary *initArgs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], FIELD_TO_UPDATE, nil];
    
    StackMobRequest *postRequest = [[StackMob stackmob] post:SCHEMA_TO_TEST withArguments:initArgs andCallback:^(BOOL success, id result){
        if (success){
            
        }
        else {
            STFail(@"did not initialize original value");
        }
        
    }];
    
    NSDictionary *result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:postRequest];
    NSDictionary *info = (NSDictionary *)result;
    objectId = [info objectForKey:[NSString stringWithFormat:@"%@_id", SCHEMA_TO_TEST]];
    
    StackMobRequest *updateRequest = [[StackMob stackmob] put:SCHEMA_TO_TEST withId:objectId updateCounterForField:FIELD_TO_UPDATE by:1 andCallback:^(BOOL success, id result){
        if(success){
            
        }
        else{
            STFail(@"updating the value failed");
        }
    }];
    
	//we need to loop until the request comes back, its just a test its OK
    result = [StackMobTestUtils runDefaultRunLoopAndGetDictionaryResultFromRequest:updateRequest];
    NSLog(@"testNSMutableDictionaryAddition result was: %@", result);
    info = (NSDictionary *)result;
    int updateValue = [[info objectForKey:FIELD_TO_UPDATE] intValue];
    STAssertTrue(updateValue == (originalValue + 1), nil);
	postRequest = nil;
    updateRequest = nil;
    
}


@end
