//
//  BDImportService.m
//  GoldenSignal
//
//  Created by CBD on 7/6/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import "BDImportService.h"
#import "BDCoreService.h"
#import <AFNetworking.h>
#import "BDNewsList.h"//Model，用来存数据
#import "BDNewStockModel.h"//要闻 新股Model


@implementation BDImportService

/**
 *  获取要闻各个页面的数据
 *  @param pageId    不同页面对应的id
 *  @param lastId    列表最后一条的id
 *  @param cellNuber 列数 一般为10条
 *  @return 返回的数据 存入数组中
 */
- (NSMutableArray *)getImportNewsListRequestDataWithPageId:(int)pageId lastCellId:(long)lastId quantity:(int)cellCount{
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:[NSNumber numberWithInt:cellCount] forKey:@"COUNT"];
        [parameters setValue:[NSNumber numberWithLong:lastId] forKey:@"ID"];
        
        
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
        
        for (NSDictionary *item in data) {
            BDNewsList *newsModel = [[BDNewsList alloc] init];
            
            newsModel.title = item[@"TIT"];//标题
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            if (pageId == 1582) {
                formatter.dateFormat = @"yyyy-MM-dd";
            } else {
                formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            }
            
            newsModel.date = (item[@"PUB_DT"] == [NSNull null]) ? 0 : [formatter dateFromString:item[@"PUB_DT"]] ;//日期
            
            newsModel.media = item[@"MED_NAME"];//媒体名字
//            newsModel.companyName = item[@"COM_NAME"];
            newsModel.author = (item[@"AUT"] == [NSNull null]) ? @"" : item[@"AUT"];//作者名字
            newsModel.abstract = item[@"ABST"];//摘要
//            newsModel.ABST_SHT = item[@"ABST_SHT"];
            newsModel.connectId = [item[@"CONT_ID"] longValue];//正文内容对应的ID
            newsModel.innerId = [item[@"ID"]longValue];//lastId
            
            
            
            [list addObject:newsModel];
        }
        [watch stop];
        NSLog(@"Success: 加载要闻列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载要闻列表 %@",exception.reason);
    }
    return list;
}



/**
 *  获取要闻 策略页面的数据
 *  @param pageId    不同页面对应的id
 *  @param cellCount 列数 一般为10条
 *  @param index     次数 第几次
 *  @return 返回的数据 存入数组中
 */
- (NSMutableArray *)getImportNewsStrategyRequestDataWithPageId:(int)pageId cellCount:(int)cellCount timeNumber:(int)index {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:[NSNumber numberWithInt:cellCount] forKey:@"COUNT"];
        [parameters setValue:[NSNumber numberWithInt:index] forKey:@"INDEX"];
        
        
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
        
        for (NSDictionary *item in data) {
            BDNewsList *newsModel = [[BDNewsList alloc] init];
            
            newsModel.title = item[@"TIT"];//标题
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            if (pageId == 1582) {
                formatter.dateFormat = @"yyyy-MM-dd";
            } else {
                formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            }
            
            newsModel.date = (item[@"PUB_DT"] == [NSNull null]) ? 0 : [formatter dateFromString:item[@"PUB_DT"]] ;//日期
            
            newsModel.companyName = item[@"COM_NAME"];
            newsModel.author = (item[@"AUT"] == [NSNull null]) ? @"" : item[@"AUT"];//作者名字
            newsModel.abstract = item[@"ABST"];//摘要
            newsModel.connectId = [item[@"CONT_ID"] longValue];//正文内容对应的ID //lastId
            
            [list addObject:newsModel];
        }
        [watch stop];
        NSLog(@"Success: 加载要闻列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载要闻列表 %@",exception.reason);
    }
    return list;
}


/**
 *  获取要闻 新股页面的数据
 *  @param pageId    不同页面对应的id
 *  @param lastId    列表最后一条的id
 *  @param cellNumber 列数 一般为10条
 *  @return 返回的数据 存入数组中
 */
- (NSMutableArray *)getImportNewStockRequestDataWithPageId:(int)pageId lastCellId:(long)lastId quantity:(int)cellNumber{
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:[NSNumber numberWithInt:cellNumber] forKey:@"PSize"];
        [parameters setValue:[NSNumber numberWithInt:1] forKey:@"PIndex"];
        if (lastId != 0) {
            NSString *filter = [NSString stringWithFormat:@"{\"LeftPart\":\"ID\",\"RightPart\":%ld,\"Mode\":2}", lastId];
            [parameters setValue:filter forKey:@"filter"];
        }
        BDCoreService *service = [BDCoreService new];
        
        //如果没有数据，界面显示"近期无IPO新股申购"
        NSArray *dataArray = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
        //test
//        dataArray = @[@{@"SUB_BGN_DT_ON":@"11" , @"SECU_SHT":@"aaa"},
//                      @{@"SUB_BGN_DT_ON":@"11" , @"SECU_SHT":@"bbb"},
//                      @{@"SUB_BGN_DT_ON":@"11" , @"SECU_SHT":@"ccc"},
//                      @{@"SUB_BGN_DT_ON":@"22" , @"SECU_SHT":@"dddd"},
//                      @{@"SUB_BGN_DT_ON":@"22" , @"SECU_SHT":@"eeee"},
//                      @{@"SUB_BGN_DT_ON":@"333" , @"SECU_SHT":@"123"},
//                      @{@"SUB_BGN_DT_ON":@"333" , @"SECU_SHT":@"456"},
//                      @{@"SUB_BGN_DT_ON":@"333" , @"SECU_SHT":@"333"},
//                      @{@"SUB_BGN_DT_ON":@"333" , @"SECU_SHT":@"789"},];
        
        
        DEBUGLog(@"Debug:data>%@",dataArray);
        if (dataArray.count ==0) {
            list = nil;
        } else
        
        for (NSDictionary *item in dataArray) {
            BDNewStockModel *nsModel = [[BDNewStockModel alloc] init];
            nsModel.SECU_SHT = item[@"SECU_SHT"];
            nsModel.TRD_CODE = [item[@"TRD_CODE"] longValue];
            
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.dateFormat = @"YYYY-MM-DD DAY";
            nsModel.SUB_BGN_DT_ON = [formatter1 dateFromString:item[@"SUB_BGN_DT_ON"]];
            
//            nsModel.SUB_BGN_DT_ON = item[@"SUB_BGN_DT_ON"];
//            DEBUGLog(@"11Debug:%@,%@>" ,item[@"SUB_BGN_DT_ON"],item[@"SECU_SHT"]);
//            DEBUGLog(@"22Debug:%@,%@>",nsModel.SUB_BGN_DT_ON ,nsModel.SECU_SHT);
            
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.dateFormat = @"YYYY-MM";
            nsModel.ALOT_RSLT_NTC_DT = [formatter2 dateFromString:item[@"ALOT_RSLT_NTC_DT"]];
            
            nsModel.ISS_PRC     = [item[@"ISS_PRC"] floatValue];
            nsModel.PE_DIL      = [item[@"PE_DIL"]  floatValue];
            nsModel.SUB_SHR_ON  = [item[@"SUB_SHR_ON"] floatValue];
            nsModel.ISS_SHR     = [item[@"ISS_SHR"]  integerValue];
            
            [list addObject:nsModel];
        }
        
//        list = [NSMutableArray arrayWithArray:dataArray];
        [watch stop];
        DEBUGLog(@"Success: 加载要闻 新股列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载要闻 新股列表 %@",exception.reason);
    }
    return list;
}



/**
 *  获取要闻 新股 子页面 详细信息
 *
 *  @param connectId 连接的Id 即 股票代码
 *  @param pageId    页面数据源Id （1591）
 *
 *  @return Model
 */
- (BDNewStockModel *)getImportNewsStockDetailWithId:(long)connectId andPageId:(int)pageId{
    BDNewStockModel *newsModel = [BDNewStockModel new];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"id"];
    BDCoreService *service = [BDCoreService new];
    
    NSArray *dataAry = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
    for (NSDictionary *items in dataAry) {
        
        newsModel.TRD_CODE = connectId;//链接的id 股票代码
        
        //KVC赋值
        newsModel = [[BDNewStockModel alloc]initWithDictionary:(NSMutableDictionary *)items];
        
//        [newsModel setValuesForKeysWithDictionary:(NSMutableDictionary *)items]; //KVC
        
        break;
    }
    return newsModel;
}


- (NSMutableArray *)getImportNewsStockDetailById2:(long)connectId andPageId2:(int)pageId{
    NSMutableArray * souceArray = [NSMutableArray array];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"id"];
    BDCoreService *service = [BDCoreService new];
    
    NSArray *dataArray = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
//    //数组转NSData后 再变字典
//    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:dataArray] options:0 error:nil];
    
    //同forin 遍历一样
    [dataArray enumerateObjectsUsingBlock:^(NSObject *obj, NSUInteger idx, BOOL *stop) {
        //把json中 数组中 字典的数据 加入到Model中
        BDNewStockModel *nsModel = [[BDNewStockModel alloc]initWithDictionary:(NSMutableDictionary *)obj];
        nsModel.SUB_CODE = connectId;
        [souceArray addObject:nsModel];
    }];
    
    return souceArray;
}

@end
