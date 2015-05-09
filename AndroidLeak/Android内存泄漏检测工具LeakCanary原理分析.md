## Android内存泄漏检测工具LeakCanary原理分析

用于Android应用内存泄漏监测，Square开源的又一大作，设计非常精巧。  
  
https://github.com/square/leakcanary。
  
可以监测任何感兴趣的对象，包括`Activity`、`Fragment`，默认只监测`Activity`。  
  
库的用法很简单，说说原理吧~
  
### 原理
###### 1. `ActivityRefWatcher`中，注册Activity生命周期监听接口，当Activity onDestroy()被调用时，将当前Activity加入内存泄漏监听队列；  
  
```java
	private final Application.ActivityLifecycleCallbacks lifecycleCallbacks =
      new Application.ActivityLifecycleCallbacks() {
        @Override public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        }

        @Override public void onActivityStarted(Activity activity) {
        }

        @Override public void onActivityResumed(Activity activity) {
        }

        @Override public void onActivityPaused(Activity activity) {
        }

        @Override public void onActivityStopped(Activity activity) {
        }

        @Override public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        @Override public void onActivityDestroyed(Activity activity) {
          ActivityRefWatcher.this.onActivityDestroyed(activity);
        }
      };

  public void watchActivities() {
    // Make sure you don't get installed twice.
    stopWatchingActivities();
    application.registerActivityLifecycleCallbacks(lifecycleCallbacks);
  }

  public void stopWatchingActivities() {
    application.unregisterActivityLifecycleCallbacks(lifecycleCallbacks);
  }
```
  
注意注册Activity生命周期监听接口只在Android 4.0以上支持，如果要支持Android 4.0以下版本，可以参考`手机QQ`中采用的方法，见下一篇文章。  
  
###### 问题来了，如果要监听Fragment对象有无泄漏，怎么办？  
  
```java
public class ExampleApplication extends Application {

  public static RefWatcher getRefWatcher(Context context) {
    ExampleApplication application = (ExampleApplication) context.getApplicationContext();
    return application.refWatcher;
  }

  private RefWatcher refWatcher;

  @Override public void onCreate() {
    super.onCreate();
	// 默认开启对Activity泄漏的监听
    refWatcher = LeakCanary.install(this);
  }
}

// 定义自己的Fragment基类，onDestroy方法中添加对当前Fragment对象的watch
public abstract class BaseFragment extends Fragment {

  @Override public void onDestroy() {
    super.onDestroy();
    RefWatcher refWatcher = ExampleApplication.getRefWatcher(getActivity());
    refWatcher.watch(this);
  }
}

```
  
###### 2. `RefWatcher`中，`watch`方法将对象用`WeakReference`引起来,监听对象是否内存泄漏  
###### 这里的原理是：`WeakReference`和`ReferenceQueue<Object>`配合使用，如果弱引用所引用的对象被垃圾回收，Java虚拟机就会把这个弱引用加入到与之关联的引用队列  
###### 检测方法就很简单了，主动GC，触发`WeakReference`被GC，同时检测GC前后，ReferenceQueue是否包含被监听对象；如果不包含，则说明该对象没有被GC，一定存在到GC Roots的强引用链，也就是发生了泄漏。  
  
```java
  public void watch(Object watchedReference, String referenceName) {
    checkNotNull(watchedReference, "watchedReference");
    checkNotNull(referenceName, "referenceName");
    if (debuggerControl.isDebuggerAttached()) {
      return;
    }
    final long watchStartNanoTime = System.nanoTime();
    String key = UUID.randomUUID().toString();
    retainedKeys.add(key);
    final KeyedWeakReference reference =
        new KeyedWeakReference(watchedReference, key, referenceName, queue);

    watchExecutor.execute(new Runnable() {
      @Override public void run() {
        ensureGone(reference, watchStartNanoTime);
      }
    });
  }
  
  void ensureGone(KeyedWeakReference reference, long watchStartNanoTime) {
    long gcStartNanoTime = System.nanoTime();

    long watchDurationMs = NANOSECONDS.toMillis(gcStartNanoTime - watchStartNanoTime);
    removeWeaklyReachableReferences();
    if (gone(reference) || debuggerControl.isDebuggerAttached()) {
      return;
    }
    gcTrigger.runGc();
    removeWeaklyReachableReferences();
    if (!gone(reference)) {
      long startDumpHeap = System.nanoTime();
      long gcDurationMs = NANOSECONDS.toMillis(startDumpHeap - gcStartNanoTime);

      File heapDumpFile = heapDumper.dumpHeap();

      if (heapDumpFile == null) {
        // Could not dump the heap, abort.
        return;
      }
      long heapDumpDurationMs = NANOSECONDS.toMillis(System.nanoTime() - startDumpHeap);
      heapdumpListener.analyze(
          new HeapDump(heapDumpFile, reference.key, reference.name, watchDurationMs, gcDurationMs,
              heapDumpDurationMs));
    }
  }

  private boolean gone(KeyedWeakReference reference) {
    return !retainedKeys.contains(reference.key);
  }

  private void removeWeaklyReachableReferences() {
    // WeakReferences are enqueued as soon as the object to which they point to becomes weakly
    // reachable. This is before finalization or garbage collection has actually happened.
    KeyedWeakReference ref;
    while ((ref = (KeyedWeakReference) queue.poll()) != null) {
      retainedKeys.remove(ref.key);
    }
  }
```
  
###### 3. dump文件分析，`HeapAnalyzer`类
基于Square开源的`haha`库，专用于分析Android heap dump文件，https://github.com/square/haha。  
  
查看`haha`库的历史，可以发现是由`Eclipse Memory Analyzer`改版而来，支持Android Dalvik格式 heap dump文件的分析。  
  
分析的结果即泄漏对象到GC Roots强引用的最短路径，形式如下：  
```
In com.example.leakcanary:1.0:1 com.example.leakcanary.MainActivity has leaked:
* GC ROOT thread java.lang.Thread.<Java Local> (named 'AsyncTask #1')
* references com.example.leakcanary.MainActivity$3.this$0 (anonymous class extends android.os.AsyncTask)
* leaks com.example.leakcanary.MainActivity instance
```
  
其实看结果，就是我们平时用MAT工具分析的结果，系统的Android内存泄漏分析技巧，可以参见下一篇上传的文章。  
  
---
#### 对第2步基本原理的进一步补充：
1. 主动GC，采用`Runtime.getRuntime().gc()`（对比System.gc()的优点是能保证及时触发GC），同时GC后等待100ms，等待Java虚拟机把这个弱引用加入`ReferenceQueue<Object>`。  
参考`GcTrigger`类。  
```java
  GcTrigger DEFAULT = new GcTrigger() {
    @Override public void runGc() {
      // Code taken from AOSP FinalizationTest:
      // https://android.googlesource.com/platform/libcore/+/master/support/src/test/java/libcore/
      // java/lang/ref/FinalizationTester.java
      // System.gc() does not garbage collect every time. Runtime.gc() is
      // more likely to perfom a gc.
      Runtime.getRuntime().gc();
      enqueueReferences();
      System.runFinalization();
    }

    private void enqueueReferences() {
      // Hack. We don't have a programmatic way to wait for the reference queue daemon to move
      // references to the appropriate queues.
      try {
        Thread.sleep(100);
      } catch (InterruptedException e) {
        throw new AssertionError();
      }
    }
  };
```
2. 步骤2执行时机的选择，参考`AndroidWatchExecutor`类。  
在主线程空闲阶段，由主线程提交步骤2，即将步骤2放入子线程执行，这样可以尽可能小的降低子线程执行对主线程时间片抢占带来的影响。  
```java
  @Override public void execute(final Runnable command) {
    if (isOnMainThread()) {
      executeDelayedAfterIdleUnsafe(command);
    } else {
      mainHandler.post(new Runnable() {
        @Override public void run() {
          executeDelayedAfterIdleUnsafe(command);
        }
      });
    }
  }

  private boolean isOnMainThread() {
    return Looper.getMainLooper().getThread() == Thread.currentThread();
  }

  private void executeDelayedAfterIdleUnsafe(final Runnable runnable) {
    // This needs to be called from the main thread.
    Looper.myQueue().addIdleHandler(new MessageQueue.IdleHandler() {
      @Override public boolean queueIdle() {
        backgroundHandler.postDelayed(runnable, DELAY_MILLIS);
        return false;
      }
    });
  }
```
  
全文完~
  
