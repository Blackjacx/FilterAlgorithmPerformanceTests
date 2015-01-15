//
//  TestPMTests.m
//  TestPMTests
//
//  Created by Stefan Herold on 16/06/14.
//  Copyright (c) 2014 Stefan Herold. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestPMTests : XCTestCase
@property(nonatomic, copy)NSArray *largeListOfDictionaries;
@property(nonatomic, copy)NSString *jsonKeyPath;
@property(nonatomic, copy)NSString *jsonValue;
@end

@implementation TestPMTests

- (void)setUp {
    [super setUp];
	
	self.jsonKeyPath = @"name";
	self.jsonValue = @"Gainsboro";
	
	NSString *localJSONPath = [[NSBundle mainBundle] pathForResource:@"webcolors" ofType:@"json"];
	NSData *JSONData = [[NSFileManager defaultManager] contentsAtPath:localJSONPath];
	NSArray *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
	self.largeListOfDictionaries = [NSMutableArray array];
	
	// Upscale the array to get readable results
	for (int i=0; i<100; i++) {
		self.largeListOfDictionaries = [self.largeListOfDictionaries arrayByAddingObjectsFromArray:JSONObject];
	}
}

- (void)testPerformancePredicateWithFormat {
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.%@ == %@", self.jsonKeyPath, self.jsonValue];
	__block NSArray *filtered = nil;
	
	[self measureBlock:^{
		filtered = [self.largeListOfDictionaries filteredArrayUsingPredicate:pred];
	}];
	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}

- (void)testPerformancePredicateWithBlock {
	NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *d, NSDictionary *bindings) {
		return [d[self.jsonKeyPath] isEqualToString:self.jsonValue];
	}];
	
	__block NSArray *filtered = nil;
	
	[self measureBlock:^{
		filtered = [self.largeListOfDictionaries filteredArrayUsingPredicate:pred];
	}];
	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}

- (void)testPerformanceIndexesOfObjectsPassingTest {
	__block NSArray *filtered = nil;
	
	[self measureBlock:^{
		
		// Returns a SORTED set of indexes
		NSIndexSet *matchingIndexes = [self.largeListOfDictionaries indexesOfObjectsPassingTest:^BOOL(NSDictionary *d, NSUInteger idx, BOOL *stop) {
			return [d[self.jsonKeyPath] isEqualToString:self.jsonValue];
		}];
		
		filtered = [self.largeListOfDictionaries objectsAtIndexes:matchingIndexes];
	}];
	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}

- (void)testPerformanceIndexesOfObjectsPassingTestConcurrent {
	__block NSArray *filtered = nil;
	
	[self measureBlock:^{
		// Returns a SORTED set of indexes
		NSIndexSet *matchingIndexes = [self.largeListOfDictionaries indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(NSDictionary *d, NSUInteger idx, BOOL *stop) {
			return [d[self.jsonKeyPath] isEqualToString:self.jsonValue];
		}];
		
		filtered = [self.largeListOfDictionaries objectsAtIndexes:matchingIndexes];
	}];
	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}

- (void)testPerformanceFastEnumeration {
	__block NSMutableArray *filtered = nil;
	[self measureBlock:^{
		filtered = [[NSMutableArray alloc] init];
		for (NSDictionary *d in self.largeListOfDictionaries) {
			if ([d[self.jsonKeyPath] isEqualToString:self.jsonValue]) {
				[filtered addObject:d];
			}
		}
	}];
	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}

- (void)testPerformanceEnumerationBlock {
	__block NSMutableArray *filtered = nil;
	[self measureBlock:^{
		filtered = [[NSMutableArray alloc] init];
		[self.largeListOfDictionaries enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
			if ([d[self.jsonKeyPath] isEqualToString:self.jsonValue]) {
				[filtered addObject:d];
			}
		}];
	}];
	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}

- (void)testPerformanceEnumerationConcurrent {
	__block NSMutableArray *filtered = nil;
	[self measureBlock:^{
		filtered = [[NSMutableArray alloc] init];
		[self.largeListOfDictionaries enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
			if ([d[self.jsonKeyPath] isEqualToString:self.jsonValue]) {
				dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					[filtered addObject:d];
				});
			}
		}];
	}];
//	NSLog(@"❤️Count: %lu", (unsigned long)filtered.count);
}


@end


