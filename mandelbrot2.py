import numpy as np
from PIL import Image
import time
import math
import io
# 图像尺寸
WIDTH, HEIGHT = 800, 800

# 曼德布罗集合的范围
REAL_MIN, REAL_MAX = -5.0, 2.0
IMAG_MIN, IMAG_MAX = -3.5, 3.5

# 最大迭代次数
MAX_ITER = 100

# 计算曼德布罗集合迭代函数
def mandelbrot(c, max_iter):
    z = 0
    for n in range(max_iter):
        if abs(z) > 2:
            return n
        z = z*z + c
    return max_iter

# 颜色映射函数，将迭代次数转换为颜色
def map_color(iter, max_iter):
    if iter == max_iter:
        return (0, 0, 0)  # 内部为黑色
    else:
        t = iter / max_iter
        r = int(9 * (1 - t) * t * t * t * 255)
        g = int(15 * (1 - t) * (1 - t) * t * t * 255)
        b = int(8.5 * (1 - t) * (1 - t) * (1 - t) * t * 255)
        return (r, g, b)
    
    
def generate_mandelbrot_frame(iteration, max_iter):
    image = Image.new("RGB", (WIDTH, HEIGHT))
    pixels = image.load()

    for x in range(WIDTH):
        for y in range(HEIGHT):
            real = REAL_MIN + (REAL_MAX - REAL_MIN) * x / (WIDTH - 1)
            imag = IMAG_MIN + (IMAG_MAX - IMAG_MIN) * y / (HEIGHT - 1)
            c = complex(real, imag)
            iter = mandelbrot(c, iteration)
            color = map_color(iter, max_iter)
            pixels[x, y] = color
            
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    buffer.seek(0)
    return buffer.read()

# 生成曼德布罗集合图像
def generate_mandelbrot_image(filename):
    image = Image.new("RGB", (WIDTH, HEIGHT))
    pixels = image.load()
    frames = []
    start_time = time.time()
    # for iteration in range(1, MAX_ITER + 1):
    #       frame = generate_mandelbrot_frame(iteration, MAX_ITER)
    #       frames.append(frame)
    for x in range(WIDTH):
        for y in range(HEIGHT):
            real = REAL_MIN + (REAL_MAX - REAL_MIN) * x / (WIDTH - 1)
            imag = IMAG_MIN + (IMAG_MAX - IMAG_MIN) * y / (HEIGHT - 1)
            c = complex(real, imag)
            iter = mandelbrot(c, MAX_ITER)
            color = map_color(iter, MAX_ITER)
            pixels[x, y] = color

    end_time = time.time()

    # 计算总时间、吞吐量和延迟
    total_time = end_time - start_time
    pixel_count = WIDTH * HEIGHT
    overall_throughput = pixel_count / total_time
    latency = total_time / pixel_count

    print(f"Total time: {total_time:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.6f} seconds")
  
    image.save(filename)
    image.show()
    return  total_time, overall_throughput, latency, frames
# 生成并保存图像
A = generate_mandelbrot_image("mandelbrot.png")

total_time = A[0]
overall_throughput = A[1]
latency = A[2]
frames = A[3]
