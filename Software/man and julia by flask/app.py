from flask import Flask, request, jsonify, send_file
from io import BytesIO
import numpy as np
from PIL import Image

import julia_cy  # 导入Cython模块
from flask_cors import CORS
app = Flask(__name__, static_folder='static')
CORS(app)
from flask import Flask, request, jsonify, send_file
import numpy as np
from PIL import Image
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

@app.route('/')
def index():
    return app.send_static_file('index.html')


@app.route('/mandelbrot', methods=['GET'])
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

    # Save image to a BytesIO object
    img_io = io.BytesIO()
    # mandelbrot_image.save("mandelbrot1.png", )
    mandelbrot_image.save(img_io, 'PNG')
    img_io.seek(0)

    return send_file(img_io, mimetype='image/png')


@app.route('/julia', methods=['POST'])
def compute_and_display_julia():
    data = request.json
    cr = data.get('cr', 0.0)
    ci = data.get('ci', 0.0)
    print(f"Computing Julia set for c = {cr} + {ci}i")

    julia_set = np.zeros((WIDTH, HEIGHT), dtype=int)
    julia_cy.compute_julia_set(julia_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, cr, ci, MAX_ITER)
    julia_image = generate_image(julia_set, MAX_ITER, MAX_ITER)

    # Save image to a BytesIO object
    img_io = io.BytesIO()
    julia_image.save(img_io, 'PNG')
    img_io.seek(0)

    return send_file(img_io, mimetype='image/png')

if __name__ == '__main__':
    app.run(debug=True)
