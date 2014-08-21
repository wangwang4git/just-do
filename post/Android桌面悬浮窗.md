## Android桌面悬浮窗

#### 基本原理
1. `WindowManager`三个方法（实现接口`ViewManager`）：`addView`、`removeView`、`updateViewLayout`
2. 涉及`addView`、`updateViewLayout`的布局信息，由`WindowManager.LayoutParams`提供，关键参数
  
```
type：TYPE_PHONE // 权限：android.permission.SYSTEM_ALERT_WINDOW
flags：FLAG_NOT_FOCUSABLE | FLAG_NOT_TOUCH_MODAL
gravity：Gravity.LEFT | Gravity.TOP
width
heigth
x
y
...
```
  
3. 悬浮窗显示逻辑
  
```
当前界面是桌面，且没有悬浮窗显示，则创建悬浮窗
当前界面是桌面，且有悬浮窗显示，则更新悬浮窗信息
当前界面不是桌面，且有悬浮窗显示，则移除悬浮窗
```
  
其中判断当前界面是否是桌面，代码如下
  
```java
private boolean isHome() {
    ActivityManager mActivityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
    // Android3.0+需要权限：android.permission.GET_TASKS
    List<RunningTaskInfo> rti = mActivityManager.getRunningTasks(1);
    return getHomes().contains(rti.get(0).topActivity.getPackageName());
}

private List<String> getHomes() {
    List<String> names = new ArrayList<String>();
    PackageManager packageManager = getPackageManager();
    Intent intent = new Intent(Intent.ACTION_MAIN);
    intent.addCategory(Intent.CATEGORY_HOME);
    List<ResolveInfo> resolveInfo = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
    for (ResolveInfo ri : resolveInfo) {
        names.add(ri.activityInfo.packageName);
    }
    return names;
}
```
  
判断有无悬浮窗，逻辑如下
  
```java
public static boolean isWindowShowing() {
    return smallWindow != null || bigWindow != null;
}
```
  

#### 参考文章
1. [Android桌面悬浮窗效果实现，仿360手机卫士悬浮窗效果][1]
2. [Android桌面悬浮窗进阶，QQ手机管家小火箭效果实现][2]

[1]: http://blog.csdn.net/guolin_blog/article/details/8689140
[2]: http://blog.csdn.net/guolin_blog/article/details/16919859