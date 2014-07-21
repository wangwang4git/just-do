## Android开发-应用优化

Android应用优化，涉及的范围挺广的，这里推荐一本挺薄的书[《Android应用性能优化》][1]，网上有电子版。  
  
我想就自己的开发经历，讲讲优化，对自己也算是个复习梳理。  
  

Android程序优化，应该是涉及三个层次的：其一，Java语言层面通用的优化；其二，Android开发层面通用的优化；其三，应用内热点的优化。  
  
#### Java语言通用优化
###### 1. 容器按需选择
  
Java和Android定义了许多容器，需要你有一定的经验去选择最适合当前场景的容器。  
  
比如并发场景下，你需要一个`HashMap`，你有两种选择`Collections.synchronizedMap`，`ConcurrentHashMap`，但显然后一种效率要高。  
  
再比如，你要自己构建一个LRU缓存，显然用Android提供的`LruCache`更好。  
  
再比如，你需要实现`HashMap<Integer, E> hashMap = new HashMap<Integer, E>();`，应该考虑使用Android提供的`SparseArray<E> sparseArray = new SparseArray<E>();`。  
  
这里罗列一下Android提供的几个容器：  
  
`Pair<F, S>`  
`LruCache<K, V>`  
`SparseArray<E>`  
`SparseIntArray`  
`SparseLongArray`  
`SparseBooleanArray`  
`LongSparseArray<E>`  
`ArrayMap<K, V>`  
  
###### 2.  



---
## 参考文献
1. [《Android应用性能优化》][1]
2. [Android性能调优][2]

[1]: http://book.douban.com/subject/19976838/
[2]: http://www.trinea.cn/android/android-performance-demo/