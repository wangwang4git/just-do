## Java基本功不牢造成的那些似坑非坑

##### `Java`中的变量要么是对象的引用，要么是基础类型

> 那么对于不可变`String`类  

```java
    String s = "Hello";
    s += "World!";
```

> 重新构造新`String`对象，同时修改引用`s`  

##### `==`比较变量存储的值，对于基本类型比较基本类型值，对于引用比较引用值

> 可是`JVM`中的对象池技术会让引用比较有点混乱  

```java
    String s1 = "Hi", s2 = "Hi";
    Integer a = 12, b = 12;
    String s3 = new String(s1);
    Integer c = -222, d = -222;
  
    s1 == s2;  // true，对象池优化导致
    s1 ==  s3;  // false
    s1.equals(s3);  // true
    a == b;  // true，对象池优化导致
    c == d;  // false，Integer对象池缓存范围-128~127
    c.equals(d);  // true
```

##### `Object.hashCode`生成的值，看起来像地址，但是与地址没啥关系

##### `Object.toString`默认行为是输出`类名`+`hashCode`
> 对于数组  

```java
	String[] words = {"Hello", "World"};
    System.out.println(words);
```

> 输出`[Ljava.lang.String;@1ce08c7`  
> 如果要输出数组内容，就需要借助类`Arrays`  

```java
	System.out.println(Arrays.toString(words));
```

> 但是这样显然破坏了`OOP`的原则  

##### TODO...

