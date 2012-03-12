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

#import "SMFileTest.h"

@implementation SMFileTest
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testJSONSerializastion {
    NSData *data = [@"w00t!" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *fName = @"test.jpg";
    NSString *contentType = @"image/jpg";
    SMFile *file =  [[SMFile alloc] initWithFileName:fName data:data contentType:contentType];
    NSString *encodedString = [data base64EncodedString];
    
    NSString *expectedResult = [NSString stringWithFormat:@"Content-Type: %@\n"
                                "Content-Disposition: attachment; filename=%@\n"
                                "Content-Transfer-Encoding: base64\n\n"
                                "%@", contentType, fName, encodedString];
    NSString * actualResult = [file JSON];
    bool result = [expectedResult isEqualToString:actualResult];
    STAssertTrue(result, @"JSON serialization failed");
    [file release];
}


@end