//
//  BDNewStockModel.h
//  GoldenSignal
//
//  Created by CBD on 7/8/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNewStockModel : NSObject

//1+2为 cell列表 和 详情页面 都要用到
#pragma mark  //Cell列表 从数据源1590里面获取 对应的SQL 1
@property (nonatomic, copy  ) NSString *TRD_CODE;           //股票代码ID  1+2
@property (nonatomic, copy  ) NSString *SECU_SHT;           //股票名称    1+2

@property (nonatomic, strong) NSDate *  SUB_BGN_DT_ON1;      //申购日         1+2
@property (nonatomic, strong) NSDate *  ALOT_RSLT_NTC_DT1;   //中签结果公告日  1+2
@property (nonatomic, copy  ) NSString *ISS_PRC;            //发行价         1+2
@property (nonatomic, copy  ) NSString *PE_DIL;             //全面摊薄市盈率  1+2
@property (nonatomic, copy  ) NSString *SUB_SHR_ON;         //申购上限 (万股) 1+2
@property (nonatomic, copy  ) NSString *ISS_SHR;            //发行总数量(万股) 1+2
@property (nonatomic, assign) long      SECU_ID;            //cell与详情页面连接的ID 1+2

//TRD_CODE  SECU_SHT

#pragma mark  //详情页面数据源1591 SQL 2
@property (nonatomic, copy  ) NSString *SUB_BGN_DT_ON;      //申购日         1+2
@property (nonatomic, copy  ) NSString *ALOT_RSLT_NTC_DT;   //中签结果公告日  1+2

@property (nonatomic, copy  ) NSString *SUB_CODE;           //申购代码
@property (nonatomic, copy  ) NSString *LST_DT;             //上市日
@property (nonatomic, copy  ) NSString *SUCC_RAT_ON;        //网上发行中签率
@property (nonatomic, copy  ) NSString *ISS_ALOT_NO;        //中签号
//

- (instancetype)initWithDictionary:(NSMutableDictionary *)jsonObject;


@end
