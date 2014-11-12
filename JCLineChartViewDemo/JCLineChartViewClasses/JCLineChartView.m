//
//  JCLineChartView.m
//  JCLineChartViewDemo
//
//  Created by Jimple on 14-8-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "JCLineChartView.h"
#import "JCLineData.h"
#import "JCLinePointData.h"
#import "UIBezierPath+curved.h"

#define kLineColorDefault                   [UIColor blueColor]
#define kLineWidthDefault                   1.0f


@interface JCLineChartView ()

@property (nonatomic, strong) NSMutableDictionary *lineData2LayerArrayDic;

@end

@implementation JCLineChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self commonInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)commonInit
{
    _lineData2LayerArrayDic = [[NSMutableDictionary alloc] init];
}

// 清空画布
- (void)clearChart
{
    for (NSString *indexStr in _lineData2LayerArrayDic.allKeys)
    {
        NSArray *layerArray = _lineData2LayerArrayDic[indexStr];
        for (CALayer *layer in layerArray)
        {
            [layer removeFromSuperlayer];
        }
    }
    [_lineData2LayerArrayDic removeAllObjects];
}

// 画线
- (void)showLines:(NSArray *)lineDataArray withChartBound:(CGRect)chartBound
{
    if (lineDataArray && (lineDataArray.count > 0))
    {
        if (!_lineData2LayerArrayDic)
        {
            _lineData2LayerArrayDic = [[NSMutableDictionary alloc] init];
        }else{}
        
        NSMutableArray *lineLayerArray = [NSMutableArray arrayWithCapacity:lineDataArray.count];
        NSMutableArray *pointLayerArray = [NSMutableArray arrayWithCapacity:lineDataArray.count];
        for (JCLineData *lineData in lineDataArray)
        {
            // create as many chart line layers as there are data-lines
            CAShapeLayer *chartLineLayer = [self lineLayerWithLineData:lineData];
            [self.layer addSublayer:chartLineLayer];
            [lineLayerArray addObject:chartLineLayer];
            
            // create point
            CAShapeLayer *pointLayer = [self pointLayerWithLineData:lineData];
            [self.layer addSublayer:pointLayer];
            [pointLayerArray addObject:pointLayer];
            
            NSString *indexStr = @(_lineData2LayerArrayDic.allKeys.count).stringValue;
            _lineData2LayerArrayDic[indexStr] = @[chartLineLayer, pointLayer];
        }
        
        [self setNeedsDisplay];
        
        [self strokeChartWithLineDataArray:lineDataArray
                            lineLayerArray:lineLayerArray
                           pointLayerArray:pointLayerArray
                                chartBound:chartBound];
    }else{}
}

// 对闭合线内部区域填充颜色
// 仅填充颜色
- (void)cycleLine:(JCLineData *)lineData
       fillColors:(NSArray *)fillColors
          inBound:(CGRect)chartBound
{
    [self cycleLine:lineData fillColors:fillColors inBound:chartBound drawBorderLine:NO];
}
// 填充颜色，且画边缘线
- (void)cycleLine:(JCLineData *)lineData
       fillColors:(NSArray *)fillColors
          inBound:(CGRect)chartBound
   drawBorderLine:(BOOL)drawBorder
{
    if (fillColors && (fillColors.count > 0) && lineData)
    {
        if (!_lineData2LayerArrayDic)
        {
            _lineData2LayerArrayDic = [[NSMutableDictionary alloc] init];
        }else{}
        NSMutableArray *layerArray = [[NSMutableArray alloc] init];
        
        // 填充颜色层
        NSMutableArray *colors=[[NSMutableArray alloc] initWithCapacity:fillColors.count];
        for (UIColor* color in fillColors)
        {
            if ([color isKindOfClass:[UIColor class]])
            {
                [colors addObject:(id)[color CGColor]];
            }
            else
            {
                [colors addObject:(id)color];
            }
        }
        
        CAGradientLayer * gradientLayer;
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = chartBound;
        gradientLayer.colors = colors;
        [self.layer addSublayer:gradientLayer];
        [layerArray addObject:gradientLayer];
        
        if (drawBorder)
        {
            // create as many chart line layers as there are data-lines
            CAShapeLayer *chartLineLayer = [self lineLayerWithLineData:lineData];
            [self.layer addSublayer:chartLineLayer];
            
            // create point
            CAShapeLayer *pointLayer = [self pointLayerWithLineData:lineData];
            [self.layer addSublayer:pointLayer];
            
            [layerArray addObject:chartLineLayer];
            [layerArray addObject:pointLayer];
            
            [self strokeChartWithLineDataArray:@[lineData]
                                lineLayerArray:@[chartLineLayer]
                               pointLayerArray:@[pointLayer]
                            gradientLayerArray:@[gradientLayer]
                                    chartBound:chartBound];
        }
        else
        {
            [self strokeChartForFillColorWithCycleLineData:lineData
                                             gradientLayer:gradientLayer
                                                chartBound:chartBound];
        }
        
        NSString *indexStr = @(_lineData2LayerArrayDic.allKeys.count).stringValue;
        _lineData2LayerArrayDic[indexStr] = layerArray;

        [self setNeedsDisplay];
    }else{}
}

#pragma mark -
- (void)strokeChartWithLineDataArray:(NSArray *)lineDataArray
                      lineLayerArray:(NSArray *)lineLayerArray
                     pointLayerArray:(NSArray *)pointLayerArray
                          chartBound:(CGRect)chartBound
{
    [self strokeChartWithLineDataArray:lineDataArray
                        lineLayerArray:lineLayerArray
                       pointLayerArray:pointLayerArray
                    gradientLayerArray:nil
                            chartBound:chartBound];
}
- (void)strokeChartWithLineDataArray:(NSArray *)lineDataArray
                      lineLayerArray:(NSArray *)lineLayerArray
                     pointLayerArray:(NSArray *)pointLayerArray
                  gradientLayerArray:(NSArray *)gradientLayerArray
                          chartBound:(CGRect)chartBound
{
    NSAssert(lineDataArray && lineLayerArray && pointLayerArray
             && (lineDataArray.count == lineLayerArray.count)
             && (lineDataArray.count == pointLayerArray.count),
             @" Assert!");
    
    CGFloat xMin = chartBound.origin.x;
    CGFloat yMin = chartBound.origin.y;
    CGFloat xMax = chartBound.origin.x + chartBound.size.width;
    CGFloat yMax = chartBound.origin.y + chartBound.size.height;
    
    for (NSUInteger lineIndex = 0; lineIndex < lineDataArray.count; lineIndex++)
    {
        JCLineData *lineData = lineDataArray[lineIndex];
        CAShapeLayer *lineLayer = (CAShapeLayer *)lineLayerArray[lineIndex];
        CAShapeLayer *pointLayer = (CAShapeLayer *)pointLayerArray[lineIndex];
        
        // 颜色填充层
        CAGradientLayer *gradientLayer;
        if (gradientLayerArray && (gradientLayerArray.count > lineIndex))
        {
            id layer = gradientLayerArray[lineIndex];
            if ([layer isKindOfClass:CAGradientLayer.class])
            {
                gradientLayer = (CAGradientLayer *)gradientLayerArray[lineIndex];
            }else{}
        }else{}
        
        CGPoint ptValue;
        CGFloat innerScaleX;
        CGFloat innerScaleY;
        
        UIGraphicsBeginImageContext(self.frame.size);
        
        UIBezierPath *progressline = [UIBezierPath bezierPath];
        [progressline setLineWidth:lineData.lineWidth];
        [progressline setLineCapStyle:kCGLineCapRound];
        [progressline setLineJoinStyle:kCGLineJoinRound];
        
        UIBezierPath *pointPath = [UIBezierPath bezierPath];
        [pointPath setLineWidth:lineData.lineWidth];
        
        UIBezierPath *fillPath = [UIBezierPath bezierPath];
        
        
        NSMutableArray *breakPointStateArray = [[NSMutableArray alloc] init];
        BOOL hasBreakPoint = NO;
        NSUInteger iFirstPointIndex = 0;   // 线段第一个点的开始序号
        for (NSUInteger i = 0; i < lineData.pointCount; i++)
        {
            NSAssert(lineData.getPointValue, @" assert!");
            ptValue = lineData.getPointValue(i);
            
            innerScaleX = (ptValue.x - xMin) / (xMax - xMin);
            innerScaleY = (ptValue.y - yMin) / (yMax - yMin);
            
            int x = innerScaleX * chartBound.size.width;
            int y = (1.0f - innerScaleY) *chartBound.size.height;
            
            
            if (ptValue.y == CGFLOAT_MIN)
            {
                iFirstPointIndex = i+1;
                hasBreakPoint = YES;
            }
            else
            {
                // 颜色填充层
                if (gradientLayer)
                {
                    if (i == iFirstPointIndex)
                    {
                        [fillPath moveToPoint:CGPointMake(x, y)];
                    }
                    else
                    {
                        
                        [fillPath addLineToPoint:CGPointMake(x, y)];
                    }
                }else{}

                // 线与顶点
                if (lineData.pointStyle == kEJCLinePointStyleCycle)
                {

                    CGPoint circleCenter = CGPointMake(x, y);
                    [pointPath moveToPoint:CGPointMake(circleCenter.x + (lineData.cyclePointWidth / 2.0f), circleCenter.y)];
                    [pointPath addArcWithCenter:circleCenter radius:(lineData.cyclePointWidth / 2.0f) startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
                    
                    if (i == iFirstPointIndex)
                    {
                        [progressline moveToPoint:CGPointMake(x, y)];
                        [breakPointStateArray addObject:@(YES)];
                    }
                    else
                    {
                        [progressline addLineToPoint:CGPointMake(x, y)];
                        [breakPointStateArray addObject:@(NO)];
                    }
                }
                else
                {

                    if (i == iFirstPointIndex)
                    {
                        [progressline moveToPoint:CGPointMake(x, y)];
                        [breakPointStateArray addObject:@(YES)];
                    }
                    else
                    {
                        
                        [progressline addLineToPoint:CGPointMake(x, y)];
                        [breakPointStateArray addObject:@(NO)];
                    }
                }
            }
        }
        
        if (lineData.lineColor)
        {
            lineLayer.strokeColor = [lineData.lineColor CGColor];
            pointLayer.strokeColor = [lineData.lineColor CGColor];
        }
        else
        {
            lineLayer.strokeColor = [kLineColorDefault CGColor];
            pointLayer.strokeColor = [kLineColorDefault CGColor];
        }
        
        [progressline stroke];
        
        if (lineData.isCurved)
        {
            progressline = [progressline smoothedPathWithGranularity:20 breakPointStateArray:breakPointStateArray];
            
            if (gradientLayer)
            {
                fillPath = [fillPath smoothedPathWithGranularity:20];
            }else{}
        }else{/* assert */}
        
        // 颜色填充层
        if (gradientLayer)
        {
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = chartBound;
            maskLayer.path = fillPath.CGPath;
            gradientLayer.mask = maskLayer;
        }else{}
        
        lineLayer.path = progressline.CGPath;
        pointLayer.path = pointPath.CGPath;
        if (lineData.showWithAnimation)
        {
            [CATransaction begin];
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = (lineData.animationDuration > 0.2f) ? lineData.animationDuration : 0.2f;
            pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pathAnimation.fromValue = @0.0f;
            pathAnimation.toValue   = @1.0f;
            
            [lineLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
            lineLayer.strokeEnd = 1.0;
            
            [CATransaction setCompletionBlock:^{
            }];
            [CATransaction commit];
        }
        else
        {
            lineLayer.strokeEnd = 1.0;
        }
        
        UIGraphicsEndImageContext();
    }
}

// 仅画填充层，不画边缘曲线
- (void)strokeChartForFillColorWithCycleLineData:(JCLineData *)lineData
                                   gradientLayer:(CAGradientLayer *)gradientLayer
                                      chartBound:(CGRect)chartBound
{
    NSAssert(lineData && gradientLayer, @" Assert! ");
    
    CGFloat xMin = chartBound.origin.x;
    CGFloat yMin = chartBound.origin.y;
    CGFloat xMax = chartBound.origin.x + chartBound.size.width;
    CGFloat yMax = chartBound.origin.y + chartBound.size.height;

    CGPoint ptValue;
    CGFloat innerScaleX;
    CGFloat innerScaleY;
    
    UIGraphicsBeginImageContext(self.frame.size);
    
    NSUInteger iFirstPointIndex = 0;   // 线段第一个点的开始序号
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    for (NSUInteger i = 0; i < lineData.pointCount; i++)
    {
        NSAssert(lineData.getPointValue, @" assert!");
        ptValue = lineData.getPointValue(i);
        
        innerScaleX = (ptValue.x - xMin) / (xMax - xMin);
        innerScaleY = (ptValue.y - yMin) / (yMax - yMin);
        
        int x = innerScaleX * chartBound.size.width;
        int y = (1.0f - innerScaleY) *chartBound.size.height;

        if (ptValue.y == CGFLOAT_MIN)
        {
            iFirstPointIndex = i+1;
        }
        else
        {
            if (i == iFirstPointIndex)
            {
                [fillPath moveToPoint:CGPointMake(x, y)];
            }
            else
            {
                
                [fillPath addLineToPoint:CGPointMake(x, y)];
            }
        }
    }
    
    if (lineData.isCurved)
    {
        fillPath = [fillPath smoothedPathWithGranularity:20];
    }else{/* assert */}

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = chartBound;
    maskLayer.path = fillPath.CGPath;
    gradientLayer.mask = maskLayer;
    
    UIGraphicsEndImageContext();
}

// 在两条线间填充颜色
- (void)fillColors:(NSArray *)fillColors
           inBound:(CGRect)chartBound
       betweenLine:(JCLineData *)firstLineData
           andLine:(JCLineData *)secondLineData
{
    NSAssert(fillColors && firstLineData && secondLineData, @" Assert! ");
    
    if (fillColors && (fillColors.count > 0) && firstLineData && secondLineData)
    {
        if (!_lineData2LayerArrayDic)
        {
            _lineData2LayerArrayDic = [[NSMutableDictionary alloc] init];
        }else{}
        NSMutableArray *layerArray = [[NSMutableArray alloc] init];
        
        // 填充颜色层
        NSMutableArray *colors=[[NSMutableArray alloc] initWithCapacity:fillColors.count];
        for (UIColor* color in fillColors)
        {
            if ([color isKindOfClass:[UIColor class]])
            {
                [colors addObject:(id)[color CGColor]];
            }
            else
            {
                [colors addObject:(id)color];
            }
        }
        
        CAGradientLayer * gradientLayer;
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = chartBound;
        gradientLayer.colors = colors;
        [self.layer addSublayer:gradientLayer];
        [layerArray addObject:gradientLayer];
        
        UIGraphicsBeginImageContext(self.frame.size);
        
        UIBezierPath *firstLinePath = [self pathFromLine:firstLineData inBound:chartBound];
        UIBezierPath *secondLinePath = [self pathFromLine:secondLineData inBound:chartBound];
        
        UIBezierPath *fillPath = [[UIBezierPath alloc] init];
        [fillPath appendPath:firstLinePath];
        NSArray *secondPathPointsArray = [[secondLinePath bezierPathByReversingPath] pointsInBezierPath];
        for (int i = 0; i < secondPathPointsArray.count; i++)
        {
            CGPoint pt = [(NSValue *)[secondPathPointsArray objectAtIndex:i] CGPointValue];
            [fillPath addLineToPoint:pt];
        }
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = chartBound;
        maskLayer.path = fillPath.CGPath;
        gradientLayer.mask = maskLayer;
        
        UIGraphicsEndImageContext();
        
        NSString *indexStr = @(_lineData2LayerArrayDic.allKeys.count).stringValue;
        _lineData2LayerArrayDic[indexStr] = layerArray;
        
        [self setNeedsDisplay];
    }else{}
}

#pragma mark -

- (CAShapeLayer *)lineLayerWithLineData:(JCLineData *)lineData
{
    CAShapeLayer *chartLineLayer = [CAShapeLayer layer];
    chartLineLayer.lineCap = kCALineCapButt;
    chartLineLayer.lineJoin = kCALineJoinMiter;
    chartLineLayer.fillColor = ((lineData && lineData.lineColor) ? lineData.lineColor.CGColor : kLineColorDefault.CGColor);
    chartLineLayer.lineWidth = (lineData ? lineData.lineWidth : kLineWidthDefault);
    chartLineLayer.strokeEnd = 0.0;
    
    chartLineLayer.fillColor = [UIColor clearColor].CGColor;
    
    return chartLineLayer;
}

- (CAShapeLayer *)pointLayerWithLineData:(JCLineData *)lineData
{
    CAShapeLayer *pointLayer = [CAShapeLayer layer];
    pointLayer.strokeColor   = ((lineData && lineData.lineColor) ? lineData.lineColor.CGColor : kLineColorDefault.CGColor);
    pointLayer.lineCap       = kCALineCapRound;
    pointLayer.lineJoin      = kCALineJoinBevel;
    pointLayer.fillColor     = ((lineData && lineData.cyclePointFillColor) ? lineData.cyclePointFillColor.CGColor : pointLayer.strokeColor);
    pointLayer.lineWidth     = (lineData ? lineData.lineWidth : kLineWidthDefault);
    
    return pointLayer;
}

- (UIBezierPath *)pathFromLine:(JCLineData *)lineData inBound:(CGRect)chartBound
{
    NSAssert(lineData, @" Assert! ");
    
    CGFloat xMin = chartBound.origin.x;
    CGFloat yMin = chartBound.origin.y;
    CGFloat xMax = chartBound.origin.x + chartBound.size.width;
    CGFloat yMax = chartBound.origin.y + chartBound.size.height;
    
    CGPoint ptValue;
    CGFloat innerScaleX;
    CGFloat innerScaleY;
    
    NSUInteger iFirstPointIndex = 0;   // 线段第一个点的开始序号
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    for (NSUInteger i = 0; i < lineData.pointCount; i++)
    {
        NSAssert(lineData.getPointValue, @" assert!");
        ptValue = lineData.getPointValue(i);
        
        innerScaleX = (ptValue.x - xMin) / (xMax - xMin);
        innerScaleY = (ptValue.y - yMin) / (yMax - yMin);
        
        int x = innerScaleX * chartBound.size.width;
        int y = (1.0f - innerScaleY) *chartBound.size.height;

        if (ptValue.y == CGFLOAT_MIN)
        {
            iFirstPointIndex = i+1;
        }
        else
        {
            if (i == iFirstPointIndex)
            {
                [fillPath moveToPoint:CGPointMake(x, y)];
            }
            else
            {
                
                [fillPath addLineToPoint:CGPointMake(x, y)];
            }
        }
    }
    
    if (lineData.isCurved)
    {
        fillPath = [fillPath smoothedPathWithGranularity:20];
    }else{/* assert */}
    
    return fillPath;
}




















































@end
