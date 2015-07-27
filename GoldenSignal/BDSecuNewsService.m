//
//  BDBulletinService.m
//  CBNAPP
//
//  Created by Frank on 14/12/16.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDSecuNewsService.h"
#import "BDCoreService.h"
#import "BDNetworkService.h"

@implementation BDSecuNewsService

- (NSArray *)getBulletinBySecuCode:(NSString *)code andSN:(long)sn andQuantity:(int)quantity {
    NSMutableArray *bulletinArray = [NSMutableArray array];
    BDCoreService *service = [BDCoreService new];
    NSDictionary *paramDic = @{@"BD_CODE": [NSString stringWithFormat:@"\'%@\'",code],
                               @"filter": [NSString stringWithFormat:@"{\"LeftPart\":{\"LeftPart\":\"SN\",\"RightPart\":%ld,\"Mode\":0},\"RightPart\":{\"LeftPart\":\"SN\",\"RightPart\":%ld,\"Mode\":3},\"Mode\":9}", sn, sn + quantity]};
    NSArray *data = [service syncRequestDatasourceService:1549 parameters:paramDic query:nil];
    for (NSDictionary *item in data) {
        BDBulletin *bulletin = [[BDBulletin alloc] init];
        bulletin.innerId = [item[@"ID"] longValue];
        bulletin.title = item[@"TIT"];
        bulletin.date = [service deserializeJsonDateString:item[@"PUB_DT"]];
        bulletin.sn = [item[@"SN"] longValue];
        [bulletinArray addObject:bulletin];
    }
    return bulletinArray;
}

- (NSArray *)getReportBySecuCode:(NSString *)code andSN:(long)sn andQuantity:(int)quantity {
    NSMutableArray *reportArray = [NSMutableArray array];
    BDCoreService *service = [BDCoreService new];
    NSDictionary *paramDic = @{@"BD_CODE": [NSString stringWithFormat:@"\'%@\'",code],
                               @"filter": [NSString stringWithFormat:@"{\"LeftPart\":{\"LeftPart\":\"SN\",\"RightPart\":%ld,\"Mode\":0},\"RightPart\":{\"LeftPart\":\"SN\",\"RightPart\":%ld,\"Mode\":3},\"Mode\":9}", sn, sn + quantity]};
    NSArray *data = [service syncRequestDatasourceService:1550 parameters:paramDic query:nil];
    for (NSDictionary *item in data) {
        BDReportList *report = [[BDReportList alloc] init];
        report.innerId = [item[@"ID"] longValue];
        report.title = item[@"TIT"];
        report.date = [service deserializeJsonDateString:item[@"PUB_DT"]];
        report.sn = [item[@"SN"] longValue];
        [reportArray addObject:report];
    }
    return reportArray;
}

- (NSArray *)getNewsEventBySecuCode:(NSString *)code andSN:(long)sn andQuantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *newsArray = nil;
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"NewsEventService.Gets" forKey:@"Service"];
    [parameters setValue:@"GetsService" forKey:@"Function"];
    [parameters setValue:code forKey:@"secuCode"];
    [parameters setObject:[NSNumber numberWithLong:sn] forKey:@"lastId"];
    [parameters setObject:[NSNumber numberWithInt:quantity] forKey:@"count"];
    [parameters setValue:@"JSON" forKey:@"ATYPE"];
    
    @try {
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        newsArray = [self paraseNews:data];
        
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

- (NSArray *)getNewsListBySecuCode:(NSString *)code andQuantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *newsArray = nil;
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"StockInfoTxtService.Gets" forKey:@"Service"];
    [parameters setValue:@"GetsService" forKey:@"Function"];
    [parameters setValue:@"news" forKey:@"type"];
    [parameters setValue:code forKey:@"secuCode"];
    [parameters setObject:[NSNumber numberWithLong:0] forKey:@"lastId"];
    [parameters setObject:[NSNumber numberWithInt:quantity] forKey:@"count"];
    [parameters setValue:@"JSON" forKey:@"ATYPE"];
    
    @try {
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        newsArray = [self paraseStockInfoList:data];
        
        [watch stop];
        NSLog(@"Success: 加载个股新闻列表 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载个股新闻列表 %@",exception.reason);
    }
    @finally {
        return  newsArray;
    }
}

- (NSArray *)getBulletinListBySecuCode:(NSString *)code andQuantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *newsArray = nil;
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"StockInfoTxtService.Gets" forKey:@"Service"];
    [parameters setValue:@"GetsService" forKey:@"Function"];
    [parameters setValue:@"bulletin" forKey:@"type"];
    [parameters setValue:code forKey:@"secuCode"];
    [parameters setObject:[NSNumber numberWithLong:0] forKey:@"lastId"];
    [parameters setObject:[NSNumber numberWithInt:quantity] forKey:@"count"];
    [parameters setValue:@"JSON" forKey:@"ATYPE"];
    
    @try {
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        newsArray = [self paraseStockInfoList:data];
        
        [watch stop];
        NSLog(@"Success: 加载个股公告列表 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载个股公告列表 %@",exception.reason);
    }
    @finally {
        return  newsArray;
    }
}

- (NSArray *)getReportListBySecuCode:(NSString *)code andQuantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *newsArray = nil;
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"StockInfoTxtService.Gets" forKey:@"Service"];
    [parameters setValue:@"GetsService" forKey:@"Function"];
    [parameters setValue:@"report" forKey:@"type"];
    [parameters setValue:code forKey:@"secuCode"];
    [parameters setObject:[NSNumber numberWithLong:0] forKey:@"lastId"];
    [parameters setObject:[NSNumber numberWithInt:quantity] forKey:@"count"];
    [parameters setValue:@"JSON" forKey:@"ATYPE"];
    
    @try {
        NSData *data = [[BDNetworkService sharedInstance] syncPostRequest:POSTURL parameters:parameters returnResponse:&response error:&error];
        newsArray = [self paraseStockInfoList:data];
        
        [watch stop];
        NSLog(@"Success: 加载个股研报列表 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载个股研报列表 %@",exception.reason);
    }
    @finally {
        return  newsArray;
    }
}


#pragma mark - parsing

// 解析新闻数据
- (NSArray *)paraseNews:(NSData *)data {
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

// 解析新闻列表数据
- (NSArray *)paraseStockInfoList:(NSData *)data {
    NSMutableArray *newsArray = [NSMutableArray array];
    if (data == nil) {
        return newsArray;
    }
    
    BDCoreService *service = [[BDCoreService alloc] init];
    NSArray *allData = [service dataConvertToNSArray:data];
    NSArray *newsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    for (NSDictionary *item in newsData) {
        BDNewsList *news = [[BDNewsList alloc] init];
        news.innerId = [item[@"ID"] longValue];
        news.title = item[@"TIT"];
        news.date = [service deserializeJsonDateString:item[@"PUB_DT"]];
        [newsArray addObject:news];
    }
    return newsArray;
}


- (NSArray *)getListWithSecuCode:(NSString *)code type:(NewsType)type quantity:(NSUInteger)quantity {
    NSMutableArray *list = [NSMutableArray array];
    switch (type) {
        case NWS:
            
            break;
            
        default:
            break;
    }
    
    return list;
}

@end
