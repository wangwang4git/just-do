public class Outer {

    private int i1 = 0;
    protected int i2 = 0;
    public int i3 = 0;
    int i4 = 0;

    // 内部类
    public class Inner {

        public int func() {
            return i1 + i2 + i3 + i4;
        }

    }

    // 匿名内部类
    public Inner mInner = new Inner() {
        public int func() {
            return super.func() + 10;
        }
    };

}