## Android Methods Limitation

1. [How to solve the issue with Dalvik compiler limitation on 64K methods?](http://stackoverflow.com/questions/15436956/how-to-solve-the-issue-with-dalvik-compiler-limitation-on-64k-methods)
2. [Does the Android ART runtime have the same method limit limitations as Dalvik?](http://stackoverflow.com/questions/21490382/does-the-android-art-runtime-have-the-same-method-limit-limitations-as-dalvik)
3. [[DEX] Sky’s the limit? No, 65K methods is](https://medium.com/@rotxed/dex-skys-the-limit-no-65k-methods-is-28e6cb40cf71)


文章3小节：
* 原因描述
> You can reference a very large number of methods in a DEX file, but you can only invoke the first 65536, because that’s all the room you have in the method invocation instruction.  
>   
> […] the limitation is on the number of methods referenced, not the number of methods defined. If your DEX file has only a few methods, but together they call 70,000 different externally-defined methods, you’re going to exceed the limit.  
  
* 计算
> 计算`APK`每一个`Package`包含的`Method`数量。  
> 工具`dex-method-counts`[主页](https://github.com/mihaip/dex-method-counts)。  
  
* 解决方案
> 对于`google-play-services.jar`函数过多问题，采用`剔除`不需要组件策略。工具`strip_play_services.sh`[主页](https://gist.github.com/dextorer/a32cad7819b7f272239b)。  
> 借助`ProGuard`工具，剔除不需要的函数。  
> Android的`插件`机制，封装相关逻辑代码到`DEX`文件，APP运行时通过`ClassLoader`动态加载。  
> Android的插件机制，又是一个好大的知识点，可以参考[《Android 插件化 动态升级》][4]。
  
  
[4]: http://www.trinea.cn/android/android-plugin/
