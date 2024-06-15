import base64
import os
from flask import Flask, request, jsonify, send_file, render_template, url_for
from io import BytesIO
import numpy as np
from PIL import Image
import julia_cy  # 假设这个模块已经正确编译并可以导入
from flask_cors import CORS
import time
import re
import json
import cv2


app = Flask(__name__, static_folder='static')
CORS(app)

# Image dimensions
WIDTH, HEIGHT = 640, 480

# Mandelbrot set range
REAL_MIN, REAL_MAX = -1.5, 1.5
IMAG_MIN, IMAG_MAX = -1.2, 1.2

# Maximum iterations
MAX_ITER = 100

# Directory to save frames

FRAME_DIR =   'static/frames'
os.makedirs(FRAME_DIR, exist_ok=True)

def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower() for text in re.split('(\d+)', s)]

def generate_image(data_set, iteration, max_iter):
    image = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)
    julia_cy.generate_image(data_set, iteration, WIDTH, HEIGHT, image)
    return Image.fromarray(image)


@app.route('/')
def index():
    return app.send_static_file('index.html')


# @app.route('/video',  methods=['POST','GET'])
# def get_video():
#     #video_player = VideoPlayer('man.avi')
#     #video_player = VideoPlayer(frames)
#     #video_player.start()
#     #threading.Thread(target=run_video_player).start()
#     return render_template('video.html')
@app.route("/output")
def hello():
    global  total_time, overall_throughput, latency
    return jsonify({
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })

@app.route('/mandelbrot', methods=['GET','POST'])
def compute_and_display_mandelbrot():
    global  REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, HEIGHT, WIDTH, MAX_ITER,total_time, overall_throughput, latency
    if request.method in ['POST']:
    
        data = request.get_json()
        print(data)
        REAL_MAX = data.get('max_real')
        REAL_MIN = data.get('min_real')
        IMAG_MAX = data.get('max_imaginary')
        IMAG_MIN = data.get('min_imaginary')
        MAX_ITER = data.get('max_iterations')
        HEIGHT = data.get('height')
        WIDTH = data.get('width')
    
    mandelbrot_set = np.zeros((WIDTH, HEIGHT), dtype=int)
    frames = []  # List to store paths of saved frames

    try:
        # Start timing
        #start_time = time.perf_counter_ns()

        # Compute Mandelbrot set frame by frame
        for iteration in range(1, MAX_ITER + 1):
            if iteration == MAX_ITER-19:
                start_time = time.perf_counter_ns()
                
            julia_cy.compute_mandelbrot_set(mandelbrot_set, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, MAX_ITER, iteration)
            frame_image = generate_image(mandelbrot_set, iteration, MAX_ITER)
            frame_path = os.path.join(FRAME_DIR, f'mandelbrot_frame_{iteration}.png')
            frame_image.save(frame_path)
            frames.append(frame_path)
            
            if iteration == MAX_ITER:
                end_time = time.perf_counter_ns()
        # temp_dir = tempfile.gettempdir()
        # output_path = os.path.join(temp_dir, "mandelbrot_output.json")

        # for i, frame in enumerate(frames):
        #     frame_path = os.path.join(temp_dir, f"frame_{i}.png")
        #     with open(frame_path, "wb") as f:
        #         f.write(frame)
        #     output["frames"].append(frame_path)

        # with open(output_path, "w") as f:
        #     json.dump(output, f)
        
        # End timing
        #end_time = time.perf_counter_ns()

        
        mandelbrot_image = generate_image(mandelbrot_set, MAX_ITER, MAX_ITER)

        
        total_time = end_time - start_time
        pixel_count = WIDTH * HEIGHT * 20
        overall_throughput = (pixel_count / total_time) * 1e9
        latency = (total_time / pixel_count) * 1e-9
        

        print(f"Total time: {total_time / 1e9:.4f} seconds")
        print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
        print(f"Latency per pixel: {latency:.6f} seconds")
        
        # output = {
    
        #         "frames": []
        #     }

        # temp_dir = tempfile.gettempdir()
        # output_path = os.path.join(temp_dir, "mandelbrot_output.json")

        # for i, frame in enumerate(frames):
        #     frame_path = os.path.join(temp_dir, f"frame_{i}.png")
        #     with open(frame_path, "wb") as f:
        #         f.write(frame)
        #     output["frames"].append(frame_path)

        # with open(output_path, "w") as f:
        #     json.dump(output, f)
        
        # Save the final image to a BytesIO object
        img_io = BytesIO()
        mandelbrot_image.save(img_io, 'PNG')
        img_io.seek(0)
        total_time = total_time / 1e9

        # output = {
    
        #         "frames": []
        #     }

        # temp_dir = tempfile.gettempdir()
        # output_path = os.path.join(temp_dir, "mandelbrot_output.json")

        # for i, frame in enumerate(frames):
        #     frame_path = os.path.join(temp_dir, f"frame_{i}.png")
        #     with open(frame_path, "wb") as f:
        #         f.write(frame)
        #     output["frames"].append(frame_path)

        # with open(output_path, "w") as f:
        #     json.dump(output, f)
            
        return jsonify({"image": 'data:image/png;base64,' + base64.b64encode(img_io.getvalue()).decode('utf-8'),
                        'total_time': total_time, 'overall_throughput': overall_throughput, 'latency': latency,
                        'frames': frames})
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/julia', methods=['POST'])
def compute_and_display_julia():
    data = request.json
    cr = data.get('cr', 0.0)
    ci = data.get('ci', 0.0)
    print(f"Computing Julia set for c = {cr} + {ci}i")

    julia_set = np.zeros((WIDTH, HEIGHT), dtype=int)

    try:
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

        print(f"Total time: {total_time / 1e9:.4f} seconds")
        print(f"Overall throughput: {overall_throughput:.2f} pixels per second")
        print(f"Latency per pixel: {latency:.6f} seconds")

        # Save image to a BytesIO object
        img_io = BytesIO()
        julia_image.save(img_io, 'PNG')
        img_io.seek(0)
        total_time = total_time / 1e9

        return jsonify({'image': 'data:image/png;base64,' + base64.b64encode(img_io.getvalue()).decode('utf-8'),
                        'total_time': total_time, 'overall_throughput': overall_throughput, 'latency': latency})
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500
    


@app.route('/videos.html')
def video_page():
    return render_template('videos.html')

@app.route('/frames')
def get_frames():
    try:
        frame_files = sorted([url_for('static', filename=f'frames/{f}') for f in os.listdir(FRAME_DIR) if f.endswith('.png')], key=natural_sort_key)
        if not frame_files:
            return jsonify({"error": "No frames found"}), 400
        return jsonify({"frames": frame_files})
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port='5000', debug=True)