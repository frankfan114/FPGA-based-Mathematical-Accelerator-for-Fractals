import vcd
import numpy as np
import cv2

def extract_pixel_data(vcd_file, max_pixels):
    signals = {}
    pixels = []
    valid_pixel_count = 0

    with open(vcd_file, 'rb') as f:  # Open the file in binary mode
        for token in vcd.tokenize(f):
            if token.kind == vcd.reader.TokenKind.VAR:
                var = token.data
                if var.reference == 'simu_stream_tdata':
                    signals['data'] = var.id_code
            elif token.kind == vcd.reader.TokenKind.CHANGE_VECTOR:
                changes = {token.data.id_code: token.data.value}

                if signals.get('data') in changes:
                    data_change = changes[signals['data']]
                    if data_change is not None and 'x' not in data_change and 'z' not in data_change:  # Skip invalid data
                        try:
                            rgb_value = int(data_change, 2)
                            r = (rgb_value >> 16) & 0xFF
                            g = (rgb_value >> 8) & 0xFF
                            b = rgb_value & 0xFF
                            pixels.append((r, g, b))
                            valid_pixel_count += 1
                            if valid_pixel_count >= max_pixels:
                                return pixels
                        except ValueError as e:
                            print(f"Skipping invalid data: {data_change}, error: {e}")

    print(f"Total pixels extracted: {len(pixels)}")
    return pixels

# Path to the VCD file
vcd_file = 'test1.vcd'

# Resolution of 640x480
width = 640
height = 480

expected_pixels = width * height

# Parse VCD file
pixels = extract_pixel_data(vcd_file, expected_pixels)

if len(pixels) < expected_pixels:
    raise ValueError(f"Expected {expected_pixels} pixels, but got {len(pixels)}")

# Convert pixel data to numpy array and reshape
pixels = np.array(pixels[:expected_pixels], dtype=np.uint8).reshape((height, width, 3))

# Create and save the image
image = pixels.astype(np.uint8)
cv2.imwrite('output.png', image)

print("Image saved as output.png")
