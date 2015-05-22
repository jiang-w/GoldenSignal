//
//  SectCollectionViewModel.m
//  GoldenSignal
//
//  Created by Frank on 15/2/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "SectCollectionViewModel.h"
#import "BDSectService.h"

@implementation SectCollectionViewModel
{
    NSMutableDictionary *_dataDic;
    NSMutableArray *_keys;
}

- (id)init {
    self = [super init];
    if (self) {
        _dataDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _keys = [NSMutableArray arrayWithCapacity:0];
        [self loadSectData];
    }
    return self;
}

- (void)loadSectData {
    BDSectService *service = [[BDSectService alloc] init];
    NSMutableArray *sectInfoArray = [NSMutableArray arrayWithArray:[service getSectInfoByTypeCode:nil]];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"typCode" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES];
    [sectInfoArray sortUsingDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];

    for (BDSectInfo *sect in sectInfoArray) {
        NSMutableArray *sectArray;
        if ([self isContainKey:sect.typName]) {
            NSMutableArray *sectArray = [_dataDic objectForKey:sect.typName];
            [sectArray addObject:sect];
        }
        else {
            sectArray = [NSMutableArray arrayWithCapacity:0];
            [sectArray addObject:sect];
            [_dataDic setObject:sectArray forKey:sect.typName];
            [_keys addObject:sect.typName];
        }
    }
}

- (BOOL)isContainKey:(NSString *)key {
    for (NSString *item in _keys) {
        if ([item isEqualToString:key]) {
            return YES;
        }
    }
    return NO;
}

- (BDSectInfo *)getSectInfoAtIndexPath:(NSIndexPath *)indexPath {
    BDSectInfo *info = nil;
    if (indexPath.section < _keys.count) {
        NSMutableArray *sectArray = [_dataDic objectForKey:_keys[indexPath.section]];
        if (sectArray != nil && indexPath.row < sectArray.count) {
            info = [sectArray objectAtIndex:indexPath.row];
        }
    }
    return info;
}

- (NSString *)getTitleForSection:(NSInteger)section {
    if (section < _keys.count) {
        return _keys[section];
    }
    else {
        return nil;
    }
}

- (NSInteger)getNumberOfSections {
    return _keys.count;
}

- (NSInteger)getNumberOfItemsInSection:(NSInteger)section {
    NSInteger number = 0;
    if (section < _keys.count) {
         NSMutableArray *sectArray = [_dataDic objectForKey:_keys[section]];
        if (sectArray) {
            number = sectArray.count;
        }
    }
    return number;
}

@end
