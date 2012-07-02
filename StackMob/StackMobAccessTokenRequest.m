//
//  StackMobAccessTokenRequest.m
//  StackMobiOS
//
//  Created by Douglas Rapp on 7/2/12.
//  Copyright (c) 2012 StackMob, Inc. All rights reserved.
//

#import "StackMobAccessTokenRequest.h"

@implementation StackMobAccessTokenRequest

+ (id)requestForMethod:(NSString *)method withArguments:(NSDictionary *)arguments {
    StackMobAccessTokenRequest *request = [[[StackMobAccessTokenRequest alloc] init] autorelease];
    request.method = method;
    [request setArguments: arguments];
    
    return request;
}

- (NSString *)contentType {
    return @"application/x-www-form-urlencoded";
}

- (NSData *)postBody {
    return [[mArguments queryString] dataUsingEncoding:NSUTF8StringEncoding]; 
}

@end
