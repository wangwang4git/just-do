## Android WebView Java与JavaScript互调

#### Java调用JavaScript方式
* HTML中定义`JavaScript`函数
```
    <script language = "javascript">
        function add(i, j) {
            var v = i + j;
            return v;
        }
    </script>
```
* `Java`层直接调用
```
    WebSettings webSettings = mWebView.getSettings();
    webSettings.setJavaScriptEnabled(true);
	
    public void myOnClick(View view) {
        mWebView.loadUrl("javascript:add(1, 2)");
    }
```

#### JavaScript返回值
* 一种方法是定义`JavaScriptInterface`类，其中存放结果`HashMap`，然后`JavaScript`层`set`结果，`Java`层`get`结果
```
    final class MyJavaScriptInterface {
        private HashMap<String, String> mValueMap = new HashMap<String, String>();
    
        @JavascriptInterface
        public void set(String key, String value) {
            mValueMap.put(key, value);
        }
    
        @JavascriptInterface
        public String get(String key) {
            return mValueMap.get(key);
        }
    }
    
    // Javascript
    window.mywebview.set('ret', v);
    // Java
    myJavaScriptInterface.get("ret");
```
* 另一种方法是截获JavaScript`alert`函数
```
    private class MyWebChromeClient extends WebChromeClient {
        @Override
        public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
            Log.i(TAG, "ret = " + message);
            result.confirm();
            return true;
        }
    }
    mWebView.setWebChromeClient(new MyWebChromeClient());
    
    // Javascript
    <script language="javascript">
        function add(i, j) {
            var v = i + j;
            alert(v);
            return v;
        }
    </script>
```

#### JavaScript调用Java方式
* `Java`层定义`JavaScriptInterface`类
```
    WebSettings webSettings = mWebView.getSettings();
    webSettings.setJavaScriptEnabled(true);
    mWebView.addJavascriptInterface(new MyJavaScriptInterface(), "mywebview");
    mWebView.loadUrl("file:///android_asset/www/index.html");
    
    final class MyJavaScriptInterface {
        @JavascriptInterface
        public String printHello(String world) {
            return "hello " + world + "!";
        }
    }
```
> 注：Android SDK 4.2+需增加注解@JavascriptInterface

* `HTML`中编写调用代码
```
    <body>
        <p>调用java函数</p>
        <button id="print" type="button" onclick="var v = window.mywebview.printHello('world');">print</button>
    </body>
```

####Java返回值
* `java`函数返回值，直接返回给`JavaScript`变量，如上
