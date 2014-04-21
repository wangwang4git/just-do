## Android ContentProvider入门

#### 基础
* `ContentProvider`是Android提供的一种数据访问抽象机制，封装实际的数据访问机制，比如`Sqlite3`
* 用于应用间数据共享
* Android提供了哪些`ContentProvider`，[参见][1]
* `ContentProvider`类似于以下业内抽象机制
> 网站，具有唯一URI，在`Manifest`文件中授权，`ContentProvider`注册表  
> REST，数据获取和操作，类似于REST的URL风格  
> Web服务，通过URI将内部数据公开为服务，输出数据类型由`Android MIME`描述，`Android MIME`类型，包含两部分，类型和子类型  
> 存储过程，对`ContentProvider`的URI调用将返回一个`Cursor`  
* 每一个`ContentProvider`对应一个`Sqlite3`数据库，其中对应到Android Java层面就是一个Class，每一个`Sqlite3`数据库表存储具体的数据，对应到Android Java层面就是上述Class的内部类(Nested Class)，其中每一个内部类对应一个内部接口(Nested Interface)，用于描述该表的列结构
> 例如：`android.provider.Contacts`--`android.provider.Contacts.People`--`android.provider.Contacts.PeopleColumns`

### 注意

* `where`子句注意点：两种方式，一种通过`URI`传递where子句，另一种使用`显示`where子句
* 将文件插入到`ContentProvider`中，插入操作返回`uri`，根据`uri`获取输出流，文件写入输出流，系统自动将文件引用存入`_data`列

### 实现

* 第一步，设计`数据库`，`表结构`，编写`元数据`类，其中`元数据`类包括`ContentProvider`的`Authority`信息，数据库表对应内部类`column`描述信息

```java
public class BookProviderMetaData {

    public static final String AUTHORITY = "com.androidbook.provider.BookProvider";

    public static final String DATABASE_NAME = "book.db";
    public static final int DATABASE_VERSION = 1;

    public static final String BOOKS_TABLE_NAME = "books";

    private BookProviderMetaData() {
    }

    public static final class BookTableMetaData implements BaseColumns {

        public static final String TABLE_NAME = "books";

        public static final Uri CONTENT_URI = Uri.parse("content://" + AUTHORITY + "/books");

        public static final String CONTENT_TYPE = "vnd.android.cursor.dir/vnd.androidbook.book";
        public static final String CONTENT_ITEM_TYPE = "vnd.android.cursor.item/vnd.androidbook.book";

        public static final String DEFAULT_SORT_ORDER = "modified DESC";

        // columns
        // String
        public static final String BOOK_NAME = "name";

        // String
        public static final String BOOK_ISBN = "isbn";

        // String
        public static final String BOOK_AUTHOR = "author";

        // Integer
        public static final String CREATED_DATE = "created";

        // Integer
        public static final String MODIFIED_DATE = "modified";

    }

}
```

* 第二步，实现数据库`helper`类

```java
    private class DatabaseHelper extends SQLiteOpenHelper {

        public DatabaseHelper(Context context) {
            super(context, BookProviderMetaData.DATABASE_NAME, null, BookProviderMetaData.DATABASE_VERSION);
        }

        @Override
        public void onCreate(SQLiteDatabase sqLiteDatabase) {
            Log.i(TAG, "inner onCreate() called");
            sqLiteDatabase.execSQL("CREATE TABLE " + BookProviderMetaData.BookTableMetaData.BOOK_NAME + " ("
                    + BookProviderMetaData.BookTableMetaData._ID + " INTEGER PRIMARY KEY,"
                    + BookProviderMetaData.BookTableMetaData.BOOK_NAME + " TEXT,"
                    + BookProviderMetaData.BookTableMetaData.BOOK_ISBN + " TEXT,"
                    + BookProviderMetaData.BookTableMetaData.BOOK_AUTHOR + " TEXT,"
                    + BookProviderMetaData.BookTableMetaData.CREATED_DATE + " INTEGER,"
                    + BookProviderMetaData.BookTableMetaData.MODIFIED_DATE + " INTEGER"
                    + ");");
        }

        @Override
        public void onUpgrade(SQLiteDatabase sqLiteDatabase, int i, int i2) {
            Log.i(TAG, "inner onUpgrade() called");
            Log.w(TAG, "upgrading database from version " + i + " to " + i2 + ", which will destroy all old data");
            sqLiteDatabase.execSQL("DROP TABLE IF EXISTS " + BookProviderMetaData.BookTableMetaData.BOOK_NAME);
            onCreate(sqLiteDatabase);
        }
    }
```

* 第三步，实现自己的`contentprovider`类

```java
do to list...

```

### 参考
1. [ContentProvider和Uri详解][2]

[1]: http://developer.android.com/intl/zh-cn/reference/android/provider/package-summary.html "content provider"
[2]: http://www.cnblogs.com/linjiqin/archive/2011/05/28/2061396.html "ContentProvider和Uri详解"