#### 我在简网上生成的GoodMan001.apk破解笔记

1. App界面组件研究
> `SplashActivity`后进入主界面，主界面样式由`MainActivityFactory`工厂类提供，生成具体导航样式主界面  
> `buildCubeNavIntent`三种导航样式主界面：`GridMenuActivity`，`VerticalMenuActivity`，`SplitMenuActivity`  
> `buildFixNavIntent`一种导航样式主界面：`FixNavActivity`  
> 两种其他样式主界面：`MommyActivity`，`AppSquareActivity`  

2. 相关导航实现研究
> `ActionBar`的实现基于开源框架`ActionBarSherlock`，但是当前Google已经出了一套Support v7包向下兼容Android低版本，当前`ActionBarSherlock`已经用的不多了  
> `Drawer导航`的实现基于开源框架`SlidingMenu`，同样当前Google已经出了一套Support v4包向下兼容Android低版本，当前`SlidingMenu`已经用的不多了  

3. 相关交互实现研究
> 类似于`Flipboard`的翻页效果基于`openaphid/android-flip`  
> 下拉刷新基于``实现`chrisbanes/Android-PullToRefresh`  
> 类似于`Pinterest`的瀑布流基于`GDG-Korea/PinterestLikeAdapterView`  
> 似乎简网在App里面自己做了一个浏览器组件，基于`lobobrowser`，`steadystate.css`，需要参看App里哪里有相关应用  

4. 相关功能实现研究
> `推送`基于`个推`  
> `统计`基于`有盟`  
> `定位`基于`百度地图sdk`  
> `xml`基于`FasterXML/jackson-core`  
> `一维码，二维码扫描`基于`ZBar`  
> `社会化分享`发现腾讯相关jar包  

#### 总结
> 以上是反编译apk文件的结果，可以看出为什么一个功能非常简单的站点最后的apk文件也是近7M的原因，因为相关功能基本都是`原生框架实现`