//
//  SectCollectionViewModel.h
//  GoldenSignal
//
//  Created by Frank on 15/2/4.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectCollectionViewModel : NSObject

- (BDSectInfo *)getSectInfoAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)getTitleForSection:(NSInteger)section;

- (NSInteger)getNumberOfSections;

- (NSInteger)getNumberOfItemsInSection:(NSInteger)section;

@end
