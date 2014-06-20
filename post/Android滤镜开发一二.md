## Android滤镜开发一二

#### 滤镜开发步骤
1. 颜色映射
2. 叠加材质
3. 应用相框
4. 反复

#### 给我的滤镜英文名称取一个好听的名字
1. Instafix`色彩校正`
2. Ansel`单色`
3. Testino`强烈`
4. XPro`LOMO`
5. Retro`复古`
6. Black & White`黑白`
7. Sepia`回忆`
8. Cyano`深海`
9. Georgia`甜美`
10. Sahara`暖日`
10. HDR`反转`

#### 滤镜算法搜集
1. Instafix`色彩校正`

* [Gamma校正][4]
> 步骤：`归一化`，`预补偿`，`反归一化`

    ```c
    // 脚本变量，java层设置
    rs_allocation gammaSource;
    uint32_t gammaHeight;
    uint32_t gammaWidth;
    // 脚本内部变量，gamma校正待查表
    static int32_t redLut[256];
    static int32_t greenLut[256];
    static int32_t blueLut[256];
    
    void init() {
        for (uint32_t i = 0; i < 256; ++i) {
            redLut[i] = -1;
            greenLut[i] = -1;
            blueLut[i] = -1;
        }
    }
    
    void createGammaLut() {
        float redAverage = 0.0f, greenAverage = 0.0f, blueAverage = 0.0f;
        uint32_t n = 1;
        for (uint32_t i = 0; i < gammaHeight; ++i) {
            for (uint32_t j = 0; j < gammaWidth; ++j) {
                uchar4 in = rsGetElementAt_uchar4(gammaSource, j, i);
                redAverage = ((n - 1) * redAverage + in.r) / n;
                greenAverage = ((n - 1) * greenAverage + in.g) / n;
                blueAverage = ((n - 1) * blueAverage + in.b) / n;
                ++n;
            }
        }
    
        float gammaRed = log(128.0f / 255) / log(redAverage / 255);
        float gammaGreen = log(128.0f / 255) / log(greenAverage / 255);
        float gammaBlue = log(128.0f / 255) / log(blueAverage / 255);
        for (uint32_t i = 0; i < gammaHeight; ++i) {
            for (uint32_t j = 0; j < gammaWidth; ++j) {
                uchar4 in = rsGetElementAt_uchar4(gammaSource, j, i);
                if (redLut[in.r] == -1) {
                    redLut[in.r] = rsClamp(255.0f * pow((in.r / 255.0f), gammaRed), 0, 255);
                }
                if (greenLut[in.g] == -1) {
                    greenLut[in.g] = rsClamp(255.0f * pow((in.g / 255.0f), gammaGreen), 0, 255);
                }
                if (blueLut[in.b] == -1) {
                    blueLut[in.b] = rsClamp(255.0f * pow((in.b / 255.0f), gammaBlue), 0, 255);
                }
            }
        }
    }
    
    void gammaFilterKernel(const uchar4 *in, uchar4 *out) {
        out->r = redLut[in->r];
        out->g = greenLut[in->g];
        out->b = blueLut[in->b];
    }
    ```

* [颜色均衡][5]
> 步骤：`统计直方图（归一化）`，`累计直方图`，`计算新值`

    ```c
    rs_allocation histogramSource;
	uint32_t histogramHeight;
	uint32_t histogramWidth;
    static uint32_t histogram[3][256];

    void createHistogramLut() {
        for (uint32_t i = 0; i < histogramHeight; ++i) {
            for (uint32_t j = 0; j < histogramWidth; ++j) {
                uchar4 in = rsGetElementAt_uchar4(histogramSource, j, i);
                ++histogram[0][in.r];
                ++histogram[1][in.g];
                ++histogram[2][in.b];
            }
        }
    
        uint32_t count = histogramWidth * histogramHeight;
        for (uint32_t channel = 0; channel < 3; ++channel) {
            uint32_t low = 0;
            uint32_t high = 255;
            float percentage, nextPercentage;
    
            nextPercentage = (float) histogram[channel][0] / count;
            for (uint32_t i = 0; i < 255; ++i) {
                percentage = nextPercentage;
                nextPercentage += (float) histogram[channel][i + 1] / count;
                if (fdim(percentage, nextPercentage) > 0.006) {
                    low = i;
                    break;
                }
            }
    
            nextPercentage = (float) histogram[channel][255] / count;
            for (uint32_t i = 255; i > 0; --i) {
                percentage = nextPercentage;
                nextPercentage += (float) histogram[channel][i - 1] / count;
                if (fdim(percentage, nextPercentage) > 0.006) {
                    high = i;
                    break;
                }
            }
    
            for (uint32_t i = 0; i < low; ++i) {
                histogram[channel][i] = 0;
            }
            for (uint32_t i = 255; i > high; --i) {
                histogram[channel][i] = 255;
            }
    
            float base = 0;
            float mult = 255.0f / (high - low);
            for (uint32_t i = low; i <= high; i++) {
                histogram[channel][i] = (int) base;
                base += mult;
            }
        }
	}

    void histogramFilterKernel(const uchar4 *in, uchar4 *out) {
        out->r = histogram[0][in->r];
        out->g = histogram[1][in->g];
        out->b = histogram[2][in->b];
    }
    ```


#### TIDOLIST
1.  


#### 参考文献
1. [只需 4 步，手把手教你如何实现滤镜功能][1]
2. [Instagram 是用什么语言编写的？为什么它的图片滤镜效果那么出众？][2]
3. [PhotoProcessing][3]
4. [gamma原理及快速实现算法（C/C++)][4]
5. [颜色直方图均衡化][5]

[1]: http://zihua.li/2014/06/implement-instagram-like-filters
[2]: http://www.zhihu.com/question/20242095
[3]: https://github.com/lightbox/PhotoProcessing
[4]: http://blog.csdn.net/lxy201700/article/details/24929013
[5]: http://blog.csdn.net/gxiaob/article/details/9824487
