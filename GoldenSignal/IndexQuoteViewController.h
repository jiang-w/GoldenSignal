//
//  QuoteIndexViewController.h
//  GoldenSignal
//
//  Created by CBD-miniMac on 6/15/15.
//  Copyright (c) 2015 bigdata. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IndexQuoteViewDelegate <NSObject>

-(void)didSelectIndexCode:(NSString *)code;

@end

@interface IndexQuoteViewController : UIViewController

@property(nonatomic, weak) id <IndexQuoteViewDelegate> delegate;

- (id)initWithIndexId:(long)IndexId;

//@property (nonatomic, assign) long indexIDD;

@end
