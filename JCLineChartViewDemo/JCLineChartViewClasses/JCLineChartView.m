//
//  JCLineChartView.m
//  JCLineChartViewDemo
//
//  Created by ThreegeneDev on 14-8-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "JCLineChartView.h"
#import "JCLineData.h"
#import "JCLinePointData.h"
#import "UIBezierPath+curved.h"


#define kLineColorDefault                   [UIColor blueColor]


@interface JCLineChartView ()

@property (nonatomic, assign) CGRect chartBound;
@property (nonatomic, strong) NSArray *lineDataArray;
@property (nonatomic, assign) CGFloat xMin;
@property (nonatomic, assign) CGFloat xMax;
@property (nonatomic, assign) CGFloat yMin;
@property (nonatomic, assign) CGFloat yMax;
@property (nonatomic) NSMutableArray *lineLayerArray;
@property (nonatomic) NSMutableArray *pointLayerArray;
@property (nonatomic) NSMutableArray *linePathArray;
@property (nonatomic) NSMutableArray *pointPathArray;

@end

@implementation JCLineChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)showLines:(NSArray *)lineDataArray withChartBound:(CGRect)chartBound
{
    _lineDataArray = [NSArray arrayWithArray:lineDataArray];
    _chartBound = chartBound;
    _xMin = chartBound.origin.x;
    _yMin = chartBound.origin.y;
    _xMax = chartBound.origin.x + chartBound.size.width;
    _yMax = chartBound.origin.y + chartBound.size.height;
    
    [self initalizeLineData:_lineDataArray];
    [self strokeChart];
}

- (void)initalizeLineData:(NSArray *)lineDataArray
{
    if (_lineLayerArray)
    {
        for (CALayer *layer in _lineLayerArray)
        {
            [layer removeFromSuperlayer];
        }
    }else{}
    if (_pointLayerArray)
    {
        for (CALayer *layer in _pointLayerArray)
        {
            [layer removeFromSuperlayer];
        }
    }else{}

    if (lineDataArray && (lineDataArray.count > 0))
    {
        _lineLayerArray = [NSMutableArray arrayWithCapacity:lineDataArray.count];
        _pointLayerArray = [NSMutableArray arrayWithCapacity:lineDataArray.count];
        
        for (JCLineData *lineData in lineDataArray)
        {
            // create as many chart line layers as there are data-lines
            CAShapeLayer *chartLine = [CAShapeLayer layer];
            chartLine.lineCap = kCALineCapButt;
            chartLine.lineJoin = kCALineJoinMiter;
            chartLine.fillColor = lineData.lineColor.CGColor;
            chartLine.lineWidth = lineData.lineWidth;
            chartLine.strokeEnd = 0.0;
            [self.layer addSublayer:chartLine];
            [_lineLayerArray addObject:chartLine];
            
            // create point
            CAShapeLayer *pointLayer = [CAShapeLayer layer];
            pointLayer.strokeColor   = lineData.lineColor.CGColor;
            pointLayer.lineCap       = kCALineCapRound;
            pointLayer.lineJoin      = kCALineJoinBevel;
            pointLayer.fillColor     = lineData.lineColor.CGColor;
            pointLayer.lineWidth     = lineData.lineWidth;
            [self.layer addSublayer:pointLayer];
            [_pointLayerArray addObject:pointLayer];
        }
    }
    else
    {
        _lineLayerArray = [[NSMutableArray alloc] init];
        _pointLayerArray = [[NSMutableArray alloc] init];
    }
    
    [self setNeedsDisplay];
}

- (void)strokeChart
{
    _linePathArray = [[NSMutableArray alloc] init];
    _pointPathArray = [[NSMutableArray alloc] init];
    
    for (NSUInteger lineIndex = 0; lineIndex < _lineDataArray.count; lineIndex++)
    {
        JCLineData *lineData = _lineDataArray[lineIndex];
        CAShapeLayer *lineLayer = (CAShapeLayer *)_lineLayerArray[lineIndex];
        CAShapeLayer *pointLayer = (CAShapeLayer *)_pointLayerArray[lineIndex];
        
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
        
        [_linePathArray addObject:progressline];
        [_pointPathArray addObject:pointPath];
        
        NSMutableArray *linePointsArray = [[NSMutableArray alloc] init];
        BOOL hasBreakPoint = NO;
        int iFirstPointIndex = 0;   // 线段第一个点的开始序号
        for (NSUInteger i = 0; i < lineData.pointCount; i++)
        {
            NSAssert(lineData.getPointValue, @" assert!");
            
            ptValue = lineData.getPointValue(i);
            
            innerScaleX = (ptValue.x - _xMin) / (_xMax - _xMin);
            innerScaleY = (ptValue.y - _yMin) / (_yMax - _yMin);
            
            int x = innerScaleX * _chartBound.size.width;
            int y = (1.0f - innerScaleY) *_chartBound.size.height;

            if (lineData.pointStyle == kEJCLinePointStyleCycle)
            {
                if (ptValue.y == CGFLOAT_MIN)
                {
                    iFirstPointIndex = i+1;
                    hasBreakPoint = YES;
                }
                else
                {
                    CGPoint circleCenter = CGPointMake(x, y);
                    [pointPath moveToPoint:CGPointMake(circleCenter.x + (lineData.cyclePointWidth / 2.0f), circleCenter.y)];
                    [pointPath addArcWithCenter:circleCenter radius:(lineData.cyclePointWidth / 2.0f) startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
                    
                    if (i != iFirstPointIndex)
                    {
                        [progressline addLineToPoint:CGPointMake(x, y)];
                    }else{}
                    [progressline moveToPoint:CGPointMake(x, y)];
                }
            }
            else
            {
                if (ptValue.y == CGFLOAT_MIN)
                {
                    iFirstPointIndex = i+1;
                    hasBreakPoint = YES;
                }
                else
                {
                    if (i != iFirstPointIndex)
                    {
                        [progressline addLineToPoint:CGPointMake(x, y)];
                    }else{}
                    
                    [progressline moveToPoint:CGPointMake(x, y)];
                }
            }
            
            [linePointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
        
        [_linePathArray addObject:[linePointsArray copy]];
        
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
        
        if (!hasBreakPoint  // 有孤立的点存在，则用这种方法暂时无法插值，需获得线段开始点位置，然后在插值时只对线段起止点间插值。
            && lineData.isCurved)
        {
            progressline = [progressline smoothedDoublePointPathWithGranularity:20];
        }
        
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
            
//            if (lineData.pointStyle != kEJCLinePointStyleNone)
//            {
//                [pointLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
//            }else{}
            
            [CATransaction setCompletionBlock:^{
                //pointLayer.strokeEnd = 1.0f;
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































@end
