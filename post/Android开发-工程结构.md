## Android开发-工程结构

#### Android工程典型结构  
使用`Eclipse`与`Android Studio`开发，Android Project的结构组织有较大出入，本文将分别描述  
  
###### 1. Eclipse，默认`Ant`构建工具[工程结构，参考1][1]
 <br />
  
| 名称 | 描述 |
| :---: | :--- |
| AndroidManifest.xml | 描述应用基本特征，定义应用组件(四大组件`Activity`、`Service`、`BroadcastReceiver`、`ContentProvider`) |
| project.properties | 工程设置，包括编译目标、ProGuard配置等；低版本`ADT`该文件名为`default.properties` |
| local.properties | 设置本地Java SDK路径，用于`Ant`构建 |
| ant.properties | 配置Release发布的签名信息，用于`Ant`构建 |
| build.xml | `Ant`构建文件 |
| /src/ | 包括`Java`源码、`AIDL`源码(.aidl)、`RenderScript`源码(.rs)，当然少不了相应的包结构目录 |
| /bin/ | 包含各种编译输出结果(具体编辑过程，后面文章在说)，包括最终的`APK`文件 |
| /jni/ | 包含`NDK`工程源文件、编译输出 |
| /gen/ | 包含资源文件编译输出的`R`文件，aidl文件编译输出的`Java`文件，rs文件编译输出的`Java`文件 |
| /libs/ | 第三方jar包、`so`文件，对于so文件需要将指定版本放置于对应子目录(`armeabi`、`armeabi-v7`、`x86`、`mips`，安装App时筛选正确版本的so) |
| /assets/ | 可以放置任何文件，简单打包进apk文件，所以在R.java中不存在id，通过`AssetManager`访问 |
| /res/ | 包含各种子路径，各个子路径存放对应资源，各个子路径(稍后详述，子目录名称规则) |
  
<br />
  
###### 2. Android Studio，默认`Gradle`构建工具[Gradle Android Plugin，参考2][2]
> Android Studio新建Android工程，存在`Project`与`Module`的概念，一个Android应用对应一个`Module`(和`Visual Studio`的`WorkSpace`、`Project`一个意思)  
> Gradle和Maven一样，强调约定优于配置，所以下面给出的均是约定的结构  
  
对于一个`Module`结构如下：  
  
| 名称 | 描述 |
| :---: | :--- |
| /src/ | 包含两种`source sets`，分别是`src/main/`、`src/androidTest/` |
| /src/main/AndroidManifest.xml | 参见上表`AndroidManifest.xml`描述 |
| /src/main/ic_launcher-web.png | 512*512应用图标，用于`Google Play`展示 |
| /src/main/java/ | 包含工程`Java`源码 |
| /src/main/aidl/ | 包含工程`AIDL`源码 |
| /src/main/rs/ | 包含工程`RenderScript`源码 |
| /src/main/jni/ | 包含`NDK`工程源码 |
| /src/main/assets/ | 包含工程资源，参见上表`/assets/`描述 |
| /src/main/res/ | 包含工程资源，参见上表`/res/`描述 |
| /libs/ | 参见上表`/libs/`描述 |
| /build/ | 包含唯一子目录`/build/generated/`，存放编译中间结果(R文件，rs编译输出，aidl编译输出等) |
| /libs/ | 参见上表`/libs/`描述 |
| /build.gradle | 该`Module`构建脚本 |
  

对于`Project`结构如下：  
  
| 名称 | 描述 |
| :---: | :--- |
| /libraries/ | 可以放置依赖的本地工程，可与`Eclipse`依赖本地Library方式对比(个人觉得Eclipse的方式要方便) |
| /XXXX/ | 上文所描述的`Module`文件夹 |
| /local.properties | 参见上表`local.properties`描述，用于`Gradle`构建 |
| /build.gradle | 该`Project`构建脚本 |
| /settings.gradle | 配置需要构建的模块列表，与`/build.gradle`协作完成多模块构建(和`Maven`多模块构建方式基本一致) |
  
<br />
  
###### 3. 到底是选择Eclipse开发还是选择Android Studio开发？
* Android Studio是Google基于`IntelliJ IDEA`专门针对Android推出，智能程度甩Eclipse几条街
* 依赖管理承接Maven，如果你用Eclipse，一个一个下载jar包，jar包版本冲突解决，都太麻烦了
* Gradle构建脚本灵活容易
* 所以开发Android强烈推荐Android Studio(Beta版已出)
  
###### 4. res/目录详解


---
#### 参考文献
1. [Managing Projects][1]
2. [Android Tools Project Site][2]


[1]: http://developer.android.com/intl/zh-cn/tools/projects/index.html "Managing Projects"
[2]: http://tools.android.com/tech-docs/new-build-system/user-guide