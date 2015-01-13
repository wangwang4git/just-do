#### Android Sqlite3 Corruption学习

1. 接口[`DatabaseErrorHandler `][1]

2. final 类[`DefaultDatabaseErrorHandler`][2]
调用`SQLiteDatabase`如下函数，配置`DatabaseErrorHandler`的实现，如果为null，默认采用`DefaultDatabaseErrorHandler`
```java
SQLiteDatabase openOrCreateDatabase(String, android.database.sqlite.SQLiteDatabase.CursorFactory, DatabaseErrorHandler)
SQLiteDatabase openDatabase(String, android.database.sqlite.SQLiteDatabase.CursorFactory, int, DatabaseErrorHandler)
```

3. 异常[`SQLiteDatabaseCorruptException`][3]
标识sqlite3数据库文件污染

4. 应用内需要捕获`SQLiteDatabaseCorruptException`实现自定义行为
定义`DatabaseErrorHandler `子类；  
定义`SQLiteOpenHelper`子类，调用父类构造函数传递自定义`DatabaseErrorHandler `；  
自定义`DatabaseErrorHandler `子类，参考`DefaultDatabaseErrorHandler`[源码][4]。

5. 导致数据库文件`corrupt`原因，[参考][5]
  * File overwrite by a rogue thread or process
> a) Continuing to use a file descriptor after it has been closed;
> b) Backup or restore while a transaction is active;
> c) Deleting a hot journal;
  * File locking problems
> a) Filesystems with broken or missing lock implementations;
> b) Posix advisory locks canceled by a separate thread doing close();
> c) Two processes using different locking protocols;
> d) Unlinking or renaming a database file while in use;
> e) Multiple links to the same file;
  * Failure to sync
> a) Disk drives that do not honor sync requests;
> b) Disabling sync using PRAGMAs;
  * Disk Drive and Flash Memory Failures
> Non-powersafe flash memory controllers;
> Fake capacity USB sticks;
  * Memory corruption
  * Other operating system problems
  * Bugs in SQLite

6. 对于API大于等于11、API小于11的差别
API小于11，压根没有`DatabaseErrorHandler`一说！！
API大于等于11，SQLiteOpenHelper[源码](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/database/sqlite/SQLiteOpenHelper.java)；  
API大于等于11，SQLiteDatabase[源码](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/database/sqlite/SQLiteDatabase.java)；  
API小于11，SQLiteDatabase[源码](https://github.com/wangwang4git/platform_frameworks_base/blob/froyo-release/core%2Fjava%2Fandroid%2Fdatabase%2Fsqlite%2FSQLiteDatabase.java)；  

[1]: http://developer.android.com/reference/android/database/DatabaseErrorHandler.html
[2]: http://developer.android.com/reference/android/database/DefaultDatabaseErrorHandler.html
[3]: http://developer.android.com/reference/android/database/sqlite/SQLiteDatabaseCorruptException.html
[4]: https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/database/DefaultDatabaseErrorHandler.java
[5]: https://www.sqlite.org/howtocorrupt.html
