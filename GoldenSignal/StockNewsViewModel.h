//
//  QuoteInformationViewModel.h
//  CBNAPP
//
//  Created by Frank on 14/12/17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockNewsViewModel : NSObject

/**
 *  证券编码（BD_CODE）
 */
@property(nonatomic, copy)NSString *secuCode;

/**
 *  每次请求的条数（默认10）
 */
@property(nonatomic,assign) int pageSize;

/**
 *  新闻事件列表
 */
@property(nonatomic, strong, readonly)NSMutableArray *newsList;

/**
 *  公告列表
 */
@property(nonatomic, strong, readonly)NSMutableArray *bulletinList;

/**
 *  研报列表
 */
@property(nonatomic, strong, readonly)NSMutableArray *reportList;


- (id)initWithCode:(NSString *)code;
- (void)loadNews;
- (void)loadBulletin;
- (void)loadReport;

@end
