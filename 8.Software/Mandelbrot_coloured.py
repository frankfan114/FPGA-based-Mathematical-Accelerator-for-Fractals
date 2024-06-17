import numpy as np
import matplotlib.pyplot as plt
import time


def mandelbrot(c, max_iter):
    z = 0
    n = 0
    while abs(z) <= 2 and n < max_iter:
        z = z * z + c
        n += 1
    if n == max_iter:  
        return max_iter
    return n + 1 - np.log(np.log2(abs(z))) 


def mandelbrot_set(width, height, x_min, x_max, y_min, y_max, max_iter):
    x, y = np.linspace(x_min, x_max, width), np.linspace(y_min, y_max, height)
    C = np.array([[complex(a, b) for a in x] for b in y])

    mandelbrot_output = np.zeros((height, width))
    for i in range(height):
        for j in range(width):
            mandelbrot_output[i, j] = mandelbrot(C[i, j], max_iter)

    return mandelbrot_output


def plot_mandelbrot_set(mandelbrot_output, x_min, x_max, y_min, y_max):
    plt.imshow(mandelbrot_output, cmap='jet', extent=[x_min, x_max, y_min, y_max])
    plt.title("Mandelbrot Set")
    plt.xlabel("Re")
    plt.ylabel("Im")
    plt.show()


if __name__ == "__main__":
    width, height = 1920, 1080
    x_min, x_max = -2.0, 1.0
    y_min, y_max = -1.5, 1.5
    max_iter = 100

    start_time = time.time()

    mandelbrot_output = mandelbrot_set(width, height, x_min, x_max, y_min, y_max, max_iter)

    end_time = time.time()

    total_time = end_time - start_time
    pixel_count = width * height
    overall_throughput = pixel_count / total_time
    latency = total_time / pixel_count

    print(f"Total time: {total_time:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.6f} seconds")

    plot_mandelbrot_set(mandelbrot_output, x_min, x_max, y_min, y_max)
