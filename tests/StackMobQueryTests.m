//
//  StackMobQueryTests.m
//  StackMobiOS
//
//  Created by Jordan West on 11/30/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobQueryTests.h"
#import "SMGeoPoint.h"

#import <UIKit/UIKit.h>

@implementation StackMobQueryTests

- (void)testBasicOperators {
    StackMobQuery *q = [StackMobQuery query];
    [q field:@"equal" mustEqualValue:@"a"];
    [q field:@"ne" mustNotEqualValue:@"a"];
    [q field:@"lt" mustBeLessThanValue:[NSNumber numberWithInt:1]];
    [q field:@"lte" mustBeLessThanOrEqualToValue:[NSNumber numberWithInt:2]];
    [q field:@"gt" mustBeGreaterThanValue:[NSNumber numberWithInt:3]];
    [q field:@"gte" mustBeGreaterThanOrEqualToValue:[NSNumber numberWithInt:4]];
    [q field:@"in" mustBeOneOf:[NSArray arrayWithObject:@"hi"]];
    [q mustBeNull:@"null"];
    [q mustNotBeNull:@"notNull"];
    
    NSString *equal = [q.params objectForKey:@"equal"];
    NSString *ne = [q.params objectForKey:@"ne[ne]"];
    NSNumber *lt = [q.params objectForKey:@"lt[lt]"];
    NSNumber *lte = [q.params objectForKey:@"lte[lte]"];
    NSNumber *gt = [q.params objectForKey:@"gt[gt]"];
    NSNumber *gte = [q.params objectForKey:@"gte[gte]"];
    NSArray *ina = [q.params objectForKey:@"in[in]"];
    NSString *null = [q.params objectForKey:@"null[null]"];
    NSString *notNull = [q.params objectForKey:@"notNull[null]"];

    STAssertTrue([equal isEqualToString:@"a"], @"equal failed");
    STAssertTrue([ne isEqualToString:@"a"], @"not equal failed");
    STAssertTrue([lt isEqualToNumber:[NSNumber numberWithInt:1]], @"lt failed");
    STAssertTrue([lte isEqualToNumber:[NSNumber numberWithInt:2]], @"lte failed");
    STAssertTrue([gt isEqualToNumber:[NSNumber numberWithInt:3]], @"gt failed");
    STAssertTrue([gte isEqualToNumber:[NSNumber numberWithInt:4]], @"gte failed");
    STAssertTrue([ina isEqualToArray:[NSArray arrayWithObject:@"hi"]], @"in failed");
    STAssertTrue([null isEqualToString:@"true"], @"null failed");
    STAssertTrue([notNull isEqualToString:@"false"], @"not null failed");
}

- (void)testGeoOperators {
    StackMobQuery *q = [StackMobQuery query];
    SMGeoPoint *pt = [SMGeoPoint geoPointWithLongitude:1.0 andLatitude:2.1];
    [q field:@"near" mustBeNear:pt];
    [q field:@"nearwithinmi" mustBeNear:pt withinMi:2.0];
    [q field:@"nearwithinkm" mustBeNear:pt withinKm:2.0];
    [q field:@"withinmi" centeredAt:pt mustBeWithinMi:2.0];
    [q field:@"withinkm" centeredAt:pt mustBeWithinKm:2.0];
    [q field:@"withinbox" mustBeWithinBoxWithLowerLeft:pt andUpperRight:[SMGeoPoint geoPointWithLongitude:0.0 andLatitude:0.0]];
    
    NSString *near = [q.params objectForKey:@"near[near]"];
    STAssertTrue([near isEqualToString:@"2.1,1"], @"near failed");
    
    NSString *nearMi = [q.params objectForKey:@"nearwithinmi[near]"];
    NSNumber *expectedRadius = [NSNumber numberWithDouble:2.0/3956.6];
    NSString *expected = [NSString stringWithFormat:@"%@,%@", [pt stringValue], expectedRadius];
    STAssertTrue([nearMi isEqualToString:expected], @"near within mi failed");
    
    NSString *nearKm = [q.params objectForKey:@"nearwithinkm[near]"];
    NSNumber *expectedRadiusKm = [NSNumber numberWithDouble:2.0/6367.5];
    NSString *expectedKm = [NSString stringWithFormat:@"%@,%@", [pt stringValue], expectedRadiusKm];
    STAssertTrue([nearKm isEqualToString:expectedKm], @"near within km failed");

    NSString *withinMi = [q.params objectForKey:@"withinmi[within]"];
    STAssertTrue([withinMi isEqualToString:expected], @"within mi failed");
    
    NSString *withinKm = [q.params objectForKey:@"withinkm[within]"];
    STAssertTrue([withinKm isEqualToString:expectedKm], @"within km failed");
    
    NSString *withinBox = [q.params objectForKey:@"withinbox[within]"];
    STAssertTrue([withinBox isEqualToString:@"2.1,1,0,0"], @"within box failed");
}

@end
