//
//  ViewController.m
//  JCLineChartViewDemo
//
//  Created by ThreegeneDev on 14-8-12.
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
    
    NSArray *xValue = @[@(10.0f), @(30.0f), @(40.0f), @(60.0f), @(70.0f), @(90.0f), @(110.0f), @(150.0f), @(180.0f), @(200.0f)];
    NSArray *yValue = @[@(10.0f), @(30.0f), @(35.0f), @(40.0f), @(50.0f), @(55.0f), @(55.0f), @(70.0f), @(100.0f), @(170.0f)];
    
    JCLineData *lineData = [[JCLineData alloc] init];
    lineData.lineColor = [UIColor greenColor];
    lineData.lineWidth = 1.0f;
    lineData.cyclePointWidth = 3.0f;
    lineData.pointStyle = kEJCLinePointStyleCycle;
    lineData.pointCount = xValue.count;
    lineData.getPointValue = ^CGPoint(NSUInteger index)
    {
        return CGPointMake([xValue[index] floatValue], [yValue[index] floatValue]);
    };
    
    NSArray *xValue2 = @[@(0.0f), @(20.0f), @(30.0f), @(50.0f), @(70.0f), @(100.0f), @(110.0f), @(160.0f), @(240.0f)];
    NSArray *yValue2 = @[@(10.0f), @(30.0f), @(40.0f), @(40.0f), @(80.0f), @(100.0f), @(120.0f), @(130.0f), @(140.0f)];
    // CGFLOAT_MIN
    JCLineData *lineData2 = [[JCLineData alloc] init];
    lineData2.lineColor = [UIColor blueColor];
    lineData2.lineWidth = 1.0f;
    lineData2.cyclePointWidth = 2.0f;
    lineData2.pointStyle = kEJCLinePointStyleCycle;
    lineData2.pointCount = xValue2.count;
    lineData2.showWithAnimation = YES;
    lineData2.animationDuration = 1.0f;
    lineData2.isCurved = NO;
    lineData2.getPointValue = ^CGPoint(NSUInteger index)
    {
        return CGPointMake([xValue2[index] floatValue], [yValue2[index] floatValue]);
    };
    
    
    [chartView showLines:@[lineData2, lineData] withChartBound:CGRectMake(0.0f, 0.0f, 300.0f, 180.0f)];
    
    
}






















@end
