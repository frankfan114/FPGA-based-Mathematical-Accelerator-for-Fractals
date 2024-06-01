import numpy as np
from PIL import Image
import time
import io
import os
import mandelbrot_cy  # Import the Cython module
import sys
import tempfile
import json

# 图像尺寸
WIDTH, HEIGHT = 640, 480

# 曼德布罗集合的范围
REAL_MIN, REAL_MAX = -2.0, 1.0
IMAG_MIN, IMAG_MAX = -1.5, 1.5

# 最大迭代次数
MAX_ITER = 100


if len(sys.argv) == 8:
    REAL_MAX = float(sys.argv[1])
    REAL_MIN = float(sys.argv[2])
    IMAG_MAX = float(sys.argv[3])
    IMAG_MIN = float(sys.argv[4])
    MAX_ITER = int(sys.argv[5])
    HEIGHT = int(sys.argv[6])
    WIDTH = int(sys.argv[7])


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

    frames = []
    frame_times = []
    mandelbrot_set = np.zeros((WIDTH, HEIGHT), dtype=int)
    
    for iteration in range(1, MAX_ITER + 1):
        # 使用Cython计算当前迭代次数的曼德布罗集合迭代次数矩阵
        mandelbrot_cy.compute_mandelbrot_set(mandelbrot_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, MAX_ITER, iteration)
        
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

    # print(f"Total time: {total_time:.4f} seconds")
    # print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    # print(f"Latency per pixel: {latency:.6f} seconds")
    # print(f"Average FPS: {fps:.2f} frames per second")

    # 保存最终静态图像
    final_image = Image.open(io.BytesIO(frames[-1]))
    final_image.save(filename)
    final_image.show()

    return total_time, overall_throughput, latency, frames, fps

# 生成并保存图像，并接收返回值
A = generate_mandelbrot_image("mandelbrot.png")

total_time = A[0]
overall_throughput = A[1]
latency = A[2]
frames = A[3]
fps = A[4]

print(total_time)
print(overall_throughput)
print(latency)

output = {
    
    "frames": []
}

temp_dir = tempfile.gettempdir()
output_path = os.path.join(temp_dir, "mandelbrot_output.json")

for i, frame in enumerate(frames):
    frame_path = os.path.join(temp_dir, f"frame_{i}.png")
    with open(frame_path, "wb") as f:
        f.write(frame)
    output["frames"].append(frame_path)

with open(output_path, "w") as f:
    json.dump(output, f)


#print(output_path)