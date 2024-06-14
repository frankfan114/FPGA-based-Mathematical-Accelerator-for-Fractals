from PIL import Image, ImageTk
#from main import total_time, overall_throughput, latency, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, HEIGHT, WIDTH, MAX_ITER, frames, frame_path
#from mandelbrot2 import total_time, overall_throughput, latency, REAL_MIN, REAL_MAX, IMAG_MIN, IMAG_MAX, HEIGHT, WIDTH, MAX_ITER, frames
from flask_cors import CORS
import threading
import os
import subprocess
import io
import base64
import tkinter as tk
import tempfile
import json
from tkinter import ttk
from flask import Flask, send_from_directory, redirect, jsonify, render_template, request, send_file
import glob
app = Flask(__name__)
CORS(app)

is_paused = False



class VideoPlayer:
    def __init__(self, frames):
        #self.current_image = None
        self.frames = frames
        self.total_frames = len(frames)
        self.current_frame = 0
        self.playing = False
        self.zoom_factor = 1

        self.root = tk.Tk()
        self.root.title("Video Player")

        self.canvas = tk.Canvas(self.root, width=640, height=480)
        self.canvas.pack()


        self.progress_bar = ttk.Progressbar(self.root, orient="horizontal", length=640, mode="determinate")
        self.progress_bar.pack()
        
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

    # def get_next_frame(self):
        
    #     self.current_frame = (self.current_frame + 1) % self.total_frames
    #     frame = self.frames[self.current_frame]
    #     # buffered = io.BytesIO()
    #     # frame.save(buffered, format="JPEG")
    #     return frame
    
    def get_next_frame(self):
        frame_data = self.frames[self.current_frame]
        self.current_frame = (self.current_frame + 1) % self.total_frames
        return frame_data
    

    def play(self):
        self.playing = True
        self.update_frame()
    def pause(self):
        self.playing = False
        
    def zoom_in(self):
        self.zoom_factor *= 1.1
        self.get_next_frame
    def zoom_out(self):
        self.zoom_factor /= 1.1
        self.get_next_frame
    def start(self):
        #self.update_frame()
        self.root.mainloop()

    def update_frame(self):
        if self.playing:
            frame = self.get_next_frame()
            # Convert frame to ImageTk.PhotoImage
            image = ImageTk.PhotoImage(Image.open(io.BytesIO(frame)))
            # Update canvas with the image
            self.canvas.create_image(0, 0, anchor=tk.NW, image=image)
            self.canvas.image = image  # Keep a reference to prevent garbage collection
            self.progress_bar["value"] = (self.current_frame / self.total_frames) * 100
        self.root.after(100, self.update_frame)

    def update_frames(self, new_frames):
        self.frames = new_frames
        self.total_frames = len(new_frames)
        self.current_frame = 0
        
#video_player = VideoPlayer(frames)    
    
def run_video_player():
    video_player.start()
    

# def generate_mandelbrot_frames():
#     temp_dir = tempfile.gettempdir()
#     output_path = os.path.join(temp_dir, "mandelbrot_output.json")

#     with open(output_path, "r") as f:
#         output_data = json.load(f)
        
#     generated_frames = []
#     #frame_path = os.path.join(temp_dir, f"frame_{i}.png")
    
#     for frame_path in output_data['frames']:
        
#         with open(frame_path, "rb") as f:
#             generated_frames.append(f.read())
#     print('1')
#     return generated_frames

    
def generate_mandelbrot_frames():
    global max_iter
    temp_dir =   tempfile.gettempdir()
    output_path = os.path.join(temp_dir, "mandelbrot_frame_*.png")
    frame_paths = glob.glob(output_path)
    # with open(output_path, "r") as f:
    #     output_data = json.load(f)
        
    generated_frames = []
    #frame_path = os.path.join(temp_dir, f"frame_{i}.png")
    max_iter = 0
    for frame_path in frame_paths:
        iteration = int(os.path.basename(frame_path).split('_')[-1].split('.')[0])
        max_iter = max(max_iter, iteration)
        
        #frame_path = os.path.join(temp_dir, f"mandelbrot_frame_{iteration}.png")
        with open(frame_path, "rb") as f:
            generated_frames.append(f.read())
    print(max_iter)
    return generated_frames


#run_video_player()


@app.route('/video',  methods=['POST','GET'])
def get_video():
    #video_player = VideoPlayer('man.avi')
    #video_player = VideoPlayer(frames)
    #video_player.start()
    #threading.Thread(target=run_video_player).start()
    return render_template('video.html')

@app.route('/play_video')
def play_video():
    global is_paused
    is_paused = False
    return jsonify({'status': 'playing'}), 200

@app.route('/pause_video')
def pause_video():
    global is_paused
    is_paused = True
    return jsonify({'status': 'paused'}), 200

@app.route('/import')
def imp():
    #start_video_player()
    return render_template('import.html')

frame = generate_mandelbrot_frames()
iter = 0
@app.route('/next_frame')
def next_frame():
    # global iter
    # frame_data = frame[iter]
    # if iter <= max_iter:
    #     iter = iter+1
    # else:
    #     iter = 0
    # #video_player = VideoPlayer(frames)
    # print(iter)
    frame_data = video_player.get_next_frame()
    
    return frame_data



@app.route('/progress')
def get_progress():
    # 在这里计算视频播放的进度，假设当前进度为 50%
    current_progress = video_player.current_frame
    
    # 返回当前进度
    return jsonify({'progress': current_progress})







@app.route("/")
def hello():
    global  total_time, overall_throughput, latency
    return jsonify({
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })
    
@app.route('/login')
def ui():
    return render_template('login.html')

@app.route('/gui')
def gui():
    
    
    return render_template('gui.html')

@app.route('/guibackup')
def guibackup():
    
    
    return render_template('guibackup.html')

@app.route('/images')
def get_imagess():
    image_name = 'output.png'
    image_path = '\\\\192.168.2.99\\xilinx\\jupyter_notebooks'
    return send_from_directory(image_path, image_name)



@app.route('/post_image', methods=['GET','POST'])
def ser_image():
    image_path = os.path.join(app.root_path, 'mandelbrot.png')
    
    try:
        # Read the image file in binary mode
        with open(image_path, 'rb') as image_file:
            # Encode the image to Base64
            encoded_image = base64.b64encode(image_file.read()).decode('utf-8')

        # Return the encoded image in a JSON response
        return jsonify({"image": encoded_image})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

import requests
@app.route('/get_image',methods=['POST','GET'])
def get_images():
    global  total_time, overall_throughput, latency
    
    if request.method in ['POST','GET']:
    
        data = request.get_json()
        print(data)
        max_real = data.get('max_real')
        min_real = data.get('min_real')
        max_imaginary = data.get('max_imaginary')
        min_imaginary = data.get('min_imaginary')
        max_iterations = data.get('max_iterations')
        height = data.get('height')
        width = data.get('width')
        zoomin_factor = data.get('zoomin_factor')
        zoomout_factor = data.get('zoomout_factor')
        coordinate = data.get('coordinate')
        up = data.get('up')
        down = data.get('down')
        left = data.get('left')
        right = data.get('right')
        color1 = data.get('color1')
        color2 = data.get('color2')
        color3 = data.get('color3')
        reset  = data.get('reset')
        zoom_factor = data.get('zoom_factor')
        julia = data.get('julia')
        clickX = data.get('clickX')
        clickY =  data.get('clickY')
        # result = subprocess.run(
        #     ['python', './main.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)],
        #     capture_output=True,
        #     text=True
        # )
        
        # output = result.stdout.strip().split()
        # total_time = float(output[0])
        # overall_throughput = float(output[1])
        # latency = float(output[2])
        
        #frames = generate_mandelbrot_frames()
            #video_player = VideoPlayer(generated_frames)
        #video_player.update_frames(frames)
        #video_player.current_frame = 0
        try:
            response = requests.post(
                    "http://192.168.2.99:5011/generate_image",
                    #"http://146.169.130.117:5001/post_image",
                    json={
                        "max_real": max_real,
                        "min_real": min_real,
                        "max_imaginary": max_imaginary,
                        "min_imaginary": min_imaginary,
                        "max_iterations": max_iterations,
                        "height": height,
                        "width": width,
                        "zoomin_factor": zoomin_factor,
                        "zoomout_factor": zoomout_factor,
                        "coordinate": coordinate,
                        "color1": color1,
                        "color2": color2,
                        "color3": color3,
                        "up": up,
                        "down": down,
                        "left":left,
                        "right":right,
                        "reset": reset,
                        "julia": julia,
                        "clickX" : clickX,
                        "clickY": clickY
                    }
                )
            #encoded_image = base64.b64encode(response.text.encode()).decode('utf-8')
        except:
            print("error")
        
        return jsonify({"image": response.json()["image"],
                        "frame_rate": response.json()["frame_rate"],
                        "pixel_rate": response.json()["pixel_rate"],
                        "latency": response.json()["latency"],
                        "total_time":response.json()["total_time"]
                        
                        })


@app.route('/index.html')
def ind():
    return render_template('index.html')

@app.route('/newMandelbrot.html', methods=['POST','GET'])
def new():
    global video_player, total_time, overall_throughput, latency
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







    




@app.route('/image')
def serve_image():
    image_name = 'mandelbrot.png'
    return send_from_directory(os.path.join(app.root_path), image_name)


@app.route('/mandelbrot.html', methods=['POST','GET'])
def set_params():
    global video_player, total_time, overall_throughput, latency, frames
    if request.method == 'POST':
        
        data = request.get_json()
        
        max_real = data.get('max_real')
        min_real = data.get('min_real')
        max_imaginary = data.get('max_imaginary')
        min_imaginary = data.get('min_imaginary')
        max_iterations = data.get('max_iterations')
        height = data.get('height')
        width = data.get('width')

        
        result = subprocess.run(
            ['python', './main.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)],
            capture_output=True,
            text=True
        )

        print(f"main.py output: {result.stdout}")  # 打印输出以供调试

        
            # 解析 main.py 的输出
            
        output = result.stdout.strip().split()
        total_time = float(output[0])
        overall_throughput = float(output[1])
        latency = float(output[2])
        
        frames = generate_mandelbrot_frames()
            #video_player = VideoPlayer(generated_frames)
        video_player.update_frames(frames)
        video_player.current_frame = 0
            #threading.Thread(target=run_video_player).start()
            #video_player.start()
        return redirect('/')
#     subprocess.run(['python', '../mandelbrot.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)])
#     # Assuming you will do something with these values, like regenerating the Mandelbrot image
    mandelbrot_image_path = os.path.join(app.root_path, 'mandelbrot.png')
    
    for x in range(WIDTH):
        for y in range(HEIGHT):  
             c_re = REAL_MIN + (REAL_MAX - REAL_MIN) * x / (WIDTH - 1)
             c_im = IMAG_MIN + (IMAG_MAX - IMAG_MIN) * y / (HEIGHT - 1)   
    
    return render_template('mandelbrot.html',c_re=c_re, c_im=c_im , mandelbrot_image_path=mandelbrot_image_path)


video_player = None
#video_player = VideoPlayer(frames)

def run_flask():
    #with app.app_context():
        #video_player = VideoPlayer(frames)
        #video_player.start()
    global video_player
    app.run(host='0.0.0.0', port=5001, debug=False)
    
def start_video_player():
    global video_player
    #video_player.start()
    video_player.root.after(0, video_player.start)
if __name__ == '__main__':
    #app.run(host='0.0.0.0', port=5001, debug=False)
    
    # threading.Thread(target=run_flask).start()
    #threading.Thread(target=app.run, kwargs={'host': '0.0.0.0', 'port': 5001, 'debug': False}).start()
    
    threading.Thread(target=run_flask).start()
    #video_player = VideoPlayer(generate_mandelbrot_frames())
    #video_player.start()
    #threading.Thread(target=start_video_player).start()
    #video_player.root.after(0, start_video_player)
    #run_video_player()
    frames = generate_mandelbrot_frames()
    video_player = VideoPlayer(frames)
    #video_player.start()