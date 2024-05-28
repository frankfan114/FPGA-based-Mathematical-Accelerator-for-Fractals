import vcd
import numpy as np
import cv2

def extract_pixel_data(vcd_file, max_pixels):
    signals = {}
    pixels = []
    valid_pixel_count = 0
    valid = False  # Track the valid signal state
    word_buffer = []  # Buffer to store 3 32-bit words

    with open(vcd_file, 'rb') as f:  # Open the file in binary mode
        for token in vcd.tokenize(f):
            if token.kind == vcd.reader.TokenKind.VAR:
                var = token.data
                if var.reference == 'out_stream_tdata':
                    signals['data'] = var.id_code
                elif var.reference == 'out_stream_tvalid':
                    signals['valid'] = var.id_code
            elif token.kind == vcd.reader.TokenKind.CHANGE_VECTOR:
                changes = {token.data.id_code: token.data.value}

                if signals.get('valid') in changes:
                    valid_change = changes[signals['valid']]
                    valid = valid_change == 1

                if valid and signals.get('data') in changes:
                    data_change = changes[signals['data']]
                    if data_change is not None:
                        word_buffer.append(int(data_change))
                        if len(word_buffer) == 3:
                            # Combine 3 words into a single 96-bit integer
                            combined_data = (word_buffer[2] << 64) | (word_buffer[1] << 32) | word_buffer[0]
                            for i in range(4):
                                pixel_value = (combined_data >> (24 * i)) & 0xFFFFFF
                                r = (pixel_value >> 16) & 0xFF
                                g = (pixel_value >> 8) & 0xFF
                                b = pixel_value & 0xFF
                                pixels.append([r, b, g])
                                valid_pixel_count += 1
                                if valid_pixel_count >= max_pixels:
                                    return pixels
                            word_buffer = []  # Reset buffer after extracting pixels

            elif token.kind == vcd.reader.TokenKind.CHANGE_SCALAR:
                changes = {token.data.id_code: token.data.value}
                if signals.get('valid') in changes:
                    valid_change = changes[signals['valid']]
                    valid = valid_change == '1'

    print(f"Total pixels extracted: {len(pixels)}")
    return pixels

# Path to the VCD file
vcd_file = 'test.vcd'

# resolution of 640x480 
width = 640
height = 480

expected_pixels = width * height

# Parse VCD file
pixels = extract_pixel_data(vcd_file, expected_pixels)

if len(pixels) < expected_pixels:
    raise ValueError(f"Expected {expected_pixels} pixels, but got {len(pixels)}")

# Convert pixel data to numpy array and reshape
pixels = np.array(pixels[:expected_pixels])

# Create and save the image
image = np.zeros((height, width, 3), dtype=np.uint8)
for y in range(height):
    for x in range(width):
        image[y, x] = pixels[y * width + x]

cv2.imwrite('output.png', image)
print("Image saved as output.png")
