//
//  BDDiagnoseModel.h
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDDiagnoseModel : NSObject

//财务图形Model
@property (nonatomic, copy) NSString *NET_PROF_PCO;//净利润（换算成万元）
@property (nonatomic, copy) NSString *END_DT;//日期 年
@property (nonatomic, copy) NSString *NET_PROF_PCO_YOY;//unUse 归属上市公司股东的净利润同比增长（%）
//财务解读Model
@property (nonatomic, copy) NSString *DES;//描述的文本内容
@property (nonatomic, copy) NSString *SECU_SHT;     //2+3
@property (nonatomic, copy) NSString *TRD_CODE;     //2+3
@property (nonatomic, assign) NSNumber *SECU_ID;    //2+3

//财务主营饼图Model
@property (nonatomic, copy) NSString *OPER_INC;//营业收入(2位小数，万元)
@property (nonatomic, copy) NSString *END_DT3;
@property (nonatomic, copy) NSString *BD_CODE;
@property (nonatomic, copy) NSString *GPM;//毛利率
@property (nonatomic, copy) NSString *BIZ_NAME_NORM;

//主营的构成解读
@property (nonatomic, copy) NSString *DEC;

//认同图表
@property (nonatomic, copy) NSString *TRD_DT;//日期
@property (nonatomic, copy) NSString *RAT_CODE;//评级数
@property (nonatomic, copy) NSString *CLS_PRC;//价格


- (instancetype)initWithDictionary:(NSMutableDictionary *)jsonObject;


@end
