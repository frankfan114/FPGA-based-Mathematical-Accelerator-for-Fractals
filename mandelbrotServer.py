from PIL import Image, ImageTk
from main import total_time, overall_throughput, latency, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, HEIGHT, WIDTH, MAX_ITER, frames

from flask_cors import CORS
import os
import subprocess
import io
import cv2
import tkinter as tk
from tkinter import ttk
from flask import Flask, send_from_directory, redirect, jsonify, render_template, request, send_file

app = Flask(__name__)
CORS(app)

class VideoPlayer:
    def __init__(self, frames):
        self.frames = frames
        self.total_frames = len(frames)
        self.current_frame = 0
        
        self.zoom_factor = 1.0

        self.root = tk.Tk()
        self.root.title("Video Player")

        self.canvas = tk.Canvas(self.root, width=640, height=480)
        self.canvas.pack()

        self.control_frame = ttk.Frame(self.root)
        self.control_frame.pack()

        self.play_button = ttk.Button(self.control_frame, text="Play", command=self.play)
        self.play_button.pack(side=tk.LEFT)

        self.pause_button = ttk.Button(self.control_frame, text="Pause", command=self.pause)
        self.pause_button.pack(side=tk.LEFT)

        self.zoom_in_button = ttk.Button(self.control_frame, text="Zoom In", command=self.zoom_in)
        self.zoom_in_button.pack(side=tk.LEFT)

        self.zoom_out_button = ttk.Button(self.control_frame, text="Zoom Out", command=self.zoom_out)
        self.zoom_out_button.pack(side=tk.LEFT)

        
        #self.playing = False 
        #self.start()

    def get_next_frame(self):
        
        self.current_frame = (self.current_frame + 1) % self.total_frames
        frame = self.frames[self.current_frame]
        # buffered = io.BytesIO()
        # frame.save(buffered, format="JPEG")
        return frame

    def play(self):
        self.playing = True
        self.get_next_frame
    def pause(self):
        self.playing = False
        self.get_next_frame
    def zoom_in(self):
        self.zoom_factor *= 1.1
        self.get_next_frame
    def zoom_out(self):
        self.zoom_factor /= 1.1
        self.get_next_frame
    def start(self):
        self.root.mainloop()


video_player = VideoPlayer(frames)

@app.route('/video')
def get_video():
    #video_player = VideoPlayer('man.avi')
    #video_player = VideoPlayer(frames)
    #video_player.start()
    return render_template('video.html')

@app.route('/next_frame')
def next_frame():
    #video_player = VideoPlayer(frames)
    frame_data = video_player.get_next_frame()
    return frame_data



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
        
        subprocess.run(['python', './main.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)])
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