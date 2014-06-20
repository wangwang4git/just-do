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

2. Sepia`回忆`

* [灰度变换][6]
> 魔法数字：`0.21R + 0.72G + 0.07B`  
> 查表

	````c
    const float3 luminosity = {0.21f, 0.72f, 0.07f};
    const uint8_t sepiaRedLut[256] = {24, 24, 25, 26, 27, 28, 29, 30, 30, 30, 31, 32, 33, 34, 35,
           36, 37, 37, 38, 38, 39, 40, 41, 42, 43, 43, 44, 45, 46, 47, 47, 48, 49, 50, 50, 51, 52, 53,
           54, 55, 56, 57, 57, 58, 58, 59, 60, 61, 62, 63, 64, 64, 65, 66, 67, 68, 69, 70, 71, 71, 72,
           72, 73, 74, 75, 76, 77, 78, 78, 79, 80, 81, 82, 83, 84, 85, 85, 86, 87, 88, 89, 89, 90, 91,
           92, 93, 93, 94, 95, 96, 97, 97, 98, 99, 100, 101, 102, 102, 103, 104, 105, 106, 107, 108,
           109, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 118, 119, 120, 121, 122, 123, 124,
           125, 126, 127, 128, 129, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141,
           142, 143, 144, 145, 146, 146, 147, 148, 149, 150, 151, 152, 153, 153, 154, 155, 156, 157,
           158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
           176, 177, 178, 178, 180, 181, 182, 183, 184, 185, 186, 186, 187, 188, 189, 190, 191, 193,
           194, 195, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
           211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228,
           229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246,
           247, 248, 249, 250, 251, 252, 253, 255};
    const uint8_t sepiaGreenLut[256] = {16, 16, 16, 17, 18, 18, 19, 20, 20, 20, 21, 22, 22, 23,
           24, 24, 25, 25, 26, 26, 27, 28, 28, 29, 30, 30, 31, 31, 32, 33, 33, 34, 35, 36, 36, 36, 37,
           38, 39, 39, 40, 41, 42, 43, 43, 44, 45, 46, 47, 47, 48, 48, 49, 50, 51, 51, 52, 53, 54, 54,
           55, 55, 56, 57, 58, 59, 60, 61, 61, 61, 62, 63, 64, 65, 66, 67, 67, 68, 68, 69, 70, 72, 73,
           74, 75, 75, 76, 77, 78, 78, 79, 80, 81, 81, 82, 83, 84, 85, 86, 87, 88, 90, 90, 91, 92, 93,
           94, 95, 96, 97, 97, 98, 99, 100, 101, 103, 104, 105, 106, 106, 107, 108, 109, 110, 111, 112,
           113, 114, 115, 116, 117, 118, 119, 120, 122, 123, 123, 124, 125, 127, 128, 129, 130, 131,
           132, 132, 134, 135, 136, 137, 138, 139, 141, 141, 142, 144, 145, 146, 147, 148, 149, 150,
           151, 152, 154, 155, 156, 157, 158, 160, 160, 161, 162, 163, 165, 166, 167, 168, 169, 170,
           171, 173, 174, 175, 176, 177, 178, 179, 180, 182, 183, 184, 185, 187, 188, 189, 189, 191,
           192, 193, 194, 196, 197, 198, 198, 200, 201, 202, 203, 205, 206, 207, 208, 209, 210, 211,
           212, 213, 215, 216, 217, 218, 219, 220, 221, 223, 224, 225, 226, 227, 228, 229, 230, 231,
           232, 233, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250,
           251, 252, 253, 255};
     const uint8_t sepiaBlueLut[256] = {5, 5, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 9, 10, 10, 11, 11,
           11, 11, 12, 12, 13, 13, 14, 14, 14, 14, 15, 15, 16, 16, 17, 17, 17, 18, 18, 19, 20, 20, 21,
           21, 21, 22, 22, 23, 23, 24, 25, 25, 26, 27, 28, 28, 29, 29, 30, 31, 31, 31, 32, 33, 33, 34,
           35, 36, 37, 38, 38, 39, 39, 40, 41, 42, 43, 43, 44, 45, 46, 47, 47, 48, 49, 50, 51, 52, 53,
           53, 54, 55, 56, 57, 58, 59, 60, 60, 61, 62, 63, 65, 66, 67, 67, 68, 69, 70, 72, 73, 74, 75,
           75, 76, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 90, 91, 92, 93, 93, 95, 97, 98, 99, 100,
           101, 102, 104, 104, 106, 107, 108, 109, 111, 112, 114, 115, 115, 117, 118, 120, 121, 122,
           123, 124, 125, 127, 128, 129, 131, 132, 133, 135, 136, 137, 138, 139, 141, 142, 144, 145,
           147, 147, 149, 150, 151, 153, 154, 156, 157, 159, 159, 161, 162, 164, 165, 167, 168, 169,
           170, 172, 173, 174, 176, 177, 178, 180, 181, 182, 184, 185, 186, 188, 189, 191, 192, 193,
           194, 196, 197, 198, 200, 201, 203, 204, 205, 206, 207, 209, 210, 211, 213, 214, 215, 216,
           218, 219, 220, 221, 223, 224, 225, 226, 227, 229, 230, 231, 232, 234, 235, 236, 237, 238,
           239, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 255};
    
    void sepiaFilterKernel(const uchar4 *in, uchar4 *out) {
        float3 f3 = {in->x, in->y, in->z};
        float f = dot(f3, luminosity);
        out->x = sepiaRedLut[(uint8_t)f];
        out->y = sepiaGreenLut[(uint8_t)f];
        out->z = sepiaBlueLut[(uint8_t)f];
    }
    ````


#### TIDOLIST
1.  


#### 参考文献
1. [只需 4 步，手把手教你如何实现滤镜功能][1]
2. [Instagram 是用什么语言编写的？为什么它的图片滤镜效果那么出众？][2]
3. [PhotoProcessing][3]
4. [gamma原理及快速实现算法（C/C++)][4]
5. [颜色直方图均衡化][5]
6. [Three algorithms for converting color to grayscale][6]

[1]: http://zihua.li/2014/06/implement-instagram-like-filters
[2]: http://www.zhihu.com/question/20242095
[3]: https://github.com/lightbox/PhotoProcessing
[4]: http://blog.csdn.net/lxy201700/article/details/24929013
[5]: http://blog.csdn.net/gxiaob/article/details/9824487
[6]: http://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
