//
//  UIBezierPath+curved.m
//  MPPlot
//
//  Created by Alex Manzella on 22/05/14.
//  Copyright (c) 2014 mpow. All rights reserved.
//

#import "UIBezierPath+curved.h"

// Based on code from Erica Sadun

void getPointsFromBezier(void *info, const CGPathElement *element);
NSArray *pointsFromBezierPath(UIBezierPath *bpath);


#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

@implementation UIBezierPath (curved)


// Get points from Bezier Curve
void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

- (NSArray *)pointsInBezierPath
{
    return pointsFromBezierPath(self);
}

//- (UIBezierPath*)smoothedDoublePointPathWithGranularity:(NSInteger)granularity
//{
//    NSMutableArray *points = [pointsFromBezierPath(self) mutableCopy];
//    
//    if (points.count < 5) return [self copy];
//    
//    // Add control points to make the math make sense
//    [points insertObject:[points objectAtIndex:0] atIndex:0];
//    [points addObject:[points lastObject]];
//
//    UIBezierPath *smoothedPath = [self copy];
//    [smoothedPath removeAllPoints];
//    
//    [smoothedPath moveToPoint:POINT(0)];
//    for (NSUInteger index = 1; index < points.count - 2; index++)
//    {
//        CGPoint srcP0 = POINT(index - 1);
//        CGPoint srcP1 = POINT(index);
//        CGPoint srcP2 = POINT(index + 1);
//        CGPoint srcP3 = POINT(index + 2);
//        
//        if ([self samePointFrom:srcP1 to:srcP2])
//        {
//            [smoothedPath moveToPoint:srcP2];
//        }
//        else
//        {
//            if ([self samePointFrom:srcP2 to:srcP3]
//                || [self samePointFrom:srcP1 to:srcP0])
//            {
//                // insert
//                CGPoint p0 = POINT(index - 1);
//                CGPoint p1 = POINT(index);
//                CGPoint p2 = POINT(index + 1);
//                CGPoint p3 = POINT(index + 2);
//                
//                if ([self samePointFrom:srcP0 to:srcP1])
//                {
//                    if (index >= 2)
//                    {
//                        p0 = POINT(index - 2);
//                    }
//                    else
//                    {
//                        p0 = POINT(index - 1);
//                    }
//                }
//                else
//                {
//                    p0 = POINT(index - 1);
//                }
//                
//                p1 = POINT(index);
//                p2 = POINT(index + 1);
//                
//                if ([self samePointFrom:srcP2 to:srcP3])
//                {
//                    if ((index + 3) < points.count)
//                    {
//                        p3 = POINT(index + 3);
//                    }
//                    else
//                    {
//                        p3 = POINT(index + 2);
//                    }
//                }
//                else
//                {
//                    p3 = POINT(index + 2);
//                }
//                
//                
//                // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
//                for (int i = 1; i < granularity; i++)
//                {
//                    float t = (float) i * (1.0f / (float) granularity);
//                    float tt = t * t;
//                    float ttt = tt * t;
//                    
//                    CGPoint pi; // intermediate point
//                    pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
//                    pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
//                    
//                    [smoothedPath addLineToPoint:pi];
//                    [smoothedPath moveToPoint:pi];
//                }
//                
//                // Now add p2
//                [smoothedPath addLineToPoint:p2];
//                [smoothedPath moveToPoint:p2];
//            }
//            else
//            {
//                [smoothedPath moveToPoint:srcP2];
//            }
//        }
//    }
//    
//    // finish by adding the last point
//    [smoothedPath addLineToPoint:POINT(points.count - 1)];
//    [smoothedPath moveToPoint:POINT(points.count - 1)];
//    
//    return smoothedPath;
//}

- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity
{
    return [self smoothedPathWithGranularity:granularity breakPointStateArray:nil];
}
- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity breakPointStateArray:(NSArray *)breakPointStateArray
{
    NSMutableArray *points = [pointsFromBezierPath(self) mutableCopy];
    NSAssert((!breakPointStateArray) || (breakPointStateArray.count == 0) || (points.count == breakPointStateArray.count), @" Assert! ");
    
    if (points.count < 4) return [self copy];
    
    // Add control points to make the math make sense
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    NSMutableArray *breakPointArray = nil;
    if (breakPointStateArray && (breakPointStateArray.count > 0))
    {
        breakPointArray = [[NSMutableArray alloc] initWithArray:breakPointStateArray];
        [breakPointArray insertObject:breakPointStateArray[0] atIndex:0];
        [breakPointArray addObject:[breakPointStateArray lastObject]];
    }else{}
    
    UIBezierPath *smoothedPath = [self copy];
    [smoothedPath removeAllPoints];
    
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = POINT(index - 1);
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        CGPoint p3 = POINT(index + 2);
        
        if (breakPointStateArray)
        {// 跳过断点
            NSNumber *isBreakPoint = breakPointArray[index+1];
            if (isBreakPoint.boolValue)
            {
                [smoothedPath moveToPoint:p2];
                continue;                       // ! continue loop
            }else{}
        }else{}
        
        // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
        for (int i = 1; i < granularity; i++)
        {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

- (BOOL)samePointFrom:(CGPoint)ptSrc to:(CGPoint)ptDest
{
    return ((ptSrc.x == ptDest.x) && (ptSrc.y == ptDest.y));
}


@end
