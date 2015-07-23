//
//  AutoLayoutNewsListCell.m
//  GoldenSignal
//
//  Created by Frank on 15/5/15.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "AutoLayoutNewsEventListCell.h"
#import "Masonry.h"

@implementation AutoLayoutNewsEventListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadSubViews {
    container = self.contentView;
    
    title = [UILabel new];
    title.font = [UIFont boldSystemFontOfSize:14];
    [container addSubview:title];
    
    date = [UILabel new];
    date.font = [UIFont systemFontOfSize:10];
    date.textColor = RGB(43, 176, 241, 1);
    [container addSubview:date];
    
    detail = [UILabel new];
    detail.font = [UIFont systemFontOfSize:12];
    detail.numberOfLines = 2;
    [container addSubview:detail];
    
    tagContainer = [UIView new];
    [container addSubview:tagContainer];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 16, 10, 10);
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(container).with.offset(padding.top);
        make.left.equalTo(container).with.offset(padding.left);
        make.right.equalTo(container).with.offset(-padding.right);
    }];
    [date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).with.offset(6);
        make.left.equalTo(container).with.offset(padding.left);
    }];
    [detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(date.mas_bottom).with.offset(10);
        make.left.equalTo(container).with.offset(padding.left);
        make.right.equalTo(container).with.offset(-padding.right);
        make.bottom.lessThanOrEqualTo(container).with.offset(-padding.bottom);
    }];
    [tagContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detail.mas_bottom).with.offset(10);
        make.left.equalTo(container).with.offset(padding.left);
        make.right.equalTo(container).with.offset(-padding.right);
        make.bottom.equalTo(container).with.offset(-padding.bottom);
    }];
}

- (NSString *)getTagLabelText:(BDNewsEventList *)news forEventEffect:(EventEffect)effect {
    NSString *text = @"";
    NSArray *labels = [news getLabelsWithEventEffect:effect];
    if (labels.count > 0) {
        for (BDNewsTag *label in labels) {
            if ([text isNullOrEmpty]) {
                text = label.name;
            }
            else {
                if (effect == 5) {
                    text = [NSString stringWithFormat:@"%@ | %@", text, label.name];
                }
                else {
                    text = [NSString stringWithFormat:@"%@,%@", text, label.name];
                }
            }
        }
    }
    return text;
}

- (void)setNewsEvent:(BDNewsEventList *)news
{
    _newsEvent = news;
    title.text = news.title;
    date.text= [news.date toString:@"yyyy-MM-dd hh:mm"];
    detail.text = news.abstract;
    for (UIView *sub in tagContainer.subviews) {
        [sub removeFromSuperview];
    }

    UIView *lastTagView = nil;
    for (int i = 0; i < 6; i++) {
        NSString *labelText = [self getTagLabelText:news forEventEffect:i];
        if (![labelText isNullOrEmpty]) {
            UIImageView *symbol = [UIImageView new];
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:11];
            label.text = labelText;
            switch (i) {
                case PositivePlus:
                    symbol.image = [UIImage imageNamed:@"positivePlus"];
                    label.textColor = RGB(165, 0, 0, 1);
                    break;
                case Positive:
                    symbol.image = [UIImage imageNamed:@"positive"];
                    label.textColor = RGB(165, 0, 0, 1);
                    break;
                case Neutral:
                    symbol.image = [UIImage imageNamed:@"neutral"];
                    label.textColor = RGB(14, 93, 164, 1);
                    break;
                case Negative:
                    symbol.image = [UIImage imageNamed:@"negative"];
                    label.textColor = RGB(33, 142, 0, 1);
                    break;
                case NegativeMinus:
                    symbol.image = [UIImage imageNamed:@"negativeMinus"];
                    label.textColor = RGB(33, 142, 0, 1);
                    break;
                default:
                    label.textColor = RGB(33, 134, 225, 1);
                    break;
            }
            if (i == None) {
                [tagContainer addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (lastTagView) {
                        make.top.equalTo(lastTagView.mas_bottom).with.offset(10);
                    }
                    else {
                        make.top.equalTo(tagContainer);
                    }
                    make.left.equalTo(tagContainer);
                    make.bottom.lessThanOrEqualTo(tagContainer);
                    make.right.equalTo(tagContainer);
                }];
                lastTagView = label;
            }
            else {
                [tagContainer addSubview:symbol];
                [tagContainer addSubview:label];
                [symbol mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (lastTagView) {
                        make.top.equalTo(lastTagView.mas_bottom).with.offset(10);
                    }
                    else {
                        make.top.equalTo(tagContainer);
                    }
                    make.left.equalTo(tagContainer);
                    make.bottom.lessThanOrEqualTo(tagContainer);
                    make.width.mas_equalTo(34);
                }];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(symbol);
                    make.left.equalTo(symbol.mas_right).with.offset(10);
                    make.bottom.lessThanOrEqualTo(tagContainer);
                    make.right.equalTo(tagContainer);
                }];
                lastTagView = symbol;
            }
        }
    }
}

@end
