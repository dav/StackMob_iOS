//
//  StackMobQuery.m
//  StackMobiOS
//
//  Created by Jordan West on 10/14/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import "StackMobQuery.h"

@implementation StackMobQuery

@synthesize dictionary = _dictionary;

+ (StackMobQuery *)query {
    return [[[StackMobQuery alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    return self;
}

- (void)field:(NSString *)f mustEqualValue:(id)v {
    [self.dictionary setValue:v forKey:f];
}

- (void)field:(NSString *)f mustBeLessThanValue:(id)v {
    [self.dictionary setValue:v forKey:[NSString stringWithFormat:@"%@[lt]", f]];
}

- (void)field:(NSString *)f mustBeLessThanOrEqualToValue:(id)v {
    [self.dictionary setValue:v forKey:[NSString stringWithFormat:@"%@[lte]", f]];
}

- (void)field:(NSString *)f mustBeGreaterThanValue:(id)v {
    [self.dictionary setValue:v forKey:[NSString stringWithFormat:@"%@[gt]", f]];
}

- (void)field:(NSString *)f mustBeGreaterThanOrEqualToValue:(id)v {
    [self.dictionary setValue:v forKey:[NSString stringWithFormat:@"%@[gte]", f]];        
}

- (void)field:(NSString *)f mustBeOneOf:(NSArray *)arr {
    [self.dictionary setValue:arr forKey:[NSString stringWithFormat:@"%@[in]", f]];
}

- (void)setExpandDepth:(NSUInteger)depth {
    [self.dictionary setValue:[NSNumber numberWithInt:depth] forKey:@"_expand"];
}

- (void)dealloc {
    self.dictionary = nil;
    [super dealloc];
}

@end
