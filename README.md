JCLineChartView
===============

参考几个画曲线图代码，然后综合起来写的一个曲线视图。


================================================================

已实现：

1、能够类似PNChart在一个view上画多条曲线。

2、曲线通过Catmull-Rom样条插值实现，曲线趋势由  前两点 + 当前点 + 后一点  形成插值点。

3、多点间可插入值为 CGFLOAT_MIN 的点，使曲线断开。

4、支持环形曲线区域内填充颜色。

5、支持输入两条曲线，对两条曲线内区域填充颜色。


================================================================


Demo中的使用例子：

1、同时画多条曲线。

2、画中间有断点的线。

3、用颜色填充曲线内部区域。

4、用颜色填充曲线内部区域，且画边框。

5、输入两条曲线，对两条曲线间的区域进行颜色填充。



http://ww2.sinaimg.cn/bmiddle/9defab8bgw1em9eu4rvd9j20hs0wswfi.jpg

http://ww3.sinaimg.cn/bmiddle/9defab8bgw1em9eu5k4chj20hs0wst9l.jpg

http://ww2.sinaimg.cn/bmiddle/9defab8bgw1em9eu6dkcsj20hs0wswfb.jpg

http://ww4.sinaimg.cn/bmiddle/9defab8bgw1em9eu78zjhj20hs0wsdgt.jpg


================================================================

参考了

PNChart的画曲线代码：

https://github.com/kevinzhow/PNChart



MPPlot的平滑曲线插值代码：

https://github.com/MP0w/MPPlot






