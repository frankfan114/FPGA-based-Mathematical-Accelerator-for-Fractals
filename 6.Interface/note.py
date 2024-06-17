from flask import Flask, request, jsonify
import asyncio
import nest_asyncio
#import PIL.Image
import json
import base64
import io
import concurrent.futures
app = Flask(__name__)
import time
#executor = concurrent.futures.ThreadPoolExecutor()
#nest_asyncio.apply()

# async def generate_image_async_internal(data):
    
#     frame = imgen_vdma.readframe()
#     image = PIL.Image.fromarray(frame)
#     buffered = io.BytesIO()
#     image.save(buffered, format="PNG")
#     img_str = base64.b64encode(buffered.getvalue()).decode('utf-8')
#     return {"image": img_str}

# def generate_image_async(data):
#     loop = asyncio.new_event_loop()
#     asyncio.set_event_loop(loop)
#     result = loop.run_until_complete(generate_image_async_internal(data))
#     loop.close()
#     return result
# async def read_frame():
#     return await imgen_vdma.readframe()
nest_asyncio.apply()
loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)
async def read_frame():
    await asyncio.sleep(1)  # 模拟异步操作
    # 这里应该返回读取的图像帧数据
    return imgen_vdma.readframe()

async def read():
    start_time = time.time()
    frame =  imgen_vdma.readframe()
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(elapsed_time)
    return elapsed_time

def process_frames(num_frames):
    start_time = time.time()
    frame_count = 0
    while frame_count < num_frames:
        frame_data = imgen_vdma.readframe()
        frame_count += 1
    end_time = time.time()
    elapsed_time = end_time - start_time
    return elapsed_time, frame_count

@app.route('/generate_image', methods=['POST'])
def generate_image():
    # try:
    if request.method == 'POST':
        # 从POST请求中读取JSON数据
        data = request.get_json()
        max_real = data.get('max_real')
        min_real = data.get('min_real')
        max_imaginary = data.get('max_imaginary')
        min_imaginary = data.get('min_imaginary')
        max_iterations = data.get('max_iterations')
        height = data.get('height')
        width = data.get('width')
        zoom_factor = data.get('zoom_factor')
        coordinate = data.get('coordinate')
        up = data.get('up')
        down = data.get('down')
        left = data.get('left')
        right = data.get('right')
        color1 = data.get('color1')
        color2 = data.get('color2')
        color3 = data.get('color3')
        reset = data.get('reset')
        zoomin_factor = data.get('zoomin_factor')
        zoomout_factor = data.get('zoomout_factor')
        julia = data.get('julia')
        clickX = data.get('clickX')
        clickY =  data.get('clickY')
        up = -up
        left = -left
        
        
        
        print(data)
        pixgen.register_map.gp1[31:24] = color3;
        pixgen.register_map.gp1[23:16] = color2;
        pixgen.register_map.gp1[15:8] = color1;
        
        pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:16] +left+right
        pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:0]+ up + down
        
        
        if julia == 1:
            pixgen.register_map.gp1[7:0] = 80;
            print("julia")
            if clickX is not None and clickY is not None:
                pixgen.register_map.gp0[31:16] = round(clickX);
                pixgen.register_map.gp1[15:0] = round(clickY);
        else:
            pixgen.register_map.gp1[7:0] = max_iterations;
    
        
        if zoomin_factor >= zoomout_factor:
            x = zoomin_factor
            pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:(16+x)]
            pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:(0+x)]
            pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:(16+x)]
            pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:(0+x)]
            # pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:(16+x)] + left + right
            # pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:(0+x)]+ up + down
            # pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:(16+x)]
            # pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:(0+x)]
            print('in')
        else:
            x = zoomout_factor
            pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:16]* (2**x)
            pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:0]* (2**x)
            pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:16] * (2**x)
            pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:0] * (2**x)
            # pixgen.register_map.gp2[31:16] = (pixgen.register_map.gp2[31:16] + left + right)* (2**x)
            # pixgen.register_map.gp2[15:0] = (pixgen.register_map.gp2[15:0]+ up + down)* (2**x)
            # pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:16] * (2**x)
            # pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:0] * (2**x)
            print('out')

        #pixgen.register_map

        # # 设置视频模式
        # pixgen.register_map.gp1[7:0] = max_iterations
        # pixgen.register_map.gp2[31:16] = (pixgen.register_map.gp2[31:16] + left + right)*zoomin_factor/zoomout_factor
        # pixgen.register_map.gp2[15:0] = (pixgen.register_map.gp2[15:0]+ up + down)*zoomin_factor/zoomout_factor
        # pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:16]*zoomin_factor/zoomout_factor
        # pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:0]*zoomin_factor/zoomout_factor

        if reset == 1:
            pixgen.register_map.gp2[31:16] = pixgen.register_map.gp6[31:16]
            pixgen.register_map.gp2[15:0] =  pixgen.register_map.gp6[15:0]
            pixgen.register_map.gp3[31:16] = pixgen.register_map.gp7[31:16]
            pixgen.register_map.gp3[15:0] = pixgen.register_map.gp7 [15:0]
            print('reset')
        # videoMode = common.VideoMode(X_SIZE, Y_SIZE, 24)
        # imgen_vdma.mode = videoMode
        # imgen_vdma.start()
        print('1')
        
        # future = executor.submit(generate_image_async, data)
        # result = future.result()
       
        # loop = asyncio.new_event_loop()
        # asyncio.set_event_loop(loop)
        # frame = loop.run_until_complete(read_frame())
        # loop.close()
        
        #frame =  read_frame()
        
        
        asyncio.set_event_loop(loop)
        
        #frame = asyncio.run(read_frame())
        # start_time = time.time()
        frame = loop.run_until_complete(read_frame())
        # end_time = time.time()
        #frame = read()
        #frame = loop.run_until_complete(read())
        # frame = imgen_vdma.readframe()
        print('2')
        image = PIL.Image.fromarray(frame)
        
        
        
        
        
        
        buffered = io.BytesIO()
        image.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode('utf-8')
        print('3')
        
        

        x_size = 640
        y_size = 460

        
        # Capture multiple frames and measure the processing time
        # num_frames = 100  # Intended number of frames to process
        frame_count = 100 # Actual number of frames processed
        # with concurrent.futures.ThreadPoolExecutor() as executor:
        #     future = executor.submit(read_frames_in_thread, num_frames=100)
        #     start_time, end_time, frame_count = future.result()
        # elapsed_time, frame_count = process_frames(num_frames)
        
        start_time = time.time()
        while frame_count < num_frames:
            frame =  imgen_vdma.readframe()
            frame_count += frame_count
    
        
        end_time = time.time()
        print("4")
        if frame_count > 0:
            elapsed_time = end_time - start_time
            #elapsed_time = read()
            frame_rate = 1 / elapsed_time  # Frames per second
            total_pixels = 1 * x_size * y_size  # Total pixels processed (width x height x frame_count)
            pixel_rate = frame_rate*total_pixels  # Pixels per second
            latency = elapsed_time/total_pixels
            
            
            print(f"Frame rate: {frame_rate:.2f} FPS")
            print(f"Pixel rate: {pixel_rate:.2f} pixels/second")
            print(f"latency: {latency:.9f} second/pixel")
        else:
            print("No frames were processed.")
        
        
        
        # 返回Base64编码的图片URL
        #return jsonify({"image_url": f"data:image/png;base64,{img_str}"})
        return jsonify({"image": img_str,
                        "total_time": elapsed_time,
                        "frame_rate": frame_rate,
                        "pixel_rate": pixel_rate,
                        "latency": latency
                        
                        })
        #return jsonify(result)
    # except Exception as e:
    #     return jsonify({"error": str(e)})
    return jsonify({})
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5011)



#         numframes = 20
#         start = time.time()
#         for _ in range(numframes):
#             hdmi_out.writeframe(frame)
#         end = time.time()
        
#         elapsed_time = (end - start)
#         frame_rate = numframes / (end - start)
#         pixel_rate = (numframes*640*480) / (end - start)
#         latency = (end - start) / (numframes*640*480) 
        
#         print(frame_rate)
#         print(pixel_rate)
#         print(latency)
#         print(elapsed_time)


from flask import Flask, request, jsonify
import asyncio
import nest_asyncio
import PIL.Image
import json
import base64
import io
import time
app = Flask(__name__)


nest_asyncio.apply()
loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)

async def read_frame():
    await asyncio.sleep(4)
    frame =  imgen_vdma.readframe()
    return frame

@app.route('/generate_image', methods=['POST'])
def generate_image():
    
    if request.method == 'POST':
        # read data from post request
        data = request.get_json()
        max_real = data.get('max_real')
        min_real = data.get('min_real')
        max_imaginary = data.get('max_imaginary')
        min_imaginary = data.get('min_imaginary')
        max_iterations = data.get('max_iterations')
        height = data.get('height')
        width = data.get('width')
        zoom_factor = data.get('zoom_factor')
        coordinate = data.get('coordinate')
        up = data.get('up')
        down = data.get('down')
        left = data.get('left')
        right = data.get('right')
        color1 = data.get('color1')
        color2 = data.get('color2')
        color3 = data.get('color3')
        color4 = data.get('color4')
        reset = data.get('reset')
        zoomin_factor = data.get('zoomin_factor')
        zoomout_factor = data.get('zoomout_factor')
        julia = data.get('julia')
        clickX = data.get('clickX')
        clickY =  data.get('clickY')
        up = -up
        left = -left
        
        
        
        print(data)
        
        
        pixgen.register_map.gp1[31:24] = color3;
        pixgen.register_map.gp1[23:16] = color1;
        pixgen.register_map.gp1[15:8] = color2;
        pixgen.register_map.gp0[26:19] = color4;
        
        pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:16] +left+right
        pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:0]+ up + down
        
        
        if julia == 1:
            pixgen.register_map.gp1[7:0] = 80;
            print("julia")
            
            pixgen.register_map.gp2[31:16] = 410
            pixgen.register_map.gp2[15:0] = 230
            pixgen.register_map.gp3[31:16] = 819
            pixgen.register_map.gp3[15:0] = 461
            if clickX is not None and clickY is not None:
                pixgen.register_map.gp0[18:10] = round(clickX);
                pixgen.register_map.gp0[9:0] = round(clickY);
            
        else:
            pixgen.register_map.gp1[7:0] = max_iterations;
    
        
        if zoomin_factor >= zoomout_factor:
            x = zoomin_factor
            pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:(16+x)]
            pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:(0+x)]
            pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:(16+x)]
            pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:(0+x)]
            
            print('in')
        else:
            x = zoomout_factor
            pixgen.register_map.gp2[31:16] = pixgen.register_map.gp2[31:16]* (2**x)
            pixgen.register_map.gp2[15:0] = pixgen.register_map.gp2[15:0]* (2**x)
            pixgen.register_map.gp3[31:16] = pixgen.register_map.gp3[31:16] * (2**x)
            pixgen.register_map.gp3[15:0] = pixgen.register_map.gp3[15:0] * (2**x)
            
            print('out')

        

        if reset == 1:
            pixgen.register_map.gp2[31:16] = pixgen.register_map.gp6[31:16]
            pixgen.register_map.gp2[15:0] =  pixgen.register_map.gp6[15:0]
            pixgen.register_map.gp3[31:16] = pixgen.register_map.gp7[31:16]
            pixgen.register_map.gp3[15:0] = pixgen.register_map.gp7 [15:0]
            print('reset')
        
        print('1')
        
        
        frame = loop.run_until_complete(read_frame())
        image = PIL.Image.fromarray(frame)
        hdmi_out.writeframe(frame)
        
        
        buffered = io.BytesIO()
        image.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode('utf-8')
        print('3')
        
        

       
        return jsonify({"image": img_str})
                        # "total_time": elapsed_time,
                        # "frame_rate": frame_rate,
                        # "pixel_rate": pixel_rate,
                        # "latency": latency
                        
                        
      
    return jsonify({})
    

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5011)