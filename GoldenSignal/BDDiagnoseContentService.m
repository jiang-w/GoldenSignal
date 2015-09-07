//
//  BDDiagnoseContentService.m
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDDiagnoseContentService.h"
#import "BDCoreService.h"
#import "BDDiagnoseModel.h"

@implementation BDDiagnoseContentService


///资金的
- (NSMutableArray *)getDiagnoseEachPageWithPageId:(int)pageSourceId andBD_CODE:(NSString *)bd_code andDays:(NSInteger)days{
    NSMutableArray *endArray = [NSMutableArray array];
    BDDiagnoseModel *diagnoseModel = [BDDiagnoseModel new];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:bd_code forKey:@"BD_CODE"];
    [parameters setValue:[NSNumber numberWithInteger:days] forKey:@"days"];
    
    BDCoreService *service = [BDCoreService new];
    
    NSArray *dataAry = [service syncRequestDatasourceService:pageSourceId parameters:parameters query:nil];
    
    
    for (NSDictionary *items in dataAry) {
        
        //KVC赋值
        diagnoseModel = [[BDDiagnoseModel alloc]initWithDictionary:(NSMutableDictionary *)items];
        [endArray addObject:diagnoseModel];
    }
    return endArray;
}





//value	__NSCFString *	@"公司2014-12-31财报显示：\n盈利能力一般，每股收益0.1277元，净资产收益率3.53%；目前成长性不稳定，处于波动；负债较高，资产负债率76.54%，每元负债对应的经营活动现金流净额为0.10。"
- (NSMutableArray *)getDiagnoseEachPageWithPageId:(int)pageSourceId andBD_CODE:(NSString *)bd_code{
    NSMutableArray *endArray = [NSMutableArray array];
    BDDiagnoseModel *diagnoseModel = [BDDiagnoseModel new];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:bd_code forKey:@"BD_CODE"];
    
    BDCoreService *service = [BDCoreService new];
    
    NSArray *dataAry = [service syncRequestDatasourceService:pageSourceId parameters:parameters query:nil];
    
    //    for (NSDictionary *subd in dataAry) {
    //        DEBUGLog(@"->%@",subd[@"TRD_DT"]);
    //    }
    
    for (NSDictionary *items in dataAry) {
        
        //KVC赋值
        diagnoseModel = [[BDDiagnoseModel alloc]initWithDictionary:(NSMutableDictionary *)items];
        
        diagnoseModel.RAT_CODE = (items[@"RAT_CODE"]  == [NSNull null]) ? @"" : items[@"RAT_CODE"];
        diagnoseModel.END_DT = (items[@"END_DT"]  == [NSNull null]) ? @" " : items[@"END_DT"];
//        DEBUGLog(@"RAT_CODE->%@",diagnoseModel.RAT_CODE);
//        DEBUGLog(@"END_DT->%@",diagnoseModel.END_DT);
        
        [endArray addObject:diagnoseModel];
    }
    return endArray;
}

/*
 value	__NSCFString *	@"公司2014-12-31财报显示：
 \r业务收入88.88%来自于商品零售业收入，贡献收入356093.80万元，毛利率17.05%；
 \r业务收入11.10%来自于其他业务(补充)，贡献收入44465.30万元， 毛利率95.48%，同比增长18.71%。
 \r毛利率最高的是其他业务(补充)，达到95.48%，贡献收入44465.30万元。"
 */

@end
