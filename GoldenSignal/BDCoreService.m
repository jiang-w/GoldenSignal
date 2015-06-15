//
//  BDCoreService.m
//  yicai_iso
//
//  Created by Frank on 14-7-31.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDCoreService.h"
#import "BDNetworkService.h"

@implementation BDCoreService

- (NSArray *) syncRequestDatasourceService:(int)objId parameters:(NSDictionary *)parameters query:(BDQuery *)query pageSize:(int)pageSize pageIndex:(int)pageIndex recordCount:(int *)recordCount pageCount:(int *)pageCount {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *dataArray = nil;
    NSMutableDictionary *comboParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [comboParams setValue:@"DataSourceService.Gets" forKey:@"Service"];
    [comboParams setValue:@"GetsService" forKey:@"Function"];
    [comboParams setValue:@"JSON" forKeyPath:@"atype"];
    [comboParams setValue:[NSNumber numberWithInt:objId] forKey:@"ObjId"];
    if (query) {
        [comboParams setValue:[query serializeToJson] forKeyPath:@"filter"];
    }
    [comboParams setValue:[NSNumber numberWithInt:pageSize] forKeyPath:@"pSize"];
    [comboParams setObject:[NSNumber numberWithInt:pageIndex] forKey:@"pIndex"];
    
    @try {
        BDNetworkService *netService = [BDNetworkService sharedInstance];
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *data = [netService syncPostRequest:POSTURL parameters:comboParams returnResponse:&response error:&error];
        
        NSDictionary *dataDic = [self parasePagingDataSource:data];
        dataArray = [dataDic objectForKey:@"data"];
        if (recordCount) {
            *recordCount = (int)[dataDic objectForKey:@"rCount"];
        }
        if (pageCount) {
            *pageCount = (int)[dataDic objectForKey:@"pCount"];
        }
        
        [watch stop];
        NSLog(@"Success: 加载数据源(OBJ_ID:%d) Timeout:%.3fs Count:%lu",
              objId, watch.elapsed, (unsigned long)dataArray.count);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载数据源(OBJ_ID:%d) %@", objId, exception.reason);
    }
    @finally {
        return dataArray;
    }
}

- (NSArray *)syncRequestDatasourceService:(int)objId parameters:(NSDictionary *)parameters query:(BDQuery *)query {
    Stopwatch *watch = [Stopwatch startNew];
    NSArray *dataArray = nil;
    NSMutableDictionary *comboParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [comboParams setValue:@"DataSourceService.Gets" forKey:@"Service"];
    [comboParams setValue:@"GetsService" forKey:@"Function"];
    [comboParams setValue:@"JSON" forKeyPath:@"atype"];
    [comboParams setValue:[NSNumber numberWithInt:objId] forKey:@"ObjId"];
    if (query) {
        [comboParams setValue:[query serializeToJson] forKeyPath:@"filter"];
    }
    
    @try {
        BDNetworkService *netService = [BDNetworkService sharedInstance];
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *data = [netService syncPostRequest:POSTURL parameters:comboParams returnResponse:&response error:&error];
        dataArray = [self paraseDataSource:data];
        
        [watch stop];
        NSLog(@"Success: 加载数据源(OBJ_ID:%d) Timeout:%.3fs Count:%lu",
              objId, watch.elapsed, (unsigned long)dataArray.count);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载数据源(OBJ_ID:%d) %@", objId, exception.reason);
    }
    @finally {
        return dataArray;
    }
}


#pragma mark

- (NSArray *)dataConvertToNSArray:(NSData *)data {
    NSRange r1 = {0, 1};
    operStatus status = error;   // 0： 失败 1：成功
    [data getBytes:&status range:r1];
    if (status == ok) {
        NSRange r2 = {1, 1};
        Byte format;     // 1:JSON  2:OPENFAST
        [data getBytes:&format range:r2];
        
        if (format == 1) {
            NSRange range = {2, [(NSData *)data length] - 2};
            NSData *jsonData = [(NSData *)data subdataWithRange:range];
            
            NSError *error;
            NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
            return array;
        }
    }
    else {
        NSException *ex = [NSException exceptionWithName:@"DataSourceServiceException"
                                                  reason:[NSString stringWithFormat:@"Status:%d", status] userInfo:nil];
        @throw(ex);
    }
    return nil;
}

// 解析数据源分页数据
- (NSDictionary *)parasePagingDataSource:(NSData *)data {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *allData = [self dataConvertToNSArray:data];
    
    NSArray *dsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    [dic setObject:dsData forKey:@"data"];
    
    NSArray *summaryData = [[allData objectAtIndex:1] objectForKey:@"DATA"];
    int pcount = [[[summaryData objectAtIndex:2] objectForKey:@"value"] intValue];
    int rcount = [[[summaryData objectAtIndex:3] objectForKey:@"value"] intValue];
    [dic setObject:[NSNumber numberWithInt:pcount] forKey:@"pCount"];
    [dic setObject:[NSNumber numberWithInt:rcount] forKey:@"rCount"];
    
    return dic;
}

// 解析数据源数据
- (NSArray *)paraseDataSource:(NSData *)data {
    NSArray *allData = [self dataConvertToNSArray:data];
    NSArray *dsData = [[allData objectAtIndex:0] objectForKey:@"DATA"];
    return dsData;
}

// 将json日期格式字符串转换为NSDate类型
- (NSDate *)deserializeJsonDateString:(NSString *)jsonDateString
{
    NSInteger offset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; //get number of seconds to add or subtract according to the client default time zone
    
    NSInteger startPosition = [jsonDateString rangeOfString:@"("].location + 1; //start of the date value
    
    NSTimeInterval unixTime = [[jsonDateString substringWithRange:NSMakeRange(startPosition, 13)] doubleValue] / 1000; //WCF will send 13 digit-long value for the time interval since 1970 (millisecond precision) whereas iOS works with 10 digit-long values (second precision), hence the divide by 1000
    NSDate *ret = [[NSDate dateWithTimeIntervalSince1970:unixTime] dateByAddingTimeInterval:offset];
    return ret;
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSDate* outputDate = [formatter dateFromString:jsonDateString];
//    return outputDate;
}

@end
