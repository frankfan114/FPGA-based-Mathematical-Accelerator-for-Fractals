import vcd
import numpy as np
import cv2

# Function to parse VCD and extract pixel data
def extract_pixel_data(vcd_file):
    signals = {}
    pixels = []
    valid_pixel_count = 0

    with open(vcd_file, 'rb') as f:  # Open the file in binary mode
        for token in vcd.tokenize(f):
            if token[0] == 'var':
                var = token[1]
                if var['reference'] == 'out_stream_tdata':
                    signals['data'] = var['id']
                elif var['reference'] == 'out_stream_tvalid':
                    signals['valid'] = var['id']
            elif token[0] == 'change':
                changes = token[1]
                if signals.get('valid') in changes and changes[signals['valid']] == '1':
                    data_change = changes.get(signals.get('data'))
                    if data_change:
                        pixel_value = int(data_change, 2)
                        pixels.append(pixel_value)
                        valid_pixel_count += 1
                        print(f"Extracted pixel {valid_pixel_count}: {pixel_value}")

    print(f"Total pixels extracted: {len(pixels)}")
    return pixels

# Parse VCD file
vcd_file = 'test.vcd'
pixels = extract_pixel_data(vcd_file)

# Assuming a resolution of 640x480 for the image
width = 640
height = 480

# Ensure we have the correct number of pixels
expected_pixels = width * height
if len(pixels) != expected_pixels:
    raise ValueError(f"Expected {expected_pixels} pixels, but got {len(pixels)}")

# Reshape pixel data to form image
pixels = np.array(pixels).reshape((height, width, 3))

# Create and save the image
image = np.zeros((height, width, 3), dtype=np.uint8)
for y in range(height):
    for x in range(width):
        pixel = pixels[y, x]
        r = (pixel >> 16) & 0xFF
        g = (pixel >> 8) & 0xFF
        b = pixel & 0xFF
        image[y, x] = (b, g, r)

cv2.imwrite('output.png', image)
print("Image saved as output.png")
