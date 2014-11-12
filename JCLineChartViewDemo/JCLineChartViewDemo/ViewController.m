//
//  ViewController.m
//  JCLineChartViewDemo
//
//  Created by Jimple on 14-8-12.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "ViewController.h"
#import "JCLineChartView.h"
#import "JCLineData.h"
#import "JCLinePointData.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [self showChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showChart
{
    JCLineChartView *chartView = [[JCLineChartView alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 300.0f, 200.0f)];
    chartView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    [self.view addSubview:chartView];
    
    NSArray *xValue = @[@(10.0f), @(30.0f), @(40.0f), @(70.0f), @(90.0f), @(110.0f), @(150.0f), @(180.0f), @(180.0f)];
    NSArray *yValue = @[@(40.0f), @(30.0f), @(35.0f), @(50.0f), @(55.0f), @(55.0f), @(70.0f), @(100.0f), @(190.0f)];
    
    JCLineData *lineData = [[JCLineData alloc] init];
    lineData.lineColor = [UIColor greenColor];
    lineData.lineWidth = 1.0f;
    lineData.cyclePointWidth = 4.0f;
    lineData.pointStyle = kEJCLinePointStyleCycle;
    lineData.pointCount = xValue.count;
    lineData.getPointValue = ^CGPoint(NSUInteger index)
    {
        return CGPointMake([xValue[index] doubleValue], [yValue[index] doubleValue]);
    };
    
    NSArray *xValue2 = @[@(0.0f), @(20.0f), @(30.0f), @(50.0f), @(70.0f), @(100.0f), @(110.0f), @(160.0f), @(220.0f)];
    NSArray *yValue2 = @[@(20.0f), @(30.0f), @(40.0f), @(50.0f), @(80.0f), @(100.0f), @(120.0f), @(130.0f), @(170.0f)];

    JCLineData *lineData2 = [[JCLineData alloc] init];
    lineData2.lineColor = [UIColor blueColor];
    lineData2.lineWidth = 1.0f;
    lineData2.cyclePointWidth = 6.0f;
    lineData2.cyclePointFillColor = chartView.backgroundColor;
    lineData2.pointStyle = kEJCLinePointStyleCycle;
    lineData2.pointCount = xValue2.count;
    lineData2.showWithAnimation = YES;
    lineData2.animationDuration = 1.0f;
    lineData2.isCurved = YES;
    lineData2.getPointValue = ^CGPoint(NSUInteger index)
    {
        return CGPointMake([xValue2[index] doubleValue], [yValue2[index] doubleValue]);
    };
    
    // 同时画两条曲线
    [chartView showLines:@[lineData2, lineData] withChartBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)];
    
    
    // 画中间有断点的线（目前仅能用直线连接，不支持插值成曲线。isCurved设置无效）
    double delayInSeconds1 = 2.0f;
    dispatch_time_t delayTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds1 * NSEC_PER_SEC));
    dispatch_after(delayTime1, dispatch_get_main_queue(), ^(void){
        [chartView clearChart];
        
        NSArray *xValue4 = @[@(0.0f), @(20.0f),  @(CGFLOAT_MIN), @(30.0f), @(50.0f), @(70.0f), @(100.0f), @(CGFLOAT_MIN), @(110.0f), @(160.0f), @(240.0f)];
        NSArray *yValue4 = @[@(10.0f), @(30.0f),  @(CGFLOAT_MIN), @(40.0f), @(50.0f), @(80.0f), @(100.0f), @(CGFLOAT_MIN), @(120.0f), @(130.0f), @(140.0f)];
        JCLineData *lineData4 = [[JCLineData alloc] init];
        lineData4.lineColor = [UIColor blueColor];
        lineData4.lineWidth = 1.0f;
        lineData4.cyclePointWidth = 2.0f;
        lineData4.pointStyle = kEJCLinePointStyleCycle;
        lineData4.pointCount = xValue4.count;
        lineData4.showWithAnimation = YES;
        lineData4.animationDuration = 1.0f;
        lineData4.isCurved = YES;
        lineData4.getPointValue = ^CGPoint(NSUInteger index)
        {
            return CGPointMake([xValue4[index] doubleValue], [yValue4[index] doubleValue]);
        };
        
        [chartView showLines:@[lineData4] withChartBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)];
    });
    
    
    
    
    
    // 颜色填充环形曲线内部
    double delayInSeconds2 = 4.0f;
    dispatch_time_t delayTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(delayTime2, dispatch_get_main_queue(), ^(void){
        [chartView clearChart];
        
        NSArray *xValue3 = @[@(20.0f), @(25.0f), @(50.0f), @(70.0f), @(80.0f), @(100.0f), @(150.0f), @(150.0f), @(130.0f), @(100.0f), @(80.0f), @(40.0f)];
        NSArray *yValue3 = @[@(10.0f), @(20.0f), @(35.0f), @(50.0f), @(58.0f), @(73.0f), @(90.0f), @(70.0f), @(60.0f), @(50.0f), @(40.0f), @(20.0f)];
        JCLineData *lineData3 = [[JCLineData alloc] init];
        lineData3.lineColor = [UIColor redColor];
        lineData3.lineWidth = 1.0f;
        lineData3.pointStyle = kEJCLinePointStyleNone;
        lineData3.pointCount = xValue3.count;
        lineData3.isCurved = NO;
        lineData3.getPointValue = ^CGPoint(NSUInteger index)
        {
            return CGPointMake([xValue3[index] doubleValue], [yValue3[index] doubleValue]);
        };
        [chartView cycleLine:lineData3
                  fillColors:@[[UIColor colorWithRed:1.000 green:0.0 blue:0.0 alpha:1.0],[UIColor colorWithRed:1.0 green:0.80 blue:0.000 alpha:1.0]]
                     inBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)
              drawBorderLine:NO];
    });
    
    
    
    
    
    // 颜色填充环形曲线内部，且画边缘曲线
    double delayInSeconds3 = 5.0f;
    dispatch_time_t delayTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));
    dispatch_after(delayTime3, dispatch_get_main_queue(), ^(void){
        [chartView clearChart];
        
        NSArray *xValue3 = @[@(20.0f), @(25.0f), @(50.0f), @(70.0f), @(80.0f), @(100.0f), @(150.0f), @(150.0f), @(130.0f), @(100.0f), @(80.0f), @(40.0f),@(20.0f),@(20.0f)];
        NSArray *yValue3 = @[@(10.0f), @(20.0f), @(35.0f), @(50.0f), @(58.0f), @(73.0f), @(90.0f), @(70.0f), @(60.0f), @(50.0f), @(40.0f), @(20.0f),@(0.0f),@(10.0f)];
        JCLineData *lineData3 = [[JCLineData alloc] init];
        lineData3.lineColor = [UIColor blueColor];
        lineData3.lineWidth = 1.0f;
        lineData3.cyclePointWidth = 2.0f;
        lineData3.pointStyle = kEJCLinePointStyleNone;
        lineData3.pointCount = xValue3.count;
        lineData3.showWithAnimation = YES;
        lineData3.animationDuration = 1.0f;
        lineData3.isCurved = YES;
        lineData3.getPointValue = ^CGPoint(NSUInteger index)
        {
            return CGPointMake([xValue3[index] doubleValue], [yValue3[index] doubleValue]);
        };
        [chartView cycleLine:lineData3
                  fillColors:@[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3],[UIColor colorWithRed:0.0 green:0.80 blue:1.0 alpha:0.3]]
                     inBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)
              drawBorderLine:YES];
    });
    
    
    
    // 颜色填充两条曲线之间的区域
    double delayInSeconds4 = 7.0f;
    dispatch_time_t delayTime4 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds4 * NSEC_PER_SEC));
    dispatch_after(delayTime4, dispatch_get_main_queue(), ^(void){
        [chartView clearChart];
        
        NSArray *xValue1 = @[@(20.0f), @(25.0f), @(50.0f), @(70.0f), @(80.0f), @(100.0f), @(150.0f), @(160.0f), @(170.0f), @(180.0f), @(200.0f)];
        NSArray *yValue1 = @[@(60.0f), @(50.0f), @(65.0f), @(70.0f), @(78.0f), @(83.0f), @(90.0f), @(90.0f), @(110.0f), @(130.0f), @(140.0f)];
        JCLineData *lineData1 = [[JCLineData alloc] init];
        lineData1.lineColor = [UIColor redColor];
        lineData1.lineWidth = 1.0f;
        lineData1.cyclePointWidth = 2.0f;
        lineData1.pointStyle = kEJCLinePointStyleNone;
        lineData1.pointCount = xValue1.count;
        lineData1.showWithAnimation = YES;
        lineData1.animationDuration = 1.0f;
        lineData1.isCurved = YES;
        lineData1.getPointValue = ^CGPoint(NSUInteger index)
        {
            return CGPointMake([xValue1[index] doubleValue], [yValue1[index] doubleValue]);
        };
        
        NSArray *xValue2 = @[@(10.0f), @(22.0f), @(30.0f), @(44.0f), @(60.0f), @(80.0f), @(110.0f), @(120.0f), @(160.0f), @(170.0f), @(200.0f)];
        NSArray *yValue2 = @[@(10.0f), @(20.0f), @(35.0f), @(40.0f), @(58.0f), @(43.0f), @(70.0f), @(40.0f), @(30.0f), @(60.0f), @(80.0f)];
        JCLineData *lineData2 = [[JCLineData alloc] init];
        lineData2.lineColor = [UIColor blueColor];
        lineData2.lineWidth = 1.0f;
        lineData2.cyclePointWidth = 2.0f;
        lineData2.pointStyle = kEJCLinePointStyleNone;
        lineData2.pointCount = xValue2.count;
        lineData2.showWithAnimation = YES;
        lineData2.animationDuration = 1.0f;
        lineData2.isCurved = YES;
        lineData2.getPointValue = ^CGPoint(NSUInteger index)
        {
            return CGPointMake([xValue2[index] doubleValue], [yValue2[index] doubleValue]);
        };
        
        [chartView fillColors:@[[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3],[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]]
                      inBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)
                  betweenLine:lineData1
                      andLine:lineData2];
        
        // 同时画两条曲线
        [chartView showLines:@[lineData1, lineData2] withChartBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)];
    });
}






















@end
