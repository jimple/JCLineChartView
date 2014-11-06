//
//  JCLineData.h
//  JCLineChartViewDemo
//
//  Created by ThreegeneDev on 14-8-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EJCLinePointStyle)
{
    kEJCLinePointStyleNone = 0,
    kEJCLinePointStyleCycle
};


typedef CGPoint (^JCLinePointValueGetter)(NSUInteger index);

@interface JCLineData : NSObject


@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) NSUInteger pointCount;
@property (nonatomic, assign) EJCLinePointStyle pointStyle;
@property (nonatomic, assign) CGFloat cyclePointWidth;
@property (nonatomic, assign) BOOL showWithAnimation;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL isCurved;

@property (nonatomic, copy) JCLinePointValueGetter getPointValue;

@end
