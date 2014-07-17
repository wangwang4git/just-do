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
  
Object中默认的实现是一个浅复制，如果要实现深复制，必须对类中可变域生成新的实例。  
  
重写`clone()`，同时还应该实现标志接口`Cloneable`，当对象存在组合关系时，需要考虑组合对象的`Clone`。  
> 示例（其实`Clone()`用的不多）
  
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
  
<center>![alt text](../img/Java一二03.png "Java容器类库")</center>
  
###### 1.ArrayList
底层数据结构：`Object[]`。  
  
默认数组容量：10。  
> 参考源码
  
```java
...
private transient Object[] elementData;
...
public ArrayList(int initialCapacity) {
    super();
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal Capacity: "+ initialCapacity);
    this.elementData = new Object[initialCapacity];
}
...
public ArrayList() {
    this(10);
}
...
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    size = elementData.length;
    // c.toArray might (incorrectly) not return Object[] (see 6260652)
    if (elementData.getClass() != Object[].class)
        elementData = Arrays.copyOf(elementData, size, Object[].class);
}
```
  
扩容方案：当前数组长度 * `1.5`。同时存在缩容方案：`trimToSize()`。  
> 参考源码
  
```java
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```
  
迭代器遍历：`iterator()`方法返回`AbstractList`内部类`Itr`对象（`ArrayList`同样存在一份可选`Itr`内部类）。迭代器内部`next()`、`remove()`有`快速失败`检查。也包含`listIterator()`，参见`LinkedList`部分。  
  
###### 2.LinkedList
底层数据结构：`双向链表`。  
> 参考源码
  
```java
...
transient Node<E> first;
transient Node<E> last;
...
public LinkedList() {
}
...
private static class Node<E> {
    E item;
    Node<E> next;
    Node<E> prev;

    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```
  
`get()`方案：获取位置小于`LinkedList`长度一半，从头遍历；获取位置大于等于`LinkedList`长度一半，从尾遍历。  
> 参考源码：
  
```java
Node<E> node(int index) {
    // assert isElementIndex(index);

    if (index < (size >> 1)) {
        Node<E> x = first;
        for (int i = 0; i < index; i++)
            x = x.next;
        return x;
    } else {
        Node<E> x = last;
        for (int i = size - 1; i > index; i--)
            x = x.prev;
        return x;
    }
}
```
  
迭代器遍历：`listIterator(index)`方法返回内部类`ListItr`对象，支持`hasPrevious()`、`hasNext()`遍历，同时支持`add()`、`set()`、`remove()`操作。同样包含`快速失败`检查。  
  
###### 3.Vector
> 取自类注释（基本就是，这个类能不用就不用，设计的同步粒度太大了，降低性能啊！）
  
```java
/*
...
* <p>As of the Java 2 platform v1.2, this class was retrofitted to
* implement the {@link List} interface, making it a member of the
* <a href="{@docRoot}/../technotes/guides/collections/index.html">
* Java Collections Framework</a>.  Unlike the new collection
* implementations, {@code Vector} is synchronized.  If a thread-safe
* implementation is not needed, it is recommended to use {@link
* ArrayList} in place of {@code Vector}.
...
*/
```
  
底层数据结构：`Object[]`。  
  
默认数组容量：10。  
  
扩容方案：构造函数传入的参数`capacityIncrement`大于0，则当前长度 + `capacityIncrement`；等于0，则当前长度 * 2。所以是用户可控的扩容方案。  
  
和`ArrayList`的区别在于`add`、`remove`、`get`、`set`、`contains`、`iterator`等均是`synchonized`方法。  
  
迭代器遍历：参见`ArrayList`部分。  
  
###### 4.Stack
> 截取一段源码注释吧，我什么都不说了，只说一点`Stack`继承`Vector`
  
```java
/*
...
* <p>A more complete and consistent set of LIFO stack operations is
* provided by the {@link Deque} interface and its implementations, which
* should be used in preference to this class.  For example:
* <pre>   {@code
*   Deque<Integer> stack = new ArrayDeque<Integer>();}</pre>
*
...
*/
```
  
###### 5.HashSet
底层数据结构：`HashMap`。  
  
默认容量：16；扩容因子：0.75。  
> 源码
  
```java
...
private transient HashMap<E,Object> map;
// Dummy value to associate with an Object in the backing Map
private static final Object PRESENT = new Object();
...
/**
 * Constructs a new, empty set; the backing <tt>HashMap</tt> instance has
 * default initial capacity (16) and load factor (0.75).
 */
public HashSet() {
    map = new HashMap<>();
}
...
```
  
`put`操作：向`HashMap`添加`Key-Value`，其中`Value`为占位对象`PRESENT`。
> 源码
  
```java
public boolean add(E e) {
	return map.put(e, PRESENT)==null;
}
```
  
`remove`操作
> 源码
  
```java
public boolean remove(Object o) {
    return map.remove(o)==PRESENT;
}
```
  
`contains`操作
> 源码
  
```java
public boolean contains(Object o) {
    return map.containsKey(o);
}
```
  
没有`get`操作，只能通过`iterator`实现获取操作
> 源码
  
```java
public Iterator<E> iterator() {
    return map.keySet().iterator();
}
```
  
###### 6.TreeSet
`TreeSet`和`HashSet`的主要不同在于`TreeSet`对排序的支持。  
  
底层数据结构：`TreeMap`。  
> 源码
  
```java
public TreeSet() {
    this(new TreeMap<E,Object>());
}
```
  
`put`、`remove`、`iterator`：类同于`HashSet`部分。  
  
`TreeSet`增加了对排序方面的支持：比如可指定`Comparator`实现（其实也是设置的`TreeMap`）。  
  
###### 7.LinkedHashSet
忽悠人的家货，直接继承`HashSet`，然后啥新特性都没有，叫`Linked`就是忽悠人。  

###### 8.HashMap
底层数据结构：数组+单向链表（用于解决hash碰撞，链表法）。
  
初始容量`16`,负载因子`0.75`（用于扩容）；其中数组大小只能是2的幂。  
> 源码
  
```java
...
/**
 * The table, resized as necessary. Length MUST Always be a power of two.
 */
transient Entry<K,V>[] table;
...
static class Entry<K,V> implements Map.Entry<K,V> {
    final K key;
    V value;
    Entry<K,V> next;
    int hash;
    ...
}
...
/**
 * Constructs an empty <tt>HashMap</tt> with the default initial capacity
 * (16) and the default load factor (0.75).
 */
public HashMap() {
    this(DEFAULT_INITIAL_CAPACITY, DEFAULT_LOAD_FACTOR);
}
...
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " +
                                           initialCapacity);
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " +
                                           loadFactor);

    // Find a power of 2 >= initialCapacity
    int capacity = 1;
    while (capacity < initialCapacity)
        capacity <<= 1;

    this.loadFactor = loadFactor;
    threshold = (int)Math.min(capacity * loadFactor, MAXIMUM_CAPACITY + 1);
    table = new Entry[capacity];
    useAltHashing = sun.misc.VM.isBooted() &&
            (capacity >= Holder.ALTERNATIVE_HASHING_THRESHOLD);
    init();
}
...
```
  
`put(key, value)`操作：如果`key`为空，取`table[0]`元素进行替换/插入；如果`key`不为空，对`key`两次`hash`，获取存储位置，取出存储位置元素进行替换/插入。插入前需要进行`扩容判断`。  
> 源码
  
```java
...
public V put(K key, V value) {
    if (key == null)
        return putForNullKey(value);
    int hash = hash(key);
    int i = indexFor(hash, table.length);
    for (Entry<K,V> e = table[i]; e != null; e = e.next) {
        Object k;
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }

    modCount++;
    addEntry(hash, key, value, i);
    return null;
}
...
private V putForNullKey(V value) {
    for (Entry<K,V> e = table[0]; e != null; e = e.next) {
        if (e.key == null) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }
    modCount++;
    addEntry(0, null, value, 0);
    return null;
}
...
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
...
static int indexFor(int h, int length) {
    return h & (length-1);
}
...
void addEntry(int hash, K key, V value, int bucketIndex) {
    if ((size >= threshold) && (null != table[bucketIndex])) {
        resize(2 * table.length);
        hash = (null != key) ? hash(key) : 0;
        bucketIndex = indexFor(hash, table.length);
    }

    createEntry(hash, key, value, bucketIndex);
}
...
void createEntry(int hash, K key, V value, int bucketIndex) {
    Entry<K,V> e = table[bucketIndex];
    table[bucketIndex] = new Entry<>(hash, key, value, e);
    size++;
}
...
```
  
`get(key)`、`remove(key)`、`containsKey(key)`操作：都包含两次`hash`操作，单向链表遍历操作，具体参考`put`操作，在此不贴源码。  
  
`keySet()`：返回`HashMap`中`key`集合，最常用来做迭代器遍历。  
> 源码
  
```java
...
public Set<K> keySet() {
    Set<K> ks = keySet;
    return (ks != null ? ks : (keySet = new KeySet()));
}

private final class KeySet extends AbstractSet<K> {
    public Iterator<K> iterator() {
        return newKeyIterator();
    }
    public int size() {
        return size;
    }
    public boolean contains(Object o) {
        return containsKey(o);
    }
    public boolean remove(Object o) {
        return HashMap.this.removeEntryForKey(o) != null;
    }
    public void clear() {
        HashMap.this.clear();
    }
}
...
```
  
`values()`：返回`HashMap`中`value`集合，也是常用来做迭代器遍历。  
> 源码
  
```java
public Collection<V> values() {
    Collection<V> vs = values;
    return (vs != null ? vs : (values = new Values()));
}

private final class Values extends AbstractCollection<V> {
    public Iterator<V> iterator() {
        return newValueIterator();
    }
    public int size() {
        return size;
    }
    public boolean contains(Object o) {
        return containsValue(o);
    }
    public void clear() {
        HashMap.this.clear();
    }
}
```
  
`entrySet()`：返回`HashMap`中`key-value`集合，也是常用来做迭代器遍历。  
> 源码
  
```java
public Set<Map.Entry<K,V>> entrySet() {
    return entrySet0();
}

private Set<Map.Entry<K,V>> entrySet0() {
    Set<Map.Entry<K,V>> es = entrySet;
    return es != null ? es : (entrySet = new EntrySet());
}

private final class EntrySet extends AbstractSet<Map.Entry<K,V>> {
    public Iterator<Map.Entry<K,V>> iterator() {
        return newEntryIterator();
    }
    public boolean contains(Object o) {
        if (!(o instanceof Map.Entry))
            return false;
        Map.Entry<K,V> e = (Map.Entry<K,V>) o;
        Entry<K,V> candidate = getEntry(e.getKey());
        return candidate != null && candidate.equals(e);
    }
    public boolean remove(Object o) {
        return removeMapping(o) != null;
    }
    public int size() {
        return size;
    }
    public void clear() {
        HashMap.this.clear();
    }
}
```
  
其中上文三个操作`keySet`、`values`、`entrySet`，返回的迭代器均是继承至`HashIterator`，通过修改`next()`返回对应的数据（key、value、entry）。  
  
扩容操作：也就是常说的rehash，新建entry数组，然后遍历老数组entry对象，进行put。注意如果发生hash碰撞，entry对象添加在单链表的头部。多线程环境下，这里可能会导致`get`操作死循环，CPU直接跑满！[传送门](./简单说说HashMap，HashTable，ConcurrentHashTable.md)  
> 源码
  
```java
void resize(int newCapacity) {
    Entry[] oldTable = table;
    int oldCapacity = oldTable.length;
    if (oldCapacity == MAXIMUM_CAPACITY) {
        threshold = Integer.MAX_VALUE;
        return;
    }

    Entry[] newTable = new Entry[newCapacity];
    boolean oldAltHashing = useAltHashing;
    useAltHashing |= sun.misc.VM.isBooted() &&
            (newCapacity >= Holder.ALTERNATIVE_HASHING_THRESHOLD);
    boolean rehash = oldAltHashing ^ useAltHashing;
    transfer(newTable, rehash);
    table = newTable;
    threshold = (int)Math.min(newCapacity * loadFactor, MAXIMUM_CAPACITY + 1);
}

void transfer(Entry[] newTable, boolean rehash) {
    int newCapacity = newTable.length;
    for (Entry<K,V> e : table) {
        while(null != e) {
            Entry<K,V> next = e.next;
            if (rehash) {
                e.hash = null == e.key ? 0 : hash(e.key);
            }
            int i = indexFor(e.hash, newCapacity);
            e.next = newTable[i];
            newTable[i] = e;
            e = next;
        }
    }
}
```
  
###### 9.HashTable
底层数据结构：和`HashMap`一样，数组+单向链表（用于解决hash碰撞，链表法）。  
  
和`Vector`问题一样，为了线程安全，同步锁粒度太大，不推荐用了！  
> 一段JDK文档注释
  
```java
/*
...
* <p>As of the Java 2 platform v1.2, this class was retrofitted to
* implement the {@link Map} interface, making it a member of the
* <a href="{@docRoot}/../technotes/guides/collections/index.html">
*
* Java Collections Framework</a>.  Unlike the new collection
* implementations, {@code Hashtable} is synchronized.  If a
* thread-safe implementation is not needed, it is recommended to use
* {@link HashMap} in place of {@code Hashtable}.  If a thread-safe
* highly-concurrent implementation is desired, then it is recommended
* to use {@link java.util.concurrent.ConcurrentHashMap} in place of
* {@code Hashtable}.
...
*/
```
  
###### 10.TreeMap
底层数据结构：红黑树。  
> 源码
  
```java
...
private transient Entry<K,V> root = null;
...
static final class Entry<K,V> implements Map.Entry<K,V> {
    K key;
    V value;
    Entry<K,V> left = null;
    Entry<K,V> right = null;
    Entry<K,V> parent;
    boolean color = BLACK;

    /**
     * Make a new cell with given key, value, and parent, and with
     * {@code null} child links, and BLACK color.
     */
    Entry(K key, V value, Entry<K,V> parent) {
        this.key = key;
        this.value = value;
        this.parent = parent;
    }
    ...
}
...
```
  
重点留意一下`put(key, value)`操作：就是单纯的一个红黑树插入操作。从插入操作可以看出，对于`TreeMap`要么传入`Comparator`对象，要么`key`实现`Comparable`接口。  
> 源码
  
```java
public V put(K key, V value) {
    Entry<K,V> t = root;
    if (t == null) {
        compare(key, key); // type (and possibly null) check

        root = new Entry<>(key, value, null);
        size = 1;
        modCount++;
        return null;
    }
    int cmp;
    Entry<K,V> parent;
    // split comparator and comparable paths
    Comparator cpr = comparator;
    if (cpr != null) {
        do {
            parent = t;
            cmp = cpr.compare(key, t.key);
            if (cmp < 0)
                t = t.left;
            else if (cmp > 0)
                t = t.right;
            else
                return t.setValue(value);
        } while (t != null);
    }
    else {
        if (key == null)
            throw new NullPointerException();
        Comparable k = (Comparable) key;
        do {
            parent = t;
            cmp = k.compareTo(t.key);
            if (cmp < 0)
                t = t.left;
            else if (cmp > 0)
                t = t.right;
            else
                return t.setValue(value);
        } while (t != null);
    }
    Entry<K,V> e = new Entry<>(key, value, parent);
    if (cmp < 0)
        parent.left = e;
    else
        parent.right = e;
    fixAfterInsertion(e);	// 红黑树恢复操作
    size++;
    modCount++;
    return null;
}
```
  
`get(key)`操作：典型的红黑树查找。  
  
`remove(key)`操作：先get到entry，然后再调用delete删除entry。需参考红黑树删除，后续补充。  
  
`containsKey(key)`操作：参见`get`操作。  
  
`keySet()`、`values()`、`entrySet()`操作：用于迭代器遍历时，返回的迭代器`iterator`都是用`getFirstEntry()`初始化（_遍历从第一个节点开始_），对应都继承于抽象内部类`PrivateEntryIterator`。  
> 源码
  
```java
...
final class EntryIterator extends PrivateEntryIterator<Map.Entry<K,V>> {
    EntryIterator(Entry<K,V> first) {
        super(first);
    }
    public Map.Entry<K,V> next() {
        return nextEntry();
    }
}

final class ValueIterator extends PrivateEntryIterator<V> {
    ValueIterator(Entry<K,V> first) {
        super(first);
    }
    public V next() {
        return nextEntry().value;
    }
}

final class KeyIterator extends PrivateEntryIterator<K> {
    KeyIterator(Entry<K,V> first) {
        super(first);
    }
    public K next() {
        return nextEntry().key;
    }
}
...
```
  
###### 11.LinkedHashMap
底层数据结构：继承`HashMap`，但是创建双链表保存`HashMap`中的`key-value`对，通过重写父类相关方法，修改双链表，目的在于迭代器遍历，输出有序（支持`插入顺序`、`访问顺序`）。  
> 源码
  
```java
private transient Entry<K,V> header;

/**
 * The iteration ordering method for this linked hash map: <tt>true</tt>
 * for access-order, <tt>false</tt> for insertion-order.
 *
 * @serial
 */
private final boolean accessOrder;
...
private static class Entry<K,V> extends HashMap.Entry<K,V> {
    // These fields comprise the doubly linked list used for iteration.
    Entry<K,V> before, after;
    ...
}
```
  
`put`操作：`LinkedHashMap`重写了`addEntry`、`createEntry`方法，其中在`createEntry`中会修改双向链表，将最新加入的`entry`放置于`header`之前；在`addEntry`中会根据是否允许删除`最旧`元素，进行删除操作（是不是可以想到用它来实现`LRU缓存`）。  
> 源码
  
```java
void addEntry(int hash, K key, V value, int bucketIndex) {
    super.addEntry(hash, key, value, bucketIndex);

    // Remove eldest entry if instructed
    Entry<K,V> eldest = header.after;
    if (removeEldestEntry(eldest)) {
        removeEntryForKey(eldest.key);
    }
}

void createEntry(int hash, K key, V value, int bucketIndex) {
    HashMap.Entry<K,V> old = table[bucketIndex];
    Entry<K,V> e = new Entry<>(hash, key, value, old);
    table[bucketIndex] = e;
    e.addBefore(header);
    size++;
}
```
  
> 插入新元素，双向链表修改如图
  
<center>![img text](../img/Java一二04.png "链表修改")</center>
  
`get`操作：和`HashMap`操作一致，区别在于，在`LinkedHashMap`初始化时如果设置`accessOrder`，则修改双向链表，移动访问项到`header`前一个位置，可参见上图。  
  
遍历操作：支持`keySet`、`values`、`entrySet`，均是基于内部类`LinkedHashIterator`，遍历顺序根据双向链表顺序来，遍历起点为`header.after`。  
> 源码
  
```java
private abstract class LinkedHashIterator<T> implements Iterator<T> {
    Entry<K,V> nextEntry    = header.after;
    Entry<K,V> lastReturned = null;
    ...
}

private class KeyIterator extends LinkedHashIterator<K> {
    public K next() { return nextEntry().getKey(); }
}

private class ValueIterator extends LinkedHashIterator<V> {
    public V next() { return nextEntry().value; }
}

private class EntryIterator extends LinkedHashIterator<Map.Entry<K,V>> {
    public Map.Entry<K,V> next() { return nextEntry(); }
}
```
  
###### 12.对上面的总结
上文描述容器类，都不是线程安全的，多线程环境下涉及迭代器遍历都可能发生`fast-fail`错误。如何实现线程安全的支持？  
  
一种方式是，`Collections`类包含相当多的静态方法，用于把上述容器类封装为线程安全的容器类，比如`synchronizedMap`、`unmodifiableMap`。`synchronizedMap`是对读写操作加同步锁，`unmodifiableMap`直接只许读不许写。  
> 源码
  
```java
public static <K,V> Map<K,V> synchronizedMap(Map<K,V> m) {
    return new SynchronizedMap<>(m);
}

private static class SynchronizedMap<K,V> implements Map<K,V>, Serializable {
    ...
    public V get(Object key) {
        synchronized (mutex) {return m.get(key);}
    }
    public V put(K key, V value) {
        synchronized (mutex) {return m.put(key, value);}
    }
    public V remove(Object key) {
        synchronized (mutex) {return m.remove(key);}
    }
    public void clear() {
        synchronized (mutex) {m.clear();}
    }
    ...
}
```
  
`Collections`类中含有`SynchroniezdList`、`SynchroniezdSet`、`SynchroniezdMap`、`UnmodifiableList`、`UnmodifiableSet`、`UnmodifiableMap`等。可以看出这样的`锁粒度`是很大的，直接对集合`整体加锁`，通常性能在高并发时下降迅速。  
  
那么高并发场合，有哪些专用集合类呢？下文分解。  
  
#### Java IO

#### Java并发


---
#### 书籍列表
1. [深入理解Java虚拟机][1]

[1]: http://book.douban.com/subject/24722612/
