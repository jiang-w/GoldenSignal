//
//  BDCustomTagCollection.m
//  CBNAPP
//
//  Created by Frank on 14/10/21.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDCustomTagCollection.h"
#import "BDNetworkService.h"
#import "BDCoreService.h"

@implementation BDCustomTagCollection

@synthesize tags;

+ (instancetype) sharedInstance {
    static dispatch_once_t  onceToken;
    static BDCustomTagCollection *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDCustomTagCollection alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        tags = [NSKeyedUnarchiver unarchiveObjectWithFile:customTagsPath];
        if (tags == nil || tags.count == 0) {
            // 首次使用系统默认新闻栏目标签，并归档
            NSHTTPURLResponse *response;
            NSError *error;
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"NewsLabelService.Gets" forKey:@"Service"];
            [parameters setValue:@"GetsService" forKey:@"Function"];
            [parameters setValue:@"Gethotmk" forKey:@"op"];
            [parameters setValue:@"JSON" forKey:@"ATYPE"];
            
            @try {
                NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 1"];
                tags = [NSMutableArray arrayWithArray:[[self paraseNewsTags:data] filteredArrayUsingPredicate:predicate]];
                [self archive];
            }
            @catch (NSException *exception) {
                NSLog(@"Failure: 加载用户定制新闻标签 %@",exception.reason);
            }
        }

    }
    return self;
}

// 判断用户定制的标签中是否包含此标签
- (BOOL)IsCustomized:(BDNewsTag *)tag {
    if (tag) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"innerId = %ld", tag.innerId];
        int count = (int)[tags filteredArrayUsingPredicate:predicate].count;
        if (count > 0) {
            return YES;
        }
    }
    return NO;
}

// 添加用户定制标签
- (void)addTag:(BDNewsTag *)tag {
    if (tag) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"innerId = %ld", tag.innerId];
        int count = (int)[tags filteredArrayUsingPredicate:predicate].count;
        if (count > 0) {
            return;
        }
        [tags addObject:tag];
        [self archive];
        
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification postNotificationName:TAGS_CHANGED_NOTIFICATION object:nil];
    }
}

// 删除用户定制标签
- (void)removeTagById:(long)tagId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"innerId = %ld", tagId];
    [tags removeObjectsInArray:[tags filteredArrayUsingPredicate:predicate]];
    [self archive];
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:TAGS_CHANGED_NOTIFICATION object:nil];
}


// 数据归档
- (void)archive {
    [NSKeyedArchiver archiveRootObject:tags toFile:customTagsPath];
}

// 交换两标签位置
- (void)exchangeTagAtIndex:(NSUInteger)index1 withTagAtIndex:(NSUInteger)index2 {
    [tags exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [self archive];
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:TAGS_SORTED_NOTIFICATION object:nil];
}

#pragma mark - parsing

// 解析新闻标签数据
- (NSArray *)paraseNewsTags:(NSData *)data {
    BDCoreService *service = [[BDCoreService alloc] init];
    NSArray *allData = [service dataConvertToNSArray:data];
    NSArray *newsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    
    NSMutableArray *tagArray = [NSMutableArray array];
    for (NSDictionary *item in newsData) {
        BDNewsTag *label = [[BDNewsTag alloc] init];
        label.innerId = [item[@"LABEL_ID"] longValue];
        label.name = item[@"LABEL_NAME"];
        label.type = [item[@"LABEL_TYPE"] intValue];
        label.parentId = [item[@"P_LABEL_ID"] intValue];
        [tagArray addObject:label];
    }
    return tagArray;
}

@end
