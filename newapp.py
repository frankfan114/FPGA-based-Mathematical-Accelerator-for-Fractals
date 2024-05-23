from flask import Flask, jsonify, send_from_directory,redirect
import os

# Assuming generate_mandelbrot_image is a function that needs to be called to get the metrics
from mandelbrot import generate_mandelbrot_image

app = Flask(__name__)

@app.route("/compute-mandelbrot")
def compute_mandelbrot():
    # Assuming generate_mandelbrot_image returns the computed total_time, overall_throughput, and latency
    total_time, overall_throughput, latency = generate_mandelbrot_image("mandelbrot.png")
    
    # Return the results as JSON
    return jsonify({
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })

@app.route('/image')
def serve_image():
    image_name = 'mandelbrot.png'
    return send_from_directory(os.path.join(app.root_path, 'static'), image_name)


@app.route('/ui')
def index():
    # Redirect to another UI component or static HTML page
    return redirect("http://146.169.174.141:5000")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
