from PIL import Image
from mandelbrot import total_time, overall_throughput, latency
from flask_cors import CORS
import os

from flask import Flask, send_from_directory, redirect, jsonify

app = Flask(__name__)
CORS(app) 

@app.route("/")
def hello():
  
    
    # return ({(f"Total time: {total_time:.4f} seconds<br>"
    #         f"Overall throughput: {overall_throughput} pixels per second<br>"
    #         f"Latency per pixel: {latency} seconds",
    #          )})
    
    return jsonify({
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })
    
#"Total time: ",total_time, ":.4f seconds""Overall throughput:", overall_throughput," pixels per second""Latency per pixel: ",latency, "seconds"

@app.route('/image')
def serve_image():
    image_name = 'mandelbrot.png'
    return send_from_directory(os.path.join(app.root_path), image_name)

# @app.route('/ui')
# def index():
#   return redirect("http://146.169.174.141:5000")

if __name__ == '__main__':
    
    app.run(host = '0.0.0.0', port = 5001, debug = False)
