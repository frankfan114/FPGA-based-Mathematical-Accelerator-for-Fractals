import base64

from flask import Flask, request, send_file, jsonify
from io import BytesIO
import numpy as np
from PIL import Image
import julia_cy  # 假设这个模块已经正确编译并可以导入
from flask_cors import CORS
import time

app = Flask(__name__, static_folder='static')
CORS(app)

# Image dimensions
WIDTH, HEIGHT = 640, 480

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
    start_time = time.perf_counter_ns()

    # Compute Mandelbrot set
    julia_cy.compute_mandelbrot_set(mandelbrot_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, MAX_ITER, MAX_ITER)

    # Generate the final image
    mandelbrot_image = generate_image(mandelbrot_set, MAX_ITER, MAX_ITER)

    # End timing
    end_time = time.perf_counter_ns()

    # Calculate total time, throughput, and latency
    total_time = end_time - start_time
    pixel_count = WIDTH * HEIGHT * MAX_ITER
    overall_throughput = (pixel_count / total_time) * 1e9
    latency = (total_time / pixel_count)*1e-9

    print(f"Total time: {total_time/1e9:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.6f} seconds")

    # Save image to a BytesIO object
    img_io = BytesIO()
    mandelbrot_image.save(img_io, 'PNG')
    img_io.seek(0)
    total_time = total_time / 1e9
    return jsonify({"image": 'data:image/png;base64,' + base64.b64encode(img_io.getvalue()).decode('utf-8'),
                    'total_time': total_time, 'overall_throughput': overall_throughput, 'latency': latency})


@app.route('/julia', methods=['POST'])
def compute_and_display_julia():
    data = request.json
    cr = data.get('cr', 0.0)
    ci = data.get('ci', 0.0)
    print(f"Computing Julia set for c = {cr} + {ci}i")

    julia_set = np.zeros((WIDTH, HEIGHT), dtype=int)

    # Start timing
    start_time = time.perf_counter_ns()

    # Compute Julia set
    julia_cy.compute_julia_set(julia_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, cr, ci, MAX_ITER)

    # End timing
    end_time = time.perf_counter_ns()

    # Generate the final image
    julia_image = generate_image(julia_set, MAX_ITER, MAX_ITER)

    # Calculate total time, throughput, and latency in seconds
    total_time = (end_time - start_time)

    pixel_count = WIDTH * HEIGHT * MAX_ITER
    overall_throughput = (pixel_count / total_time) * 1e9
    latency = (total_time / pixel_count) * 1e-9

    print(f"Total time: {total_time/1e9:.4f} seconds")
    print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
    print(f"Latency per pixel: {latency:.6f} seconds")

    # Save image to a BytesIO object
    img_io = BytesIO()
    julia_image.save(img_io, 'PNG')
    img_io.seek(0)
    total_time = total_time / 1e9
    return jsonify(
        {'image': 'data:image/png;base64,' + base64.b64encode(img_io.getvalue()).decode('utf-8'), 'total_time': total_time,
         'overall_throughput': overall_throughput, 'latency': latency})


if __name__ == '__main__':
    app.run(debug=True)
