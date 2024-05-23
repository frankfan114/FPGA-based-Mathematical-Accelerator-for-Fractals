from mandelbrot import total_time, overall_throughput, latency  # Correctly import your function
from flask import Flask, jsonify,send_from_directory

import os

app = Flask(__name__)

@app.route('/compute-mandelbrot')
def compute_mandelbrot():
    # Call the function from mandelbrot.py and capture its outputs
    # total_time, overall_throughput, latency = generate_mandelbrot_image("mandelbrot.png")
    # Return results as JSON
    image_name = 'mandelbrot.png'
    
    return jsonify({
        
        send_from_directory(os.path.join(app.root_path),image_name),
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })

if __name__ == '__main__':
    app.run(host = '0.0.0.0', port = 5000,debug=True)
