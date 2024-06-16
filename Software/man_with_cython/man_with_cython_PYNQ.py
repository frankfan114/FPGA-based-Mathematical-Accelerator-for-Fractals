import numpy as np
from PIL import Image
import time
import io
import mandelbrot_cy  # Import the Cython module

# Image dimensions
WIDTH, HEIGHT = 640, 480

# Mandelbrot set range
REAL_MIN, REAL_MAX = -1.5, 1.5
IMAG_MIN, IMAG_MAX = -1.2, 1.2

# Maximum iterations
MAX_ITER = 100

# Generate a single frame of the Mandelbrot set image
def generate_mandelbrot_frame(mandelbrot_set, iteration, max_iter):
    image = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)
    mandelbrot_cy.generate_mandelbrot_image_c(mandelbrot_set, iteration, WIDTH, HEIGHT, image)
    pil_image = Image.fromarray(image)
    buffer = io.BytesIO()
    pil_image.save(buffer, format="PNG")
    buffer.seek(0)
    return buffer.read()

# Generate the Mandelbrot set image and calculate performance metrics
def generate_mandelbrot_image():
    start_time = time.perf_counter_ns()

    frame_times = []
    mandelbrot_set = np.zeros((WIDTH, HEIGHT), dtype=int)

    for iteration in range(1, MAX_ITER + 1):
        # Use Cython to compute the Mandelbrot set iteration matrix for the current iteration
        mandelbrot_cy.compute_mandelbrot_set(mandelbrot_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, MAX_ITER, iteration)

        frame_start_time = time.time()
        frame = generate_mandelbrot_frame(mandelbrot_set, iteration, MAX_ITER)
        frame_end_time = time.time()
        frame_times.append(frame_end_time - frame_start_time)

    end_time = time.perf_counter_ns()

    # Calculate total time, throughput, and latency
    total_time = end_time - start_time
    pixel_count = WIDTH * HEIGHT * MAX_ITER
    overall_throughput = (pixel_count / total_time) * 1e9
    latency = (total_time / pixel_count) * 1e-9

    # Calculate frame rate
    total_frame_time = sum(frame_times)
    fps = len(frame_times) / total_frame_time

    print(f"Total time: {total_time / 1e9:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.30f} seconds")
    print(f"Average FPS: {fps:.2f} frames per second")

    return total_time, overall_throughput, latency, fps

# Generate the Mandelbrot set image and receive the return values
total_time, overall_throughput, latency, fps = generate_mandelbrot_image()
