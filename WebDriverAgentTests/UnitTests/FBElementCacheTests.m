/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "FBElementCache.h"
#import "XCUIElementDouble.h"

@interface FBElementCacheTests : XCTestCase
@property (nonatomic, strong) FBElementCache *cache;
@end

@implementation FBElementCacheTests

- (void)setUp
{
  [super setUp];
  self.cache = [FBElementCache new];
}

- (void)testStoringElement
{
  NSString *firstUUID = [self.cache storeElement:(XCUIElement *)XCUIElementDouble.new];
  NSString *secondUUID = [self.cache storeElement:(XCUIElement *)XCUIElementDouble.new];
  XCTAssertNotNil(firstUUID, @"Stored index should be higher than 0");
  XCTAssertNotNil(secondUUID, @"Stored index should be higher than 0");
  XCTAssertNotEqualObjects(firstUUID, secondUUID, @"Stored indexes should be different");
}

- (void)testFetchingElement
{
  XCUIElement *element = (XCUIElement *)XCUIElementDouble.new;
  NSString *uuid = [self.cache storeElement:element];
  XCTAssertNotNil(uuid, @"Stored index should be higher than 0");
  XCTAssertEqual(element, [self.cache elementForUUID:uuid]);
}

- (void)testFetchingBadIndex
{
  XCTAssertNil([self.cache elementForUUID:@"random"]);
}

- (void)testResolvingFetchedElement
{
  NSString *uuid = [self.cache storeElement:(XCUIElement *)XCUIElementDouble.new];
  XCUIElementDouble *element = (XCUIElementDouble *)[self.cache elementForUUID:uuid];
  XCTAssertTrue(element.didResolve);
}

- (void)testLinearCacheExpulsion
{
  NSMutableArray *elements = [NSMutableArray arrayWithCapacity:1050];
  NSMutableArray *elementIds = [NSMutableArray arrayWithCapacity:1050];
  for(int i = 0; i < 1050; i++) {
    [elements addObject:(XCUIElement *)XCUIElementDouble.new];
  }
  
  // The capacity of the cache is limited to 1024 elements. Add 1050
  // elements and make sure:
  // - The first 26 elements are no longer present in the cache
  // - The remaining 1024 elements are present in the cache
  for(int i = 0; i < 1050; i++) {
    [elementIds addObject:[self.cache storeElement:elements[i]]];
  }
  
  for(int i = 0; i < 26; i++) {
    XCTAssertNil([self.cache elementForUUID:elementIds[i]]);
  }
  for(int i = 27; i < 1050; i++) {
    XCTAssertEqual(elements[i], [self.cache elementForUUID:elementIds[i]]);
  }
}

- (void)testMRUCacheExpulsion
{
  NSMutableArray *elements = [NSMutableArray arrayWithCapacity:1050];
  NSMutableArray *elementIds = [NSMutableArray arrayWithCapacity:1050];
  for(int i = 0; i < 1050; i++) {
    [elements addObject:(XCUIElement *)XCUIElementDouble.new];
  }
  
  // The capacity of the cache is limited to 1024 elements. Add 1050
  // elements, but with a twist: access the first 24 elements before
  // adding the last 50 elements. Then, make sure:
  // - The first 24 elements are present in the cache
  // - The next 26 elements are not present in the cache
  // - The remaining 1000 elements are present in the cache
  for(int i = 0; i < 1000; i++) {
    [elementIds addObject:[self.cache storeElement:elements[i]]];
  }
  
  for(int i = 0; i <= 24; i++) {
    [self.cache elementForUUID:elementIds[i]];
  }
     
  for(int i = 1000; i < 1050; i++) {
    [elementIds addObject:[self.cache storeElement:elements[i]]];
  }
  
  for(int i = 0; i < 24; i++) {
    XCTAssertEqual(elements[i], [self.cache elementForUUID:elementIds[i]]);
  }
  for(int i = 25; i < 51; i++) {
    XCTAssertNil([self.cache elementForUUID:elementIds[i]]);
  }
  for(int i = 51; i < 1050; i++) {
    XCTAssertEqual(elements[i], [self.cache elementForUUID:elementIds[i]]);
  }
}

@end
