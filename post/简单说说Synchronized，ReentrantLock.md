## 简单说说Synchronized，ReentrantLock

#### 背景，应该就是`Synchronized`的缺点
* `Synchronized`产生原因，`原子性(Atomicity)`与`可见性(visibility)`，其中可见性涉及到`JMM`的`happens-before`原语，这又涉及到`Memory Barrier`，推荐这篇文章[《并发导论》][1]

* `Synchronized`使用示例

	```java
    synchronized (lockObject) {
		// update object state
	}
	```

* 但是`Synchronized`存在的缺点是：它无法中断一个正在等候获得锁的线程，也无法通过投票得到锁...同时多个线程争用同一个锁，jvm的总体开销有点大

#### `ReentrantLock`
* 默认是不公平(`unfair`)锁
* 有一个与锁相关的`获取计数器`，获取一次加一，获取两次加二，注意释放两次才代表真正释放锁

* `ReentrantLock`使用示例

	```java
    ReentrantLock lock = new ReentrantLock();
    lock.lock();
    try {
    	// update object state
    }
    finally {
    	lock.unlock();
    }
	```

* 相比较`Synchronized`，`ReentrantLock`在调度的开支上花的时间相对少，从而为更高的吞吐率留下空间，实现了更有效的CPU利用

#### `Condition`
* 对比`JDK 1.4`以前版本中的`Object.wait()`，`Object.notify()`，`Object.notifyAll()`，上述三种线程间同步方式有问题，可问题是什么，需要继续学习，留在`todolist`...

* `Condition`提供`await()`，`signal()`，`signalAll()`用于实现上述功能

* `Condition`使用示例，需要和`ReentrantLock`配合，简单使用参见[《关于JAVA Condition 条件变量》][3]
	```java
    ReentrantLock lock = new ReentrantLock();
    Condition condition = lock.newCondition();
    lock.lock();
    try {
    	condition.await();
    	// update object state
    }
    finally {
    	lock.unlock();
    }
    
    condition.signal();
    condition.signalAll();
    ```
#### 那么在什么时候使用`ReentrantLock`
* 需要实现`时间锁等候`，`可中断锁等候`，`无块结构锁`，`多个条件变量`，`锁投票`，`高度争用`的情形

#### TODOLIST
1. [《ReentrantLock代码剖析之ReentrantLock.lock》][4]
2. `Object.wait()`，`Object.notify()`，`Object.notifyAll()`会存在的问题到底是什么？

#### 参考文献
1. [Java 理论与实践: JDK 5.0 中更灵活、更具可伸缩性的锁定机制][2]


[1]: http://ifeve.com/concurrency-paper/
[2]: http://www.ibm.com/developerworks/cn/java/j-jtp10264/index.html
[3]: http://my.oschina.net/leoson/blog/106452
[4]: http://www.cnblogs.com/MichaelPeng/archive/2010/02/12/1667947.html
