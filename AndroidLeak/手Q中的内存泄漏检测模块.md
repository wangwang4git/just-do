#### 手Q中的内存泄漏检测模块
---

出自`acolorzhang`之手，学习前辈知识，简单代码确很值得一学！  

###### 1. 位置
包com.tencent.mobileqq.memoryleak
* LeakInspector
  - MonitorInstrumentation
* ActivityLeakSolution
* DumpMemInfoHandler

包com.tencent.mobileqq.startup.step
* InitLeakInspector
  - LeakListener
  
其中`InitLeakInspector`步骤，自动机调度，依附于`LoadDex`步骤。  
  
`InitLeakInspector`步骤的工作很简单：  
1. 创建`LeakInspector`单例（整个手Q，有且只能有一个！！），并把`LeakListener`对象传给`LeakInspector`实例用于回调。  
比如dump堆快照前来次回调，让你有机会给UI提示；再比如dump完了回调，让你给UI提示；还有一个比较重要`filter()`，每次在进行指定`activity`内存泄漏检测前，回调一下，根据过滤规则判断还要不要继续检测！  
  
2. 开启`activity`监控，也很简单，第一次反射拿到`android.app.ActivityThread`的单例`sCurrentActivityThread`，第二次反射拿到`sCurrentActivityThread`的成员`mInstrumentation`，保存旧的`mInstrumentation`，用自己的`MonitorInstrumentation`替换系统的。  
代码很短，却给我很大启示，活用java反射hack系统，完成自己的目的！  
  
	```java
	public static boolean startActivityInspect() {
		Object currentActivityThread = BaseApplicationImpl.sCurrentActivityThread;
		Field field = currentActivityThread.getClass().getDeclaredField("mInstrumentation");
		field.setAccessible(true);
		field.set(currentActivityThread, new MonitorInstrumentation());
	}

	private static class MonitorInstrumentation extends Instrumentation {
		@Override
		public void callActivityOnDestroy(Activity activity) {
			sOldInstr.callActivityOnDestroy(activity);
			afterOnDestroy(activity);
		}

		public static void afterOnDestroy(Activity activity) {
			startInspect(activity);
		}
	}
	```
  
3. `MonitorInstrumentation`实现只重写了`callActivityOnDestroy()`方法，一旦手Q中有activity被destory，该方法就会被回调，给子线程传Runnable`InspectorRunner`，同时调用清理资源函数，清理与该activity相关的资源，参见`ActivityLeakSolution`实现。  
  
4. `InspectorRunner`先用弱引用持有当前被destory的activity，然后每间隔1s，检测弱引用`get()`操作是否为空，
不为空显然还没被gc，继续循环，循环100次。  
  
	```java
	private class InspectorRunner implements Runnable {
		private WeakReference<Object> ref;
		private String className;

		InspectorRunner(WeakReference<Object> ref, String name, int retryCount) {
			this.ref = ref;
			try {
				className = ref.get().getClass().getSimpleName();
			} catch(Exception e) {
				className = "Default";
			}
		}

		@Override
		public void run() {
			if (ref.get() != null) {//还没有释放
				if (++retryCount < LOOP_MAX_COUNT) {
					System.gc();
					mHandler.postDelayed(this, 1000);
					return ;
				} else {
					//到这里是检查完毕了，回调一下通知结果
					if (QLog.isColorLevel()) {
						QLog.d(TAG, QLog.CLR, "inspect " + digest + " leaked");
					}
					mListener.onLeaked(digest, ref);
				}
			} else {
				if (QLog.isColorLevel()) {
					QLog.d(TAG, QLog.CLR, "inspect " + digest + " finished no leak");
				}
			}
		}
	}
	```
  
5. 如果检测100次（很显然时间是至少100s），还没被回收，就判断该activity发生了泄漏，dump dalvik堆快照，over~
  
<br />
关键知识点：
1. Instrumentation；
2. 弱引用；
3. java反射hack系统framwork层；
