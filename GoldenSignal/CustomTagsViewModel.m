//
//  CustomTagsViewModel.m
//  CBNAPP
//
//  Created by Frank on 14-10-13.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "CustomTagsViewModel.h"
#import "BDNetworkService.h"
#import "BDCoreService.h"

@implementation CustomTagsViewModel
{
    NSArray *_allTags;
}

- (id)init {
    self = [super init];
    if (self) {
        /* 加载全部新闻标签 */
        _allTags = [NSKeyedUnarchiver unarchiveObjectWithFile:allTagsPath];
        if (_allTags == nil || _allTags.count == 0) {
            NSHTTPURLResponse *response;
            NSError *error;
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"NewsLabelService.Gets" forKey:@"Service"];
            [parameters setValue:@"GetsService" forKey:@"Function"];
            [parameters setValue:@"Getmk" forKey:@"op"];
            [parameters setValue:@"JSON" forKey:@"ATYPE"];
            
            @try {
                NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
                _allTags = [self paraseNewsTags:data];
                [NSKeyedArchiver archiveRootObject:_allTags toFile:allTagsPath];
            }
            @catch (NSException *exception) {
                NSLog(@"加载新闻标签出错：%@",exception);
            }
        }

        /* 设置默认选中的一级标签 */
        NSArray *topTags = self.topTags;
        if (topTags.count > 0) {
            self.selectedTag = topTags[0];
        }
        else {
            self.selectedTag = nil;
        }
    }
    return self;
}

// 添加用户定制标签
- (void)addTag:(BDNewsTag *)tag {
    BDCustomTagCollection *tagCollection = [BDCustomTagCollection sharedInstance];
    [tagCollection addTag:tag];
}

// 删除用户定制标签
- (void)removeTagById:(long)tagId {
    BDCustomTagCollection *tagCollection = [BDCustomTagCollection sharedInstance];
    [tagCollection removeTagById:tagId];
}

// 获取一级标签
- (NSArray *)getTopTags {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentId = 96"];
    NSArray *tags = [_allTags filteredArrayUsingPredicate:predicate];
    return tags;
}

// 获取二级标签
- (NSArray *)getSubTags {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentId = %ld", self.selectedTag.innerId];
    NSArray *tags = [_allTags filteredArrayUsingPredicate:predicate];
    return tags;
}


#pragma mark - parsing

// 解析新闻标签数据
- (NSArray *)paraseNewsTags:(NSData *)data {
    BDCoreService *service = [[BDCoreService alloc] init];
    NSArray *allData = [service dataConvertToNSArray:data];
    NSArray *newsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    
    NSMutableArray *tagArray = [NSMutableArray array];
    for (NSDictionary *item in newsData) {
        if (item[@"P_LABEL_ID"] != [NSNull null]) {
            BDNewsTag *label = [[BDNewsTag alloc] init];
            label.innerId = [item[@"LABEL_ID"] longValue];
            label.name = item[@"LABEL_NAME"];
            label.type = [item[@"LABEL_TYPE"] intValue];
            label.parentId = [item[@"P_LABEL_ID"] intValue];
            [tagArray addObject:label];
        }
    }
    return tagArray;
}

@end
