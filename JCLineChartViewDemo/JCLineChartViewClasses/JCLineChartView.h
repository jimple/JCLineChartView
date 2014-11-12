//
//  JCLineChartView.h
//  JCLineChartViewDemo
//
//  Created by Jimple on 14-8-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCLineData;
@interface JCLineChartView : UIView

// 清空画布
- (void)clearChart;

// 画线
- (void)showLines:(NSArray *)lineDataArray withChartBound:(CGRect)chartBound;

// 对闭合线内部区域填充颜色
// 仅填充颜色
- (void)cycleLine:(JCLineData *)lineData
       fillColors:(NSArray *)fillColors
          inBound:(CGRect)chartBound;
// 填充颜色，且画边缘线
- (void)cycleLine:(JCLineData *)lineData
       fillColors:(NSArray *)fillColors
          inBound:(CGRect)chartBound
   drawBorderLine:(BOOL)drawBorder;

// 在两条线间填充颜色
- (void)fillColors:(NSArray *)fillColors
           inBound:(CGRect)chartBound
       betweenLine:(JCLineData *)firstLineData
           andLine:(JCLineData *)secondLineData;



@end
