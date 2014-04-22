## Annotation学习笔记

#### 默认的三种注解(`Java SE5`加入)
* `@Override`
* `@Deprecated`
* `@SuppressWarnings`

#### 定义注解(不支持继承)
* 元注解`meta-annotation`，负责注解其他的注解

> `@Target`  
> `@Retention`  
> `@Documented`  
> `@Inherited`  

> ![alt text](../img/Annotation01.png "元注解")  

* 注解元素

> 注解元素类型限制  
> * 所有基本类型（int，float，boolean等）  
> * String  
> * Class  
> * enum  
> * Annotation，嵌套注解  
> * 以上类型的数组  

> 默认值限制  
> * 元素要么有默认值，要么在使用时提供初始值，不允许空值

* 定义注解示例

> 示例选取：定义基本的对象/关系映射功能，能够自动生成数据库表  

```java
	// 用于表名称注解
	@Target(ElementType.TYPE)
	@Retention(RetentionPolicy.RUNTIME)
	public @interface DBTable {
    	public String name() default "";
	}
    
    // 用于表列约束注解
    @Target(ElementType.FIELD)
    @Retention(RetentionPolicy.RUNTIME)
    public @interface Constraints {
        public boolean primaryKey() default false;
    
        public boolean allowNull() default true;
    
        public boolean unique() default false;
    }
    
    // 用于表列类型注解
    @Target(ElementType.FIELD)
    @Retention(RetentionPolicy.RUNTIME)
    public @interface SQLString {
        public int value() default 0;
    
        public String name() default "";
    
        public Constraints constraints() default @Constraints;
    }
    
    // 用于表列类型注解
    @Target(ElementType.FIELD)
    @Retention(RetentionPolicy.RUNTIME)
    public @interface SQLInteger {
        public String name() default "";
    
        public Constraints constraints() default @Constraints;
    }
```

* 使用注解

> 基于上述示例
> 元素赋值快捷方式，如果元素名为`value`，在应用该注解时，该元素为唯一需要赋值的元素

```java
    @DBTable(name = "MEMBER")
    public class Member {
    
        @SQLString(30)
        public String firstName;
        @SQLString(30)
        public String lastName;
        @SQLInteger
        public Integer age;
        @SQLString(value = 30, constraints = @Constraints(primaryKey = true))
        public String handle;
    
        public static int memberCount;
    
        public String getFirstName() {
            return firstName;
        }
    
        public String getLastName() {
            return lastName;
        }
    
        public Integer getAge() {
            return age;
        }
    
        public String getHandle() {
            return handle;
        }
    
        @Override
        public String toString() {
            return handle;
        }
    
    }
```

* 实现注解处理器

> 基于上述示例，实现的注解处理器示例

```java
    public class TableCreator {
    
        /**
         * @param args
         * @throws ClassNotFoundException
         */
        public static void main(String[] args) throws ClassNotFoundException {
            // TODO Auto-generated method stub
    
            if (args.length < 1) {
                System.out.println("arguments:annotated classes");
                System.exit(0);
            }
    
            for (String className : args) {
                Class<?> cl = Class.forName(className);
    
                DBTable dbTable = cl.getAnnotation(DBTable.class);
                if (dbTable == null) {
                    System.out.println("No DBTable annotation in class "
                            + className);
                    continue;
                }
                String tableName = dbTable.name();
                if (tableName.length() < 1) {
                    tableName = cl.getName().toUpperCase();
                }
    
                List<String> columnDefs = new ArrayList<String>();
    
                for (Field field : cl.getDeclaredFields()) {
                    String columnName = null;
                    Annotation[] anns = field.getAnnotations();
                    if (anns.length < 1) {
                        continue;
                    }
                    if (anns[0] instanceof SQLInteger) {
                        SQLInteger sInt = (SQLInteger) anns[0];
                        if (sInt.name().length() < 1) {
                            columnName = field.getName().toUpperCase();
                        } else {
                            columnName = sInt.name();
                        }
    
                        columnDefs.add(columnName + " INT"
                                + getConstraints(sInt.constraints()));
                    }
    
                    if (anns[0] instanceof SQLString) {
                        SQLString sString = (SQLString) anns[0];
                        if (sString.name().length() < 1) {
                            columnName = field.getName().toUpperCase();
                        } else {
                            columnName = sString.name();
                        }
    
                        columnDefs.add(columnName + " VARCHAR(" + sString.value()
                                + ")" + getConstraints(sString.constraints()));
                    }
                }
    
                StringBuilder createCommand = new StringBuilder("CREATE TABLE "
                        + tableName + "(");
                for (String columnsDef : columnDefs) {
                    createCommand.append("\n\t" + columnsDef + ",");
                }
                String tableCreate = createCommand.substring(0,
                        createCommand.length() - 1)
                        + ");";
                System.out.println("Table Creation SQL for " + className + " is:\n"
                        + tableCreate);
    
            }
        }
    
        private static String getConstraints(Constraints con) {
            String constraints = "";
            
            if (!con.allowNull()) {
                constraints += " NOT NULL";
            }
            if (con.primaryKey()) {
                constraints += " PRIMARY KEY";
            }
            if (con.unique()) {
                constraints += " UNIQUE";
            }
    
            return constraints;
        }
    
    }
```

