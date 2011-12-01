//
//  StackMobQuery.m
//  StackMobiOS
//
//  Created by Jordan West on 10/14/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobQuery.h"

@implementation StackMobQuery

@synthesize params = _params;
@synthesize headers = _headers;

+ (StackMobQuery *)query {
    return [[[StackMobQuery alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        _params = [[NSMutableDictionary alloc] initWithCapacity:4];
        _headers = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    return self;
}

- (void)field:(NSString *)f mustEqualValue:(id)v {
    [self.params setValue:v forKey:f];
}

- (void)field:(NSString *)f mustBeLessThanValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[lt]", f]];
}

- (void)field:(NSString *)f mustBeLessThanOrEqualToValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[lte]", f]];
}

- (void)field:(NSString *)f mustBeGreaterThanValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[gt]", f]];
}

- (void)field:(NSString *)f mustBeGreaterThanOrEqualToValue:(id)v {
    [self.params setValue:v forKey:[NSString stringWithFormat:@"%@[gte]", f]];        
}

- (void)field:(NSString *)f mustBeOneOf:(NSArray *)arr {
    [self.params setValue:arr forKey:[NSString stringWithFormat:@"%@[in]", f]];
}

- (void)setExpandDepth:(NSUInteger)depth {
    [self.headers setValue:[NSString stringWithFormat:@"%d", depth] forKey:@"X-StackMob-Expand"];
}

- (void)setRangeStart:(NSUInteger)start andEnd:(NSUInteger)end {
    [self.headers setValue:[NSString stringWithFormat:@"objects=%d-%d", start, end] forKey:@"Range"];
}

- (void)orderByField:(NSString *)f withDirection:(SMOrderDirection)dir {
    NSString *orderStr;
    NSString *currentHeader = [self.headers objectForKey:@"X-StackMob-OrderBy"];
    NSString *newHeaderValue;
    if (dir == SMOrderAscending) {
        orderStr = @"asc";
    } else {
        orderStr = @"desc";
    }    

    if ([currentHeader isKindOfClass:[NSString class]]) {
        newHeaderValue = [NSString stringWithFormat:@"%@,%@:%@", currentHeader, f, orderStr];
    } else {
        newHeaderValue = [NSString stringWithFormat:@"%@:%@", f, orderStr];
    }
    [self.headers setValue:newHeaderValue forKey:@"X-StackMob-OrderBy"];
}

- (void)dealloc {
    self.params = nil;
    self.headers = nil;
    [super dealloc];
}

@end
