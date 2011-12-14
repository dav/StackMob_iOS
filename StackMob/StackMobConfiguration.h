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

#if DEBUG
    #define SMLog(format, ...) {NSLog(format, ##__VA_ARGS__);}
    #define StackMobDebug(format, ...) {NSLog([[NSString stringWithFormat:@"[%s, %@, %d] ", __PRETTY_FUNCTION__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__] stringByAppendingFormat:format, ##__VA_ARGS__]);}
#else
    #define SMLog(format, ...) {NSLog(format, ##__VA_ARGS__);}
    #define StackMobDebug(format, ...) {NSLog([[NSString stringWithFormat:@"[%s, %@, %d] ", __PRETTY_FUNCTION__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__] stringByAppendingFormat:format, ##__VA_ARGS__]);}
#endif


#define STACKMOB_PUBLIC_KEY         @"201543b9-7b81-4934-a353-c22d979c891a"
#define STACKMOB_PRIVATE_KEY        @"7a099db4-e09a-4e71-8348-3fea8ef5164f"
#define STACKMOB_APP_NAME           @"DemoApp"
#define STACKMOB_APP_SUBDOMAIN      @"stackmob"
#define STACKMOB_APP_DOMAIN         @"stackmob.com"
#define STACKMOB_USER_OBJECT_NAME   @"user"
#define STACKMOB_API_VERSION        0

/*
NSString * const kAPIKey = @"201543b9-7b81-4934-a353-c22d979c891a";
NSString * const kAPISecret = @"7a099db4-e09a-4e71-8348-3fea8ef5164f";
NSString * const kSubDomain = @"stackmob";
NSString * const kAppName = @"DemoApp";
#define STACKMOB_USER_OBJECT_NAME   @"user"
NSInteger  const kVersion = 0;*/