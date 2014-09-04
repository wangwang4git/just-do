#### Android三方库

1. `SnappyDB`，key-value存储，用于构建缓存系统，[主页][1]。
  
2. `RoboSpice`，用于异步网络请求，解决`AsyncTask`、`Loader`设计问题，[主页][2]。
  
3. `Dagger`，Android平台依赖注入，解耦与模块化，[主页][4]。
  
4. `RoboGuice`，依赖注入库，[主页][5]。
  
5. `SmartImageView`，异步加载、本地/内存二级缓存，简单，适合用于三方库学习，[主页][6]。
  
6. `UniversalImageLoader`，异步加载、本地/内存二级缓存，[主页][7]，设计的缓存架构推荐好好读读，相关内容参见[文章][8]。
  
7. `Picasso`，`Square`出品，必属精品，图片异步加载缓存，[主页][9]。
  
8. `UrlImageViewHelper`，也是个图片异步加载缓存库，可以学习学习源码，[主页][10]。
  
9. `ACRA`，Android崩溃日志报告，[主页][12]。
  
10. `PhotoView`，图片显示，支持手势缩放，[主页][13]。
  
11. `GestureImageView`，图片显示，支持手势缩放，[主页][14]。
  
12. `Android-Gif-Drawable`，显示gif图，[主页][15]。
  
13. `Android-PullToRefresh`，下拉刷新，个人不推荐该下拉刷新的交互方式，[主页][16]。
  
14. `ActionBar-PullToRefresh`，下拉刷新，个人推荐的交互方式，[主页][17]，同时Google支持包也提供官方实现`SwipeRefreshLayout`，[参考][18]。
  
15. `SuperToasts`，Android Toast的增强版本，[主页][19]。
  
16. `android-async-http`，Android异步网络请求库，[主页][20]。
  
17. `greenDAO`，Sqlite3 ORM库，[主页][21]。
  
18. `OrmLite`，ORM库，[主页][22]。
  
19. `EventBus`，组件间事件总线，用于组件解耦，[主页][23]。
  
20. `Otto`，事件总线，`Square`出品，[主页][24]。
  
21. `NineOldAndroids`，Android 3.0增加`属性动画`，该库实现`属性动画`向前版本兼容，[主页][25]。
  
22. `fastjson`，阿里出品Json序列化/反序列化库，[主页][26]。
  
23. `Jackson`，Json序列化/反序列化库，[主页][27]。
  
24. `Gson`，Google出品Json序列化/反序列化库，[主页][28]。
  
25. `DebugLog`，日志信息增强可读性，[主页][29]。
  
26. `ProgressWheel`，圆形进度条，[主页][30]。
  
27. `FloatLabeledEditView`，`EditView`浮动提示，[主页][31]。
  
28. `PagerSlidingTabStrip`，An interactive indicator to navigate between the different pages of a ViewPager，[主页][32]。
  
29. `Android-ViewPagerIndicator`，交互同上，[主页][33]。
  
30. `line-breaking-widget-layout-for-android`，`PredicateLayout`用于实现自动换行的容器控件，[参考][34]。
  
31. `StickyGridHeaders`，分组`GridView`，[主页][35]。
  
32. `SlidingMenu`，侧导航，[主页][36]。
  
33. `ActionBarSherlock`，`ActionBar`兼容包，[主页][37]，但是Google出了官方兼容包`ActionBarCompact`（现在已经不推荐使用`ActionBarSherlock`），[参考][38]，两者[对比][39]。
  
34. `DrawerLayout`，抽屉导航，Google官方兼容包`DrawerLayout`，[参考][40]。
  
35. `HoloAccent`，holo风格组件颜色快速替换，[主页][41]。
  
36. `commons-codec`，common encoders and decoders，[主页][42]。
  
37. `sanselan`，java实现的图片库，支持图片信息读取，项目中用来获取`EXIF`信息，[主页][43]。
  
38. `Glide`，图像加载缓存，[主页][44]。
  
39. `ButterKnife`，控件依赖注入，避免重复编写`findViewById`等，[主页][45]。
  
40. `Android-Priority-JobQueue`，Android任务调度，支持任务持久化，[主页][46]。
  
41. `MPAndroidChart`，显示质量挺不错的Android图表库，[主页][49]。
  
----
#### Android应用架构经验

1. [健壮且可读的安卓架构设计][3]
2. [图片异步加载/缓存开源库选型][11]
3. [做一个懒惰高效的Android程序员][47]，[原文链接][48]

----
#### To Do List
- [ ] Dragger学习与应用，对比`RoboGuice`、`ButterKnife`
- [ ] 研究ORM实现原理

[1]: https://github.com/nhachicha/SnappyDB "SnappyDB"
[2]: https://github.com/stephanenicolas/robospice "RoboSpice"
[3]: http://blog.jobbole.com/66606/
[4]: http://square.github.io/dagger/ "Dagger"
[5]: https://github.com/roboguice/roboguice "RoboGuice"
[6]: http://loopj.com/android-smart-image-view/ "SmartImageView"
[7]: https://github.com/nostra13/Android-Universal-Image-Loader "UniversalImageLoader"
[8]: ./UIL学习.md "UIL学习笔记"
[9]: http://square.github.io/picasso/ "Picasso"
[10]: https://github.com/koush/UrlImageViewHelper "UrlImageViewHelper"
[11]: http://blog.jobbole.com/66115/
[12]: https://github.com/ACRA/acra "ACRA"
[13]: https://github.com/chrisbanes/PhotoView "PhotoView"
[14]: https://github.com/jasonpolites/gesture-imageview "GestureImageView"
[15]: https://github.com/koral--/android-gif-drawable "Android-Gif-Drawable"
[16]: https://github.com/chrisbanes/Android-PullToRefresh "Android-PullToRefresh"
[17]: https://github.com/chrisbanes/ActionBar-PullToRefresh "ActionBar-PullToRefresh"
[18]: http://developer.android.com/intl/zh-cn/reference/android/support/v4/widget/SwipeRefreshLayout.html "SwipeRefreshLayout"
[19]: https://github.com/JohnPersano/SuperToasts "SuperToasts"
[20]: http://loopj.com/android-async-http/ "android-async-http"
[21]: http://greendao-orm.com/ "greenDAO"
[22]: http://ormlite.com/ "OrmLite"
[23]: https://github.com/greenrobot/EventBus "EventBus"
[24]: http://square.github.io/otto/ "Otto"
[25]: http://nineoldandroids.com/ "NineOldAndroids"
[26]: https://github.com/alibaba/fastjson "fastjson"
[27]: https://github.com/FasterXML/jackson "Jackson"
[28]: http://code.google.com/p/google-gson/ "Gson"
[29]: https://github.com/MustafaFerhan/DebugLog "DebugLog"
[30]: https://github.com/Todd-Davies/ProgressWheel "ProgressWheel"
[31]: https://github.com/wrapp/floatlabelededittext "Float Labeled EditText"
[32]: https://github.com/astuetz/PagerSlidingTabStrip "PagerSlidingTabStrip"
[33]: https://github.com/JakeWharton/Android-ViewPagerIndicator "Android-ViewPagerIndicator"
[34]: http://stackoverflow.com/questions/549451/line-breaking-widget-layout-for-android "PredicateLayout"
[35]: http://tonicartos.github.io/StickyGridHeaders/ "StickyGridHeaders"
[36]: https://github.com/jfeinstein10/SlidingMenu "SlidingMenu"
[37]: http://actionbarsherlock.com/ "ActionBarSherlock"
[38]: http://android-developers.blogspot.com/2013/08/actionbarcompat-and-io-2013-app-source.html "ActionBarCompat"
[39]: http://stackoverflow.com/questions/7844517/difference-between-actionbarsherlock-and-actionbar-compatibility "ActionBarSherlock vs ActionBarCompat"
[40]: https://developer.android.com/intl/zh-cn/reference/android/support/v4/widget/DrawerLayout.html "DrawerLayout"
[41]: https://github.com/negusoft/holoaccent "HoloAccent"
[42]: http://commons.apache.org/proper/commons-codec/ "Commons Codec"
[43]: http://commons.apache.org/proper/commons-imaging/ "Commons Imaging"
[44]: https://github.com/bumptech/glide "Glide"
[45]: http://jakewharton.github.io/butterknife/ "ButterKnife"
[46]: https://github.com/path/android-priority-jobqueue "Android-Priority-JobQueue"
[47]: http://blog.jobbole.com/76361/
[48]: http://www.technotalkative.com/lazy-part-8-wireframemockup-tools/
[49]: https://github.com/PhilJay/MPAndroidChart "MPAndroidChart"
