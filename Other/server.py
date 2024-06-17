from PIL import Image
from mandelbrot2 import total_time, overall_throughput, latency,frames, WIDTH, HEIGHT, MAX_ITER
from flask_cors import CORS
from flask_socketio import SocketIO, emit
from flask import Flask, send_from_directory, redirect, jsonify,  render_template, send_file
import os
import io
#from mandelbrot import *
import time

app = Flask(__name__)
CORS(app) 

# @app.route("/")
# def hello():
  
    
#     # return ({(f"Total time: {total_time:.4f} seconds<br>"
#     #         f"Overall throughput: {overall_throughput} pixels per second<br>"
#     #         f"Latency per pixel: {latency} seconds",
#     #          )})
    
#     return jsonify({
#         "total_time": total_time,
#         "overall_throughput": overall_throughput,
#         "latency": latency
#     })

#"Total time: ",total_time, ":.4f seconds""Overall throughput:", overall_throughput," pixels per second""Latency per pixel: ",latency, "seconds"
@app.route('/frames/<int:iteration>')
def get_frame(iteration):
    if iteration < 1 or iteration > MAX_ITER:
        return "Invalid iteration number", 400
    
    frame_data = frames[iteration]
    img = Image.open(io.BytesIO(frame_data))
    img_io = io.BytesIO()
    img.save(img_io, 'PNG')
    img_io.seek(0)
    
    return send_file(img_io, mimetype='image/png')
    
@app.route('/image')
def serve_image():
    image_name = 'mandelbrot.png'
    return send_from_directory(os.path.join(app.root_path), image_name)

# @app.route('/ui')
# def index():
#   return redirect("http://146.169.174.141:5000")

if __name__ == '__main__':
    
    app.run(host = '0.0.0.0', port = 5001, debug = False)