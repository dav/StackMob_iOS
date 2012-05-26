//
//  AtomicCounterTests.h
//  StackMobiOS
//
//  Created by Matt Vaznaian on 5/25/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#define USE_APPLICATION_UNIT_TEST 0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "StackMob.h"
#import "StackMobTestUtils.h"
#import "StackMobTestCommon.h"
#import "NSData+Base64.h"
#import "SMFileTest.h"
#import "SMFile.h"

@interface AtomicCounterTests : StackMobTestCommon

- (void)testNSMutableDictionaryAddition;

- (void)testStackMobUpdateCounterMethod;


@end
