import numpy as np
from PIL import Image
import time
import io
import mandelbrot_cy  # Import the Cython module

# 图像尺寸
WIDTH, HEIGHT = 800, 800

# 曼德布罗集合的范围
REAL_MIN, REAL_MAX = -2.0, 1.0
IMAG_MIN, IMAG_MAX = -1.5, 1.5

# 最大迭代次数
MAX_ITER = 100

# 计算曼德布罗集合迭代次数矩阵
def compute_mandelbrot_set(width, height, real_min, real_max, imag_min, imag_max, max_iter):
    mandelbrot_set = np.zeros((width, height), dtype=int)
    for x in range(width):
        for y in range(height):
            real = real_min + (real_max - real_min) * x / (width - 1)
            imag = imag_min + (imag_max - imag_min) * y / (height - 1)
            c = complex(real, imag)
            mandelbrot_set[x, y] = mandelbrot(c, max_iter)
    return mandelbrot_set

# 计算曼德布罗集合迭代函数
def mandelbrot(c, max_iter):
    z = 0
    for n in range(max_iter):
        if abs(z) > 2:
            return n
        z = z*z + c
    return max_iter

# 生成单帧曼德布罗集合图像
def generate_mandelbrot_frame(mandelbrot_set, iteration, max_iter):
    image = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)

    mandelbrot_cy.generate_mandelbrot_image_c(mandelbrot_set, iteration, WIDTH, HEIGHT, image)

    pil_image = Image.fromarray(image)
    buffer = io.BytesIO()
    pil_image.save(buffer, format="PNG")
    buffer.seek(0)
    return buffer.read()

# 生成曼德布罗集合图像并保存动画帧
def generate_mandelbrot_image(filename):
    start_time = time.time()

    # 计算曼德布罗集合迭代次数矩阵
    mandelbrot_set = compute_mandelbrot_set(WIDTH, HEIGHT, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, MAX_ITER)

    frames = []
    frame_times = []
    for iteration in range(1, MAX_ITER + 1):
        frame_start_time = time.time()
        frame = generate_mandelbrot_frame(mandelbrot_set, iteration, MAX_ITER)
        frames.append(frame)
        frame_end_time = time.time()
        frame_times.append(frame_end_time - frame_start_time)

    end_time = time.time()

    # 计算总时间、吞吐量和延迟
    total_time = end_time - start_time
    pixel_count = WIDTH * HEIGHT * MAX_ITER
    overall_throughput = pixel_count / total_time
    latency = total_time / pixel_count

    # 计算帧率
    total_frame_time = sum(frame_times)
    fps = len(frame_times) / total_frame_time

    print(f"Total time: {total_time:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.6f} seconds")
    print(f"Average FPS: {fps:.2f} frames per second")

    # 保存最终静态图像
    final_image = Image.open(io.BytesIO(frames[-1]))
    final_image.save(filename)
    final_image.show()

    return total_time, overall_throughput, latency, frames, fps

# 生成并保存图像，并接收返回值
A = generate_mandelbrot_image("../mandelbrot.png")

total_time = A[0]
overall_throughput = A[1]
latency = A[2]
frames = A[3]
fps = A[4]
