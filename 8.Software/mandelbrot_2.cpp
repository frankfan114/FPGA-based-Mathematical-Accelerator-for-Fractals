#include <iostream>
#include <fstream>
#include <complex>
#include <chrono>

using namespace std;
using namespace std::chrono;

const int WIDTH = 800;        
const int HEIGHT = 800;       
const int MAX_ITER = 1000;    

int mandelbrot(const complex<double>& c) {
    complex<double> z = 0;
    int iter = 0;
    while (abs(z) <= 2.0 && iter < MAX_ITER) {
        z = z * z + c;
        ++iter;
    }
    return iter;
}


void mapColor(int iter, int max_iter, int& r, int& g, int& b) {
    if (iter == max_iter) {
        r = g = b = 0;  
    } else {
        double t = (double)iter / max_iter;
        r = (int)(9 * (1 - t) * t * t * t * 255);
        g = (int)(15 * (1 - t) * (1 - t) * t * t * 255);
        b = (int)(8.5 * (1 - t) * (1 - t) * (1 - t) * t * 255);
    }
}

void generateMandelbrot(const char* filename) {
    ofstream file(filename);
    file << "P3\n" << WIDTH << " " << HEIGHT << "\n255\n";  

    // 图像的复数平面范围
    double real_min = -2.0;
    double real_max = 1.0;
    double imag_min = -1.5;
    double imag_max = 1.5;

    auto start = high_resolution_clock::now();
    int pixel_count = 0;

    for (int y = 0; y < HEIGHT; ++y) {
        for (int x = 0; x < WIDTH; ++x) {
            double real = real_min + (real_max - real_min) * x / (WIDTH - 1);
            double imag = imag_min + (imag_max - imag_min) * y / (HEIGHT - 1);
            complex<double> c(real, imag);
            int iter = mandelbrot(c);

            // 颜色映射
            int r, g, b;
            mapColor(iter, MAX_ITER, r, g, b);

            file << r << " " << g << " " << b << " ";
            pixel_count++;
        }
        file << "\n";
    }

    auto end = high_resolution_clock::now();
    duration<double> total_time = end - start;

    file.close();

    double overall_throughput = pixel_count / total_time.count();
    double latency = total_time.count() / pixel_count;

    cout << "Total time: " << total_time.count() << " seconds" << endl;
    cout << "Overall throughput: " << overall_throughput << " pixels per second" << endl;
    cout << "Latency per pixel: " << latency << " seconds" << endl;
}

int main() {
    generateMandelbrot("mandelbrot2.ppm");
    cout << "Mandelbrot image generated as 'mandelbrot2.ppm'" << endl;
    return 0;
}

