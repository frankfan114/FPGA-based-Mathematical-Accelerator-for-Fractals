#include <iostream>
#include <fstream>
#include <complex>
#include <chrono>

using namespace std;
using namespace std::chrono;

const int WIDTH = 800;        // 图像宽度
const int HEIGHT = 800;       // 图像高度
const int MAX_ITER = 1000;    // 最大迭代次数

// 计算曼德布罗集合迭代函数
int mandelbrot(const complex<double>& c) {
    complex<double> z = 0;
    int iter = 0;
    while (abs(z) <= 2.0 && iter < MAX_ITER) {
        z = z * z + c;
        ++iter;
    }
    return iter;
}

// 生成曼德布罗集合图像
void generateMandelbrot(const char* filename) {
    ofstream file(filename);
    file << "P3\n" << WIDTH << " " << HEIGHT << "\n255\n";  // 写入PPM图像文件头

    // 图像的复数平面范围
    double real_min = -2.0;
    double real_max = 1.0;
    double imag_min = -1.5;
    double imag_max = 1.5;

    // 计时开始
    auto start = high_resolution_clock::now();
    int pixel_count = 0;

    for (int y = 0; y < HEIGHT; ++y) {
        for (int x = 0; x < WIDTH; ++x) {
            double real = real_min + (real_max - real_min) * x / (WIDTH - 1);
            double imag = imag_min + (imag_max - imag_min) * y / (HEIGHT - 1);
            complex<double> c(real, imag);
            int iter = mandelbrot(c);

            // 将迭代次数映射到颜色
            int color = (iter * 255) / MAX_ITER;
            file << color << " " << color << " " << color << " ";
            pixel_count++;
        }
        file << "\n";
    }

    // 计时结束
    auto end = high_resolution_clock::now();
    duration<double> total_time = end - start;

    file.close();

    // 计算吞吐量和延迟
    double overall_throughput = pixel_count / total_time.count();
    double latency = total_time.count() / pixel_count;

    cout << "Total time: " << total_time.count() << " seconds" << endl;
    cout << "Overall throughput: " << overall_throughput << " pixels per second" << endl;
    cout << "Latency per pixel: " << latency << " seconds" << endl;
}

int main() {
    generateMandelbrot("mandelbrot.ppm");
    cout << "Mandelbrot image generated as 'mandelbrot.ppm'" << endl;
    return 0;
}
