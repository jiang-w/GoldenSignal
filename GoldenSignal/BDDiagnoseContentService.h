//
//  BDDiagnoseContentService.h
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDDiagnoseModel.h"

@interface BDDiagnoseContentService : NSObject

///资金的
- (NSMutableArray *)getDiagnoseEachPageWithPageId:(int)pageSourceId andBD_CODE:(NSString *)bd_code andDays:(NSInteger)days;


/**
 *  获取 诊断板块 财务数据
 *  @param pageSourceId 不同页面对应的源id
 *  @param bd_code      链接的codeID
 *  @return 返回的数据 存入数组中
 */
- (NSMutableArray *)getDiagnoseEachPageWithPageId:(int)pageSourceId andBD_CODE:(NSString *)bd_code;



@end
