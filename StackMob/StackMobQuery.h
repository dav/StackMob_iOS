//
//  StackMobQuery.h
//  StackMobiOS
//
//  Created by Jordan West on 10/14/11.
//  Copyright (c) 2011 StackMob, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StackMobQuery : NSObject
    
@property(nonatomic, copy) NSMutableDictionary *dictionary;

+ (StackMobQuery *)query;

- (void)field:(NSString *)f mustEqualValue:(id)v;
- (void)field:(NSString *)f mustBeLessThanValue:(id)v;
- (void)field:(NSString *)f mustBeLessThanOrEqualToValue:(id)v;
- (void)field:(NSString *)f mustBeGreaterThanValue:(id)v;
- (void)field:(NSString *)f mustBeGreaterThanOrEqualToValue:(id)v;
- (void)field:(NSString *)f mustBeOneOf:(NSArray *)arr;
- (void)setExpandDepth:(NSUInteger)depth;


@end
