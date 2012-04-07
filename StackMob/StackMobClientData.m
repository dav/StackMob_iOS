// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "StackMobClientData.h"
#if TARGET_OS_IPHONE
  #import "SecureUDID.h"
  #import <UIKit/UIKit.h>
  #import "Reachability.h"
#endif
#include <sys/sysctl.h>
#if TARGET_OS_IPHONE == 0
  #include <sys/socket.h>
#endif
#include <net/if.h>
#include <net/if_dl.h>

static StackMobClientData * _sharedInstance=nil;

@interface StackMobClientData ()
#if TARGET_OS_IPHONE
- (void)startReachabilityUpdates;
- (void)reachabilityChanged:(NSNotification *)note;
#endif
- (void)generateClientDataString;

@property (nonatomic, assign) NSString *bundleVersion;
@property (nonatomic, assign) NSString *identifier;
@property (nonatomic, assign) NSString *model;
@property (nonatomic, assign) NSString *systemVersion;
@property (nonatomic, assign) NSString *device_name;
@property (nonatomic, assign) NSString *countryCode;
@property (nonatomic, assign) NSString *language;
@property (nonatomic, assign) NSString *jailBroken;
@end

@implementation StackMobClientData

@synthesize bundleVersion, identifier, model, systemVersion, device_name, countryCode, language, jailBroken;

- (id)init
{
	if((self = [super init])) {
#if TARGET_OS_IPHONE
		// Device info.
		UIDevice *device = [UIDevice currentDevice];
		identifier = [SecureUDID UDIDForDomain:@"com.stackmob" salt:@"828e4a5771d696176b1c6a3e0579858a"];
		model = [[device model] retain];
		systemVersion = [[device systemVersion] retain];
#endif		
						
		// Locale info.
		NSLocale *locale = [NSLocale currentLocale];
		countryCode = [[locale objectForKey:NSLocaleCountryCode] retain];
		language = [[[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode] retain];	
		
		// App info.
		bundleVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] retain];
		
#if TARGET_OS_IPHONE		
		jailBroken = [[self isJailBrokenStr] retain];
		[self startReachabilityUpdates];
#endif
		[self generateClientDataString];
	}
	
	return self;
}

+ (StackMobClientData*) sharedClientData
{
	if(!_sharedInstance){
		_sharedInstance = [[StackMobClientData alloc] init];
	}
	return _sharedInstance;
}


- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding: NSUTF8StringEncoding];
    free(machine);
    return platform;
}

#if TARGET_OS_IPHONE
- (NSString *) platformString{
	NSString *platform = [self platform];
	
	if ([platform isEqualToString:@"iPhone1,1"])	return IPHONE_1G_NAMESTRING;
	if ([platform isEqualToString:@"iPhone1,2"])	return IPHONE_3G_NAMESTRING;
	if ([platform hasPrefix:@"iPhone2"])			return IPHONE_3GS_NAMESTRING;
	if ([platform hasPrefix:@"iPhone3"])			return IPHONE_4_NAMESTRING;
	if ([platform hasPrefix:@"iPhone4"])			return IPHONE_5_NAMESTRING;
	
	if ([platform isEqualToString:@"iPod1,1"])		return IPOD_1G_NAMESTRING;
	if ([platform isEqualToString:@"iPod2,1"])		return IPOD_2G_NAMESTRING;
	if ([platform isEqualToString:@"iPod3,1"])		return IPOD_3G_NAMESTRING;
	if ([platform isEqualToString:@"iPod4,1"])		return IPOD_4G_NAMESTRING;
	
	if ([platform isEqualToString:@"iPad1,1"])		return IPAD_1G_NAMESTRING;
	if ([platform isEqualToString:@"iPad2,1"])		return IPAD_2G_NAMESTRING;
	
	if ([platform isEqualToString:@"AppleTV2,1"])	return APPLETV_2G_NAMESTRING;
		
	if ([platform hasPrefix:@"iPhone"])				return IPHONE_UNKNOWN_NAMESTRING;
	if ([platform hasPrefix:@"iPod"])				return IPOD_UNKNOWN_NAMESTRING;
	if ([platform hasPrefix:@"iPad"])				return IPAD_UNKNOWN_NAMESTRING;
	
	if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
	{
		if ([[UIScreen mainScreen] bounds].size.width < 768)
			return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
		else 
			return IPHONE_SIMULATOR_IPAD_NAMESTRING;
	}
	if ([platform isEqualToString:@"iFPGA"])		return IFPGA_NAMESTRING;
	return IPOD_FAMILY_UNKNOWN_DEVICE;
}
#else
- (NSString *) platformString {
  return @"Mac OS X";
}
#endif

- (void)dealloc {
	[_sharedInstance release];
	[super dealloc];

}

#pragma mark - Properties

@synthesize clientDataString = _clientDataString;


#pragma mark -

- (void)generateClientDataString {
	device_name = [self platformString];
	NSMutableDictionary* clientDataObject = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
											 identifier, DEVICE_TAG_NAME,
											 model, DEVICE_TYPE_NAME,
											 device_name, DEVICE_NAME,
											 systemVersion, DEVICE_OS_VERSION_NAME,
											 bundleVersion, APP_VERSION_NAME,
											 LIBRARY_VERSION_NUMBER,LIBRARY_VERSION_NAME,
											 countryCode, DEVICE_COUNTRY_CODE,
											 language, DEVICE_LANGUAGE,
											 jailBroken, DEVICE_IS_JAILBORKEN,
											 nil];

	SMLog(@"data %@", clientDataObject);
#if TARGET_OS_IPHONE  
	NetworkStatus newStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	switch (newStatus) {
		case ReachableViaWWAN:
			[clientDataObject setValue:@"m" forKey:NETWORK_AVAILABILITY]; // reachable via mobile network
			break;
		default: 
			[clientDataObject setValue:@"w" forKey:NETWORK_AVAILABILITY]; // reachable via wifi
			break;
	}
#endif	
  
	self.clientDataString = [clientDataObject JSONString];
    [clientDataObject release];
}

#if TARGET_OS_IPHONE  
#pragma mark - Reachability

- (void)startReachabilityUpdates {
	[Reachability reachabilityWithHostName:@"www.stackmob.com"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kReachabilityChangedNotification" object:nil];	
}

- (void)reachabilityChanged:(NSNotification *)note {
	[self generateClientDataString];
}

static const char* jailbreak_apps[] =
{
	"/Applications/Cydia.app", 
	"/Applications/limera1n.app", 
	"/Applications/greenpois0n.app", 
	"/Applications/blackra1n.app",
	"/Applications/blacksn0w.app",
	"/Applications/redsn0w.app",
	NULL,
};

- (BOOL) isJailBroken
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	
	// This key-value pair should not be in the pinfo file. If it is, we can be reasonably sure that the app has been compromised.
	if ([info objectForKey: @"SignerIdentity"] != nil)
	{
		return YES;
	}
	
	// Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
	for (int i = 0; jailbreak_apps[i] != NULL; ++i)
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
		{
			//NSLog(@"isjailbroken: %s", jailbreak_apps[i]);
			return YES;
		}		
	}
	
	// TODO: Add more checks? This is an arms-race we're bound to lose.
	
	return NO;
}


- (NSString*) isJailBrokenStr
{
	if ([self isJailBroken])
	{
		return @"42";
	}
	
	return @"0";
}
#endif

@end
