//
//  BDNewsService.m
//  CBNAPP
//
//  Created by Frank on 14/11/10.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDNewsEventService.h"
#import "BDNetworkService.h"
#import "BDCoreService.h"

@implementation BDNewsEventService

- (BDNewsEventDetail *)getNewsEventDetailById:(long)innerId {
    Stopwatch *watch = [Stopwatch startNew];
    BDNewsEventDetail *detail = nil;
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"NewsEventDetailService.Gets" forKey:@"Service"];
    [parameters setValue:@"GetsService" forKey:@"Function"];
    [parameters setValue:[NSNumber numberWithLong:innerId] forKey:@"id"];
    [parameters setValue:@"JSON" forKey:@"ATYPE"];

    @try {
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        detail = [self paraseNewsEventDetail:data];
        
        [watch stop];
        NSLog(@"Success: 加载新闻内容 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载新闻内容 %@",exception.reason);
    }
    @finally {
        return detail;
    }
}

- (NSArray *)getNewsEventListBySecuCodes:(NSArray *)codes tagId:(long)tagId lastId:(long)lastId quantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *newsArray = nil;
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"NewsEventService.Gets" forKey:@"Service"];
    [parameters setValue:@"GetsService" forKey:@"Function"];
    [parameters setValue:[NSNumber numberWithLong:tagId] forKey:@"label"];
    [parameters setObject:[NSNumber numberWithLong:lastId] forKey:@"lastId"];
    [parameters setObject:[NSNumber numberWithInt:quantity] forKey:@"count"];
    if (codes.count > 0) {
        NSString *codeString = [codes componentsJoinedByString:@","];
        [parameters setObject:codeString forKey:@"secuCode"];
    }
    [parameters setValue:@"JSON" forKey:@"ATYPE"];
    
    @try {
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        newsArray = [self paraseNewsEventList:data];
        
        [watch stop];
        NSLog(@"Success: 加载新闻列表 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载新闻列表 %@",exception.reason);
    }
    @finally {
        return  newsArray;
    }
}


#pragma mark - parsing

// 解析新闻事件列表数据
- (NSArray *)paraseNewsEventList:(NSData *)data {
    NSMutableArray *newsArray = [NSMutableArray array];
    if (data == nil) {
        return newsArray;
    }
    
    BDCoreService *service = [[BDCoreService alloc] init];
    NSArray *allData = [service dataConvertToNSArray:data];
    NSArray *newsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    for (NSDictionary *item in newsData) {
        BDNewsEventList *news = [[BDNewsEventList alloc] init];
        news.innerId = [item[@"ID"] longValue];
        news.title = item[@"TIT"];
        news.date = [service deserializeJsonDateString:item[@"PUB_DT"]];
        news.abstract = [item[@"ABST"] isKindOfClass:[NSNull class]]? @"" :item[@"ABST"];
        
        NSData *markData = [item[@"MARKS"] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *markArray = [NSJSONSerialization JSONObjectWithData:markData options:NSJSONReadingMutableLeaves error:&error];
        for (NSDictionary *item in markArray) {
            BDNewsTag *label = [[BDNewsTag alloc] init];
            label.innerId = [item[@"ID"] longValue];
            label.name = item[@"NAME"];
            label.type = [item[@"TYPE"] intValue];
            label.bdCode = item[@"BD_CODE"];
            
            // 添加新闻标签
            if (label.type == 2) {
                int evt_dir = [item[@"EVT_DIR"] intValue];
                int evt_st = [item[@"EVT_ST"] intValue];
                if (evt_dir == 1 && evt_st == 5) {
                    label.effect = PositivePlus;
                }
                else if (evt_dir == 1 && evt_st != 5) {
                    label.effect = Positive;
                }
                else if (evt_dir == 0) {
                    label.effect = Neutral;
                }
                else if (evt_dir == -1 && evt_st != 5) {
                    label.effect = Negative;
                }
                else if (evt_dir == -1 && evt_st == 5) {
                    label.effect = NegativeMinus;
                }
                else {
                    label.effect = None;
                }
            }
            else {
                label.effect = None;
            }
            [news.labels addObject:label];
        }
        
        [newsArray addObject:news];
    }
    return newsArray;
}

// 解析新闻事件详情数据
- (BDNewsEventDetail *)paraseNewsEventDetail:(NSData *)data {
    BDNewsEventDetail *detail = nil;
    if (data == nil) {
        return detail;
    }
    BDCoreService *service = [[BDCoreService alloc] init];
    NSArray *allData = [service dataConvertToNSArray:data];
    NSArray *newsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    for (NSDictionary *item in newsData) {
        detail = [[BDNewsEventDetail alloc] init];
        detail.innerId = [item[@"ID"] longValue];
        detail.title = item[@"TIT"];
        detail.date = [service deserializeJsonDateString:item[@"PUB_DT"]];
        detail.content = [item[@"CONT"] isKindOfClass:[NSNull class]]? @"" :item[@"CONT"];
        detail.media = [item[@"MED_NAME"] isKindOfClass:[NSNull class]]? @"" :item[@"MED_NAME"];
        detail.author = [item[@"AUT"] isKindOfClass:[NSNull class]]? @"" :item[@"AUT"];
        break;
    }
    return detail;
}

@end
