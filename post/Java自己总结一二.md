## Java一二

#### Java内存泄露
对于Java这一类`内存托管`语言，内存泄露的主要原因：保留下来却永远不再使用的对象引用。  
> 内存泄露示例  

```java
Vector v = new Vector(10);
for (int i = 0; i < 10; ++i) {
	Object o = new Object();
	v.add(o);
	o = null;
}
```

对于C/C++来说，内存泄露的范围更大一些，有些对象被分配了内存空间，然后却不可达，这些内存将永远收不回来；而在Java中，这些对象可由GC回收。  

#### Java[垃圾收集][1]
###### 1.运行时数据区域划分  
JVM执行Java程序会把它所管理的内存划分为若干个不同的数据区域。  
> JVM运行时数据区
  
<center>![alt text](../img/Java一二01.png "JVM运行时数据区")</center>  
  
垃圾收集`堆`、`方法区`，其他区域不管。  
  
###### 2.垃圾收集理论部分
垃圾收集需要完成的三件事情：那些内存需要回收？什么时候回收？如何回收？  
  
定位待回收对象，采用`根搜索算法（GC Roots Tracing）`，而不是单纯的`引用计数算法`。  
  
如何回收对象，可采用算法有：`标记清除（Mark-Sweep）`、`复制（Copying）`、`标记整理（Mark-Compact）`、`分代收集（Generational Collection）`。  
> Sun HotSpot，分代策略：方法区->`永久代`、堆一部分->`老年代`、堆一部分->`新生代`（具体细分为`Eden`、`Survivor 1`、`Survivor 2`）  
  
什么时候回收对象，一方面是说内存分配满足特定的垃圾收集器设定的阈值，触发收集；另一方面是程序线程执行到相关`安全点`/`安全区域`，垃圾收集器执行相关收集工作。  

###### 3.典型垃圾收集器  
> HotSpot JVM垃圾收集器
  
<center>![alt text](../img/Java一二02.png "HotSpot垃圾收集器")</center>  
  
重点关注的几个：`Parallel Scavenge-用于控制JVM吞吐量Throughput`、`CMS`、`G1`。其中`G1`没有分代的概念，有一个分区`region`的概念。  
  
JVM调优会涉及到垃圾收集器选择与设置。  
  
#### Java Object
###### 1.toString()
用于显示调用输出对象信息，或者`this + "string"`字符串重载`+`运算符形式，将`this`转为`String`类型（隐式调用）。  
  
###### 2.hashCode()
用于`HashMap`中元素增删改查时`Key`的`Hash`操作。
> JDK`HashMap`的`hash()`源码如下
  
```java
/**
 * Retrieve object hash code and applies a supplemental hash function to the
 * result hash, which defends against poor quality hash functions.  This is
 * critical because HashMap uses power-of-two length hash tables, that
 * otherwise encounter collisions for hashCodes that do not differ
 * in lower bits. Note: Null keys always map to hash 0, thus index 0.
 */
final int hash(Object k) {
    int h = 0;
    if (useAltHashing) {
        if (k instanceof String) {
            return sun.misc.Hashing.stringHash32((String) k);
        }
        h = hashSeed;
    }

    h ^= k.hashCode();

    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).
    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}
```
  
重写`hashCode()`函数是一个考点，需要注意一些细节。  
> 重写`hashCode()`函数
  
```java
public int hashCode() {
	return id != null ? id.hashCode() : 0;
    // 或者自定义Hash算法
}
```
  
###### 3.equals()
用于对象相等测试，比如容器`indexOf()`、`remove()`、`contains()`等函数中。  
> JDK`ArrayList`的`indexOf()`源码如下
  
```java
/**
 * Returns the index of the first occurrence of the specified element
 * in this list, or -1 if this list does not contain the element.
 * More formally, returns the lowest index <tt>i</tt> such that
 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>,
 * or -1 if there is no such index.
 */
public int indexOf(Object o) {
    if (o == null) {
        for (int i = 0; i < size; i++)
            if (elementData[i]==null)
                return i;
    } else {
        for (int i = 0; i < size; i++)
            if (o.equals(elementData[i]))
                return i;
    }
    return -1;
}
```
  
重写`equals()`函数是一个考点，需要注意一些细节。  
> 重写`equals()`函数
  
```java
public boolean equals(Object o) {
	// 判断自己比较自己
    if (this == o) {
    	return true;
    }
    // 判断参数，判断参数Class对象与自己Class对象
    if (o == null || getClass() != o.getClass()) {
    	return false;
    }
    A a = (A) o;
    // 判断待比较字段
    if (id != null) {
    	return id.equals(a.id);
    } else {
    	return a.id == null;
    }
}
```
  
###### 4.clone()
注意浅复制与深复制。  
  
重写`clone()`，同时还应该实现标志接口`Cloneable`，当对象存在组合关系时，需要考虑组合对象的`Clone`。  
> 示例
  
```java
class ClassA implements Cloneable {
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}
...
class ClassB implements Cloneable {
    ClassA a;

    @Override
    public Object clone() throws CloneNotSupportedException {
        ClassB b = (ClassB) super.clone();
        if (a != null) {
            b.a = (ClassA) a.clone();
        }
        return b;
    }
}
```
  
###### 5.多个wait()
用于多线程同步，阻塞线程，注意：`wait()`函数的调用必须先获取`锁`。  
  
###### 6.notify()/notifyAll()
用于多线程同步，唤醒线程，注意：`notify()`/`notifyAll()`函数的调用必须先获取`锁`（与`wait()`调用时同一个`锁`）。  
> 典型用法
  
```java
// 线程一
synchronized(shareMonitor) {
	while (conditionIsNotMet) {
    	shareMonitor.wait();
    }
}
...
// 线程二
synchronized(shareMonitor) {
    shareMonitor.notifyAll();
}
```
  
> 当然可以使用显示的`Lock`、`Condition`对象
  
```java
Lock lock = new ReentrantLock();
Condition cond = lock.newCondition();
...
// 线程一
lock.lock();
try {
	while (conditionIsNotMet) {
    	cond.await();
    }
} finally {
	lock.unlock();
}
...
// 线程二
lock.lock();
try {
	cond.signal();
} finally {
	lock.unlock();
}
```
  
###### 8.getClass()
获取`Class`对象，它包含了与类有关的信息，用于`RTTI`。事实上，Class对象就是用来创建类的所有`常规`对象的。  
  
每一个类都有一个Class对象。  
  
###### 9.fianlize()
一旦垃圾回收器准备好释放对象占用的存储空间，将首先调用其`finalize`方法，并且在下一次垃圾回收动作发生时，才会真正回收对象占用的内存。  
  
潜在的编程陷进：将`finalize()`等同于C++析构函数。对象被回收的时机是不确定的，也可能永远不会被回收，如果资源的释放依赖于`finalize()`，那么释放可能永远也不会发生。  

#### Java Container容器

#### Java IO

#### Java并发


---
#### 书籍列表
1. [深入理解Java虚拟机][1]

[1]: http://book.douban.com/subject/24722612/