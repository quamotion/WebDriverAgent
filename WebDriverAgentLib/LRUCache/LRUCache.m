// File copied from https://github.com/gn0meavp/LRUCache
// and modified to meet the requirements of WebDriverAgentLib.
//
// Licensed under the MIT License:
// The MIT License (MIT)
// Copyright (c) 2015 Alexey Patosin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  LRUCache.m
//  LRUCache
//
//  Created by Alexey Patosin on 26/02/15.
//  Copyright (c) 2015 TestOrg. All rights reserved.
//

#import "LRUCache.h"
#import "LRUCacheNode.h"

static const char *kLRUCacheQueue = "kLRUCacheQueue";

@interface LRUCache ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) LRUCacheNode *rootNode;
@property (nonatomic, strong) LRUCacheNode *tailNode;
@property (nonatomic) NSUInteger size;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation LRUCache

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create(kLRUCacheQueue, 0);
        _capacity = capacity;
    }
    return self;
}

#pragma mark - set object / get object methods

- (void)setObject:(id)object forKey:(id<NSCopying>)key {
    
    NSAssert(object != nil, @"LRUCache cannot store nil object!");
    
    dispatch_barrier_async(self.queue, ^{
        LRUCacheNode *node = self.dictionary[key];
        if (node == nil) {
            node = [LRUCacheNode nodeWithValue:object key:key];
            self.dictionary[key] = node;
            self.size++;
            
            if (self.tailNode == nil) {
                self.tailNode = node;
            }
            if (self.rootNode == nil) {
                self.rootNode = node;
            }
        }
        
        [self putNodeToTop:node];
        [self checkSpace];
        
    });
}


- (id)objectForKey:(id<NSCopying>)key {
    __block LRUCacheNode *node = nil;
    
    dispatch_sync(self.queue, ^{
        node = self.dictionary[key];
        
        if (node) {
            [self putNodeToTop:node];
        }
        
    });
    
    return node.value;
}

#pragma mark - helper methods

- (void)putNodeToTop:(LRUCacheNode *)node {
    
    if (node == self.rootNode) {
        return;
    }
    
    if (node == self.tailNode) {
        self.tailNode = self.tailNode.prev;
    }
    
    self.rootNode.prev.next = node.next;
    
    LRUCacheNode *prevRoot = self.rootNode;
    self.rootNode = node;
    self.rootNode.next = prevRoot;
}

- (void)checkSpace {
    if (self.size > self.capacity) {
        LRUCacheNode *nextTail = self.tailNode.prev;
        [self.dictionary removeObjectForKey:self.tailNode.key];
        self.tailNode = nextTail;
        self.tailNode.next = nil;
        self.size--;
    }
}

@end
