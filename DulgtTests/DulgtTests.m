//
//  DulgtTests.m
//  DulgtTests
//
//  Created by Erik Engheim on 5/12/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TLPasswordGenerator.h"

@interface DulgtTests : XCTestCase

@end

@implementation DulgtTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

NSString *parseLoginData(NSString *s) {
    NSScanner *scanner = [[NSScanner alloc] initWithString:s];
    
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:200];
    while (![scanner isAtEnd]) {
        TLLogin *login = [[TLLogin alloc] initFromScanner:scanner];
        [buffer appendString:[login colonSeparatedData]];
    }
    return buffer;
}

- (void)testNonEmptyUsernameAndTargt {
    NSString *s = @"work:bitbucket:8:$s1$0e0801$tghBmw2qsV791B3xySqnzw==$81WJDwDo6aeVT6WozpY33EGpGlGsdgGPS8aYfo55XbxhsZXUgi8BQ1iNfJzJozxcLOnF6hAiMZInYKLtnQ+jLA==\n";
    
    NSString *buffer = parseLoginData(s);
    XCTAssertEqualObjects(buffer, s, @"Parsing and then encoding a line in the password  cache file should yield the same result");
    
}

- (void)testEmptyUsernameAndTargt {
    NSString *s = @"::8:$s1$0e0801$vdqXaP2O0lcXYgTXdvuwIw==$+vOVdN8CwxXKtqjbnYBBjO8Abu8PurF6CGgP1xp7Ma0ZXAjvLwlHMkz0MyE8iaUsdUrqYJe3b4DF65JFoB/oRQ==\n";
    
    NSString *buffer = parseLoginData(s);
    XCTAssertEqualObjects(buffer, s, @"Parsing and then encoding a line in the password  cache file should yield the same result");
}


- (void)testParsingCachedLoginData {
    NSString *s = @"work:bitbucket:8:$s1$0e0801$tghBmw2qsV791B3xySqnzw==$81WJDwDo6aeVT6WozpY33EGpGlGsdgGPS8aYfo55XbxhsZXUgi8BQ1iNfJzJozxcLOnF6hAiMZInYKLtnQ+jLA==\n::8:$s1$0e0801$vdqXaP2O0lcXYgTXdvuwIw==$+vOVdN8CwxXKtqjbnYBBjO8Abu8PurF6CGgP1xp7Ma0ZXAjvLwlHMkz0MyE8iaUsdUrqYJe3b4DF65JFoB/oRQ==\n";
    
    NSString *buffer = parseLoginData(s);
    XCTAssertEqualObjects(buffer, s, @"Parsing and then encoding a line in the password  cache file should yield the same result");
}

@end
