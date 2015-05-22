//
//  RelationQuery.h
//  UQuery
//
//  Created by Frank on 14-7-17.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDQuery.h"

typedef enum {
    andRelation,
    orRelation
} RelationType;

@interface BDRelationQuery : BDQuery

@property (readonly) RelationType relation;
@property (readonly) NSMutableSet *queries;

- (instancetype)initWithRelation:(RelationType)relation andQuerise:(BDQuery *)query, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithRelation:(RelationType)relation andQueryArray:(NSArray *)querise;

@end
