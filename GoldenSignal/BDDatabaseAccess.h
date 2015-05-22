//
//  BDDatabaseAccess.h
//  CBNAPP
//
//  Created by Frank on 14/12/2.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface BDDatabaseAccess : NSObject

/**
 *  初始化
 *
 *  @param path       新闻ID
 */
- (id)initWithPath:(NSString *)path;

/**
 *  删除数据库
 */
- (void)deleteDatabse;

/**
 *  数据库是否存在表
 *
 *  @param tableName  表名
 */
- (BOOL)tableExists:(NSString *)tableName;

/**
 *  获取表记录数
 *
 *  @param tableName  表名
 */
- (int)getRowNumberOfTable:(NSString *)tableName;

/**
 *  创建表
 *
 *  @param tableName  表名
 *  @param arguments  列名及类型
 */
- (BOOL)createTable:(NSString *)tableName withColumns:(NSString *)columns;

/**
 *  删除表
 *
 *  @param tableName  表名
 */
- (BOOL)deleteTable:(NSString *)tableName;

/**
 *  清空表数据
 *
 *  @param tableName  表名
 */
- (BOOL)eraseTable:(NSString *)tableName;

/**
 *  执行插入语句
 *
 *  @param sql
 */
- (BOOL)insertTable:(NSString*)sql, ...;

/**
 *  执行更新语句
 *
 *  @param sql
 */
- (BOOL)updateTable:(NSString*)sql, ...;

/**
 *  执行查询语句
 *
 *  @param sql
 */
- (FMResultSet *)queryTable:(NSString*)sql, ...;

@end
