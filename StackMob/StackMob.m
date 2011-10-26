// Copyright 2011 StackMob, Inc
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

#import "StackMob.h"
#import "StackMobConfiguration.h"
#import "StackMobPushRequest.h"
#import "StackMobRequest.h"
#import "StackMobAdditions.h"
#import "StackMobClientData.h"
#import "StackMobHerokuRequest.h"

@interface StackMob (Private)
- (void)queueRequest:(StackMobRequest *)request andCallback:(StackMobCallback)callback;
- (void)run;
- (void)next;
- (NSDictionary *)loadInfo;
@end

#define ENVIRONMENTS [NSArray arrayWithObjects:@"production", @"development", nil]

@implementation StackMob

@synthesize requests;
@synthesize callbacks;
@synthesize session;

static StackMob *_sharedManager = nil;
static SMEnvironment environment;

+ (StackMob *)setApplication:(NSString *)apiKey secret:(NSString *)apiSecret appName:(NSString *)appName subDomain:(NSString *)subDomain userObjectName:(NSString *)userObjectName apiVersionNumber:(NSNumber *)apiVersion
{
    if (_sharedManager == nil) {
        _sharedManager = [[super allocWithZone:NULL] init];
        environment = SMEnvironmentProduction;
        _sharedManager.session = [[StackMobSession sessionForApplication:apiKey
                                                                  secret:apiSecret
                                                                 appName:appName
                                                               subDomain:subDomain
                                                                  domain:SMDefaultDomain
                                                          userObjectName:userObjectName
                                                        apiVersionNumber:apiVersion] retain];
        _sharedManager.requests = [NSMutableArray array];
        _sharedManager.callbacks = [NSMutableArray array];
    }
    return _sharedManager;
}

+ (StackMob *)stackmob {
    if (_sharedManager == nil) {
        environment = SMEnvironmentProduction;

        _sharedManager = [[super allocWithZone:NULL] init];
        NSDictionary *appInfo = [_sharedManager loadInfo];
        if(appInfo){
            NSLog(@"Loading applicatino info from StackMob.plist is being deprecated for security purposes.");
            NSLog(@"Please define your application info in your app's prefix.pch");
            _sharedManager.session = [StackMobSession sessionForApplication:[appInfo objectForKey:@"publicKey"]
                                                                      secret:[appInfo objectForKey:@"privateKey"]
                                                                     appName:[appInfo objectForKey:@"appName"]
                                                                   subDomain:[appInfo objectForKey:@"appSubdomain"]
                                                                      domain:[appInfo objectForKey:@"domain"]
                                                              userObjectName:[appInfo objectForKey:@"userObjectName"]
                                                            apiVersionNumber:[appInfo objectForKey:@"apiVersion"]];

        }
        else{
#ifdef STACKMOB_PUBLIC_KEY
            _sharedManager.session = [StackMobSession sessionForApplication:STACKMOB_PUBLIC_KEY
                                                                      secret:STACKMOB_PRIVATE_KEY
                                                                     appName:STACKMOB_APP_NAME
                                                                   subDomain:STACKMOB_APP_SUBDOMAIN
                                                                      domain:STACKMOB_APP_DOMAIN
                                                              userObjectName:STACKMOB_USER_OBJECT_NAME
                                                           apiVersionNumber:[NSNumber numberWithInt:STACKMOB_API_VERSION]];
#else
#warning "No configuration found"
#endif

        }
        _sharedManager.requests = [NSMutableArray array];
        _sharedManager.callbacks = [NSMutableArray array];
    }
    return _sharedManager;
}

#pragma mark - Session Methods

- (StackMobRequest *)startSession{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"startsession" withHttpVerb:POST];
    [self queueRequest:request andCallback:nil];
    return request;
}

- (StackMobRequest *)endSession{
    StackMobRequest *request = [StackMobRequest requestForMethod:@"endsession" withHttpVerb:POST];
    [self queueRequest:request andCallback:nil];
    return request;
}

# pragma mark - User object Methods

- (StackMobRequest *)registerWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:session.userObjectName
                                                   withArguments:arguments
                                                    withHttpVerb:POST]; 
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    
    return request;
}

- (StackMobRequest *)loginWithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/login", session.userObjectName]
                                                   withArguments:arguments
                                                    withHttpVerb:GET]; 
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    
    return request;
}

- (StackMobRequest *)logoutWithCallback:(StackMobCallback)callback
{
    return [self destroy:session.userObjectName withArguments:NULL andCallback:callback];
}

- (StackMobRequest *)getUserInfowithArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    return [self get:session.userObjectName withArguments:arguments andCallback:callback];
}

- (StackMobRequest *)getUserInfowithQuery:(StackMobQuery *)query andCallback:(StackMobCallback)callback {
    return [self get:session.userObjectName withQuery:query andCallback:callback];
}

# pragma mark - Facebook methods
- (StackMobRequest *)loginWithFacebookToken:(NSString *)facebookToken andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"facebookLogin" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)registerWithFacebookToken:(NSString *)facebookToken username:(NSString *)username andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", username, @"username", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"createUserWithFacebook" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)linkUserWithFacebookToken:(NSString *)facebookToken withCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:facebookToken, @"fb_at", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"linkUserWithFacebook" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    return request;    
}

- (StackMobRequest *)postFacebookMessage:(NSString *)message withCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"postFacebookMessage" withArguments:args withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)getFacebookUserInfoWithCallback:(StackMobCallback)callback
{
    return [self get:@"getFacebookUserInfo" withCallback:callback];
}

# pragma mark - Twitter methods

- (StackMobRequest *)registerWithTwitterToken:(NSString *)token secret:(NSString *)secret username:(NSString *)username andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:token, @"tw_tk", secret, @"tw_ts", username, @"username", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"createUserWithTwitter" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)loginWithTwitterToken:(NSString *)token secret:(NSString *)secret andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:token, @"tw_tk", secret, @"tw_ts", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"twitterLogin" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    return request;    
}

- (StackMobRequest *)linkUserWithTwitterToken:(NSString *)token secret:(NSString *)secret andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:token, @"tw_tk", secret, @"tw_ts", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"linkUserWithTwitter" withArguments:args withHttpVerb:GET];
    request.isSecure = YES;
    [self queueRequest:request andCallback:callback];
    return request;    
}

- (StackMobRequest *)twitterStatusUpdate:(NSString *)message withCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:message, @"tw_st", nil];
    StackMobRequest *request = [StackMobRequest userRequestForMethod:@"twitterStatusUpdate" withArguments:args withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
    return request;    
}

# pragma mark - PUSH Notifications

- (StackMobRequest *)registerForPushWithUser:(NSString *)userId token:(NSString *)token andCallback:(StackMobCallback)callback
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId", token, @"token", nil];
    StackMobPushRequest *request = [StackMobPushRequest request];
    request.httpMethod = @"POST";
    request.method = @"device_tokens";
    SMLog(@"args %@", args);
    [request setArguments:args];
    [self queueRequest:request andCallback:callback];
    return request;
}

# pragma mark - Heroku methods

- (StackMobRequest *)herokuGet:(NSString *)path withCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:NULL
                                                                withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)herokuGet:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)herokuPost:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)herokuPut:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:arguments
                                                                withHttpVerb:PUT];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)herokuDelete:(NSString *)path andCallback:(StackMobCallback)callback
{
    StackMobHerokuRequest *request = [StackMobHerokuRequest requestForMethod:path
                                                               withArguments:nil
                                                                withHttpVerb:DELETE];
    [self queueRequest:request andCallback:callback];
    return request;
}

# pragma mark - CRUD methods

- (StackMobRequest *)get:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:GET]; 
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)get:(NSString *)path withQuery:(StackMobQuery *)query andCallback:(StackMobCallback)callback {
    StackMobRequest *request = [StackMobRequest requestForMethod:path withQuery:query withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)get:(NSString *)path withCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:NULL
                                                    withHttpVerb:GET];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)post:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)post:(NSString *)path forUser:(NSString *)user withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback
{
    NSDictionary *modifiedArguments = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [modifiedArguments setValue:user forKey:session.userObjectName];
    StackMobRequest *request = [StackMobRequest requestForMethod:[NSString stringWithFormat:@"%@/%@", session.userObjectName, path]
                                                   withArguments:modifiedArguments
                                                    withHttpVerb:POST];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)put:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:PUT];
    [self queueRequest:request andCallback:callback];
    return request;
}

- (StackMobRequest *)destroy:(NSString *)path withArguments:(NSDictionary *)arguments andCallback:(StackMobCallback)callback{
    StackMobRequest *request = [StackMobRequest requestForMethod:path
                                                   withArguments:arguments
                                                    withHttpVerb:DELETE];
    [self queueRequest:request andCallback:callback];
    return request;
}

# pragma mark - Private methods
- (void)queueRequest:(StackMobRequest *)request andCallback:(StackMobCallback)callback
{
    request.delegate = self;
    
    [self.requests addObject:request];
    if(callback)
        [self.callbacks addObject:Block_copy(callback)];
    else
        [self.callbacks addObject:[NSNull null]];
    
    [callback release];
    
    [self run];
}

- (void)run
{
    if(!_running){
        if([self.requests isEmpty]) return;
        currentRequest = [self.requests objectAtIndex:0];
        [currentRequest sendRequest];
        _running = YES;
    }
}

- (void)next
{
    _running = NO;
    currentRequest = nil;
    [self run];
}

- (NSDictionary *)loadInfo
{
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"StackMob" ofType:@"plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:filename];
    NSString *env = [ENVIRONMENTS objectAtIndex:(int)environment];

    NSMutableDictionary *appInfo = nil;
    if(info){
        appInfo = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:env]];
        if(![appInfo objectForKey:@"publicKey"] || [[appInfo objectForKey:@"publicKey"] length] < 1 || ![appInfo objectForKey:@"privateKey"] || [[appInfo objectForKey:@"privateKey"] length] < 1 ){
            [NSException raise:@"Initialization Error" format:@"Make sure you enter your publicKey and privateKey in StackMob.plist"];
        }
        else if(![appInfo objectForKey:@"appName"] || [[appInfo objectForKey:@"appName"] length] < 1 ){
            [NSException raise:@"Initialization Error" format:@"Make sure you enter your appName in StackMob.plist"];
        }
        else if(![appInfo objectForKey:@"appSubdomain"] || [[appInfo objectForKey:@"appSubdomain"] length] < 1 ){
            [NSException raise:@"Initialization Error" format:@"Make sure you enter your appSubdomain in StackMob.plist"];
        }
        else if(![appInfo objectForKey:@"domain"] || [[appInfo objectForKey:@"domain"] length] < 1 ){
            [NSException raise:@"Initialization Error" format:@"Make sure you enter your domain in StackMob.plist"];
        }
        else if(![appInfo objectForKey:@"apiVersion"]){
            [appInfo setValue:[NSNumber numberWithInt:1] forKey:@"apiVersion"];
        }
    }
    return appInfo;
}

#pragma mark - StackMobRequestDelegate

- (void)requestCompleted:(StackMobRequest*)request {
    if([self.requests containsObject:request]){
        NSInteger idx = [self.requests indexOfObject:request];
        id callback = [self.callbacks objectAtIndex:idx];
        SMLog(@"status %d", request.httpResponse.statusCode);
        if(callback != [NSNull null]){
            StackMobCallback mCallback = (StackMobCallback)callback;
            BOOL wasSuccessful = request.httpResponse.statusCode < 300 && request.httpResponse.statusCode > 199;
            mCallback(wasSuccessful, [request result]);
            Block_release(mCallback);
        }else{
            SMLog(@"no callback found");
        }
        [self.callbacks removeObjectAtIndex:idx];
        [self.requests removeObject:request];
        [self next];
    }
}

# pragma mark - Singleton Conformity

static StackMob *sharedSession = nil;

+ (StackMob *)sharedManager
{
    if (sharedSession == nil) {
        sharedSession = [[super allocWithZone:NULL] init];
    }
    return sharedSession;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (oneway void)release
{
    // do nothing
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (id)autorelease
{
    return self;
}
@end
