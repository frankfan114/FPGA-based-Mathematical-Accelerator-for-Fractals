import numpy as np
from PIL import Image, ImageTk
import tkinter as tk
import time
import io
import julia_cy  # Import the Cython module

# Image dimensions
WIDTH, HEIGHT = 800, 800

# Mandelbrot set range
REAL_MIN, REAL_MAX = -2.0, 1.0
IMAG_MIN, IMAG_MAX = -1.5, 1.5

# Maximum iterations
MAX_ITER = 100

def generate_image(data_set, iteration, max_iter):
    image = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)
    julia_cy.generate_image(data_set, iteration, WIDTH, HEIGHT, image)
    return Image.fromarray(image)

def compute_and_display_mandelbrot():
    mandelbrot_set = np.zeros((WIDTH, HEIGHT), dtype=int)

    # Start timing
    start_time = time.time()

    # Compute Mandelbrot set
    frame_times = []
    for iteration in range(1, MAX_ITER + 1):
        frame_start_time = time.time()
        julia_cy.compute_mandelbrot_set(mandelbrot_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, MAX_ITER, iteration)
        frame_end_time = time.time()
        frame_times.append(frame_end_time - frame_start_time)

    # Generate the final image
    mandelbrot_image = generate_image(mandelbrot_set, MAX_ITER, MAX_ITER)

    # End timing
    end_time = time.time()

    # Calculate total time, throughput, and latency
    total_time = end_time - start_time
    pixel_count = WIDTH * HEIGHT * MAX_ITER
    overall_throughput = pixel_count / total_time
    latency = total_time / pixel_count

    # Calculate frame rate
    total_frame_time = sum(frame_times)
    fps = len(frame_times) / total_frame_time

    print(f"Total time: {total_time:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.6f} seconds")
    print(f"Average FPS: {fps:.2f} frames per second")

    return mandelbrot_image, total_time, overall_throughput, latency, fps

def compute_and_display_julia(cr, ci):
    print(f"Computing Julia set for c = {cr} + {ci}i")
    julia_set = np.zeros((WIDTH, HEIGHT), dtype=int)
    julia_cy.compute_julia_set(julia_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, cr, ci, MAX_ITER)
    julia_image = generate_image(julia_set, MAX_ITER, MAX_ITER)

    # Debug: temporarily save the image to check
    julia_image.save("julia_temp.png")

    return julia_image

def mandelbrot_click(event, canvas, mandelbrot_image):
    x, y = event.x, event.y
    cr = REAL_MIN + (REAL_MAX - REAL_MIN) * x / (WIDTH - 1)
    ci = IMAG_MIN + (IMAG_MAX - IMAG_MIN) * y / (HEIGHT - 1)
    print(f"Mouse clicked at: ({x}, {y})")
    print(f"Mapped to complex plane: ({cr}, {ci})")
    julia_image = compute_and_display_julia(cr, ci)
    display_image(julia_image, canvas)

def display_image(image, canvas):
    img = ImageTk.PhotoImage(image)
    canvas.create_image(0, 0, anchor=tk.NW, image=img)
    canvas.image = img  # Keep reference to avoid garbage collection

def main():
    mandelbrot_image, total_time, overall_throughput, latency, fps = compute_and_display_mandelbrot()

    root = tk.Tk()
    root.title("Mandelbrot and Julia Sets")

    mandelbrot_canvas = tk.Canvas(root, width=WIDTH, height=HEIGHT)
    mandelbrot_canvas.pack()
    display_image(mandelbrot_image, mandelbrot_canvas)
    mandelbrot_canvas.bind("<Button-1>", lambda event: mandelbrot_click(event, mandelbrot_canvas, mandelbrot_image))

    root.mainloop()

    # Save the final static image
    final_image = mandelbrot_image
    final_image.save("mandelbrot.png")
    final_image.show()

if __name__ == "__main__":
    main()
