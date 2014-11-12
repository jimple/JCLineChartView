//
//  JCLineData.h
//  JCLineChartViewDemo
//
//  Created by Jimple on 14-8-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EJCLinePointStyle)
{
    kEJCLinePointStyleNone = 0,     // 不画顶点
    kEJCLinePointStyleCycle         // 圆型顶点
};


typedef CGPoint (^JCLinePointValueGetter)(NSUInteger index);

@interface JCLineData : NSObject


@property (nonatomic, strong) UIColor *lineColor;                       // 线的颜色
@property (nonatomic, assign) CGFloat lineWidth;                        // 线的宽度
@property (nonatomic, assign) NSUInteger pointCount;                    // 线上点的总数（包括跳空的点）
@property (nonatomic, assign) EJCLinePointStyle pointStyle;             // 线顶点类型
@property (nonatomic, assign) CGFloat cyclePointWidth;                  // 顶点图形半径
@property (nonatomic, strong) UIColor *cyclePointFillColor;             // 顶点图像填充色
@property (nonatomic, assign) BOOL showWithAnimation;                   // 动画
@property (nonatomic, assign) CGFloat animationDuration;                // 动画持续时间
@property (nonatomic, assign) BOOL isCurved;                            // 是否插值成曲线

@property (nonatomic, copy) JCLinePointValueGetter getPointValue;       // 向外获取顶点数据

@end
