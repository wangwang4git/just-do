## Android SurfaceView入门

#### 对比View优势
* 大概最大的优势是，`view`绘制在UI线程，即`onDraw`函数在主线程执行，而`SurfaceView`的绘制操作可以放在自定义的任意子线程

#### MVC
* 要完成`SurfaceView`的绘制工作，依赖于`SurfaceHolder`相关回调函数，其中`SurfaceView`包含`MyWindow`类型的成员`mWindow`
* 在这里，我们认为`SurfaceView`是`View`，`SurfaceHolder`是`Controller`，`Surface`是`Model`

#### 实现
* 既然`SurfaceView`的最大优势是允许非UI线程绘制，那么实现过程中肯定要编写相关的子线程绘制操作
* 子线程部分

```java
    public class MyThread extends Thread {
    
        private SurfaceHolder mSurfaceHolder;
        private boolean mRun;
    
        public boolean isRun() {
            return mRun;
        }
    
        public void setRun(boolean mRun) {
            this.mRun = mRun;
        }
    
        public MyThread(SurfaceHolder mSurfaceHolder) {
            this.mSurfaceHolder = mSurfaceHolder;
        }
    
        @Override
        public void run() {
            super.run();
    
            Canvas canvas;
    
            while (mRun) {
    
                canvas = mSurfaceHolder.lockCanvas();
    
                canvas.drawColor(Color.YELLOW);
    
                Paint paint = new Paint();
                paint.setColor(Color.RED);
                paint.setTextSize(20.0f);
                Rect rect = new Rect(10, 10, 200, 200);
                String text = "hello world!";
    
                canvas.drawRect(rect, paint);
                canvas.drawText(text, 100, 300, paint);
    
    
                mSurfaceHolder.unlockCanvasAndPost(canvas);
            }
        }
    }
```
* SurfaceView部分

```java
    public class MySurfaceView extends SurfaceView implements SurfaceHolder.Callback {
    
        private MyThread mMyThread;
        private SurfaceHolder mSurfaceHolder;
    
        public MySurfaceView(Context context) {
            super(context);
            init();
        }
    
        public MySurfaceView(Context context, AttributeSet attrs) {
            super(context, attrs);
            init();
        }
    
        public MySurfaceView(Context context, AttributeSet attrs, int defStyle) {
            super(context, attrs, defStyle);
            init();
        }
    
        private void init() {
            mSurfaceHolder = getHolder();
            mSurfaceHolder.addCallback(this);
            mMyThread = new MyThread(mSurfaceHolder);
        }
    
        @Override
        public void surfaceCreated(SurfaceHolder surfaceHolder) {
            mMyThread.setRun(true);
            mMyThread.start();
        }
    
        @Override
        public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i2, int i3) {
    
        }
    
        @Override
        public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
            mMyThread.setRun(false);
        }
}
```
