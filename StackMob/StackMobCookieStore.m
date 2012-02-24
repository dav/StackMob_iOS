// Copyright 2012 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "StackMobCookieStore.h"

@interface StackMobCookieStore()
- (void) addCookie:(NSHTTPCookie *)cookie;
@end

@implementation StackMobCookieStore

static NSMutableDictionary *cookies;
static NSString *cookieStoreKey;

- (StackMobCookieStore*)initWithAppName:(NSString *)appName;
{
	if ((self = [super init])) {

        cookieStoreKey = [@"stackmob." stringByAppendingString:appName];
        NSData *storedCookes = [[NSUserDefaults standardUserDefaults] objectForKey:cookieStoreKey];
        if ([storedCookes length]) {
            cookies = [NSKeyedUnarchiver unarchiveObjectWithData:storedCookes];
        } else {
            cookies = [[NSMutableDictionary alloc] init];
        }
	}
	return self;
}


- (void) addCookies:(StackMobRequest *)request
{
    NSHTTPURLResponse *response = request.httpResponse;
    for(NSHTTPCookie *cookie in [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:@""]]) {
        [self addCookie:cookie];
    }

}

- (void) addCookie:(NSHTTPCookie *)cookie
{
    [cookies setObject:cookie forKey:[cookie name]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:cookies] forKey:cookieStoreKey];
}

- (NSString *) cookieHeader
{
    BOOL first = YES;
    NSString * cookieString = @"";
    for(NSHTTPCookie *cookie in [cookies allValues]) {
        if ([[cookie expiresDate] compare:[NSDate date]] != NSOrderedAscending)
        {
            cookieString = [cookieString stringByAppendingFormat:@"%@%@=%@", (first ? @"" : @";"), [cookie name], [cookie value]];
            first = NO;
        }
    }
    return cookieString;
}
@end
