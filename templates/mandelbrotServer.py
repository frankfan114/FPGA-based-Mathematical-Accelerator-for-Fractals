from PIL import Image
from mandelbrot2 import total_time, overall_throughput, latency, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, HEIGHT, WIDTH
from flask_cors import CORS
import os
import subprocess


from flask import Flask, send_from_directory, redirect, jsonify, render_template, request

app = Flask(__name__)
CORS(app)

@app.route("/")
def hello():
    return jsonify({
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })

@app.route('/login')
def ui():
    return render_template('login.html')

# @app.route('/<unique_url>')
# def url(unique_url):
#     return render_template(f'{unique_url}.html')
@app.route('/index.html')
def ind():
    return render_template('index.html')

@app.route('/newMandelbrot.html')
def new():
    
    results = {
        'total_time': total_time,
        'overall_throughput': overall_throughput,
        'latency': latency
    }
    
    return render_template('newMandelbrot.html', results = results)

# @app.route('/mandelbrot.html', methods = ['GET'])
# def man():
    
    
#     # data = request.get_json()
    
#     # max_real = data.get('max_real')
#     # min_real = data.get('min_real')
#     # max_imaginary = data.get('max_imaginary')
#     # min_imaginary = data.get('min_imaginary')
#     # max_iterations = data.get('max_iterations')
#     # height = data.get('height')
#     # width = data.get('width')
    
#     # REAL_MAX = data.get('c_maxre')
#     # REAL_MIN = data.get('c_minre')
#     # IMAG_MAX = data.get('c_maxim')
#     # IMAG_MIN = data.get('c_minim')
#     # WIDTH = data.get('hi')
#     # HIGHT = data.get('wi')
#     # max_iter = data.get('max_iter')
#     # total_time = data.get('total_time')
#     # overall_throughput = data.get('overall_throughput')
#     # latency = data.get('latency')

#     # subprocess.run(['python', '../mandelbrot.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)])
    
    
#     for x in range(WIDTH):
#         for y in range(HEIGHT):  
#             c_re = REAL_MIN + (REAL_MAX - REAL_MIN) * x / (WIDTH - 1)
#             c_im = IMAG_MIN + (IMAG_MAX - IMAG_MIN) * y / (HEIGHT - 1)
            
#     mandelbrot_image_path = os.path.join(app.root_path, 'mandelbrot.png')
    
#     return render_template('mandelbrot.html',c_re=c_re, c_im=c_im , mandelbrot_image_path=mandelbrot_image_path)

@app.route('/image')
def serve_image():
    image_name = 'mandelbrot.png'
    return send_from_directory(os.path.join(app.root_path), image_name)

@app.route('/mandelbrot.html', methods=['POST','GET'])
def set_params():
    
    if request.method == 'POST':
        data = request.get_json()
        max_real = data.get('max_real')
        min_real = data.get('min_real')
        max_imaginary = data.get('max_imaginary')
        min_imaginary = data.get('min_imaginary')
        max_iterations = data.get('max_iterations')
        height = data.get('height')
        width = data.get('width')
#     max_real = data.get('max_real')
#     min_real = data.get('min_real')
#     max_imaginary = data.get('max_imaginary')
#     min_imaginary = data.get('min_imaginary')
#     max_iterations = data.get('max_iterations')
#     # total_time = data.get('total_time')
#     # overall_throughput = data.get('overall_throughput')
#     # latency = data.get('latency')
#     height = data.get('height')
#     width = data.get('width')
#     # REAL_MAX = data.get('c_maxre')
#     # REAL_MIN = data.get('c_minre')
#     # IMAG_MAX = data.get('c_maxim')
#     # IMAG_MIN = data.get('c_minim')
#     # WIDTH = data.get('hi')
#     # HIGHT = data.get('wi')
#     # max_iter = data.get('max_iter')
#     # total_time = data.get('total_time')
#     # overall_throughput = data.get('overall_throughput')
#     # latency = data.get('latency')
#     import subprocess
        print(max_real)
        subprocess.run(['python', './mandelbrot2.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)])
#     subprocess.run(['python', '../mandelbrot.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)])
#     # Assuming you will do something with these values, like regenerating the Mandelbrot image
    mandelbrot_image_path = os.path.join(app.root_path, 'mandelbrot.png')
    
    for x in range(WIDTH):
        for y in range(HEIGHT):  
             c_re = REAL_MIN + (REAL_MAX - REAL_MIN) * x / (WIDTH - 1)
             c_im = IMAG_MIN + (IMAG_MAX - IMAG_MIN) * y / (HEIGHT - 1)   
    
    return render_template('mandelbrot.html',c_re=c_re, c_im=c_im , mandelbrot_image_path=mandelbrot_image_path)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=False)