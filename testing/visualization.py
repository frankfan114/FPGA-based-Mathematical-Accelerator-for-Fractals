import vcd
import numpy as np
import cv2

def extract_pixel_data(vcd_file, max_pixels):
    signals = {}
    pixels = []
    valid_pixel_count = 0
    valid = False  # Track the valid signal state
    word_buffer = []  # Buffer to store 3 32-bit words
    last_valid_pixel_value = None  # Last valid pixel value for continued use

    with open(vcd_file, 'rb') as f:
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
                    valid = int(changes[signals['valid']]) == 1

                if valid and signals.get('data') in changes:
                    data_change = changes[signals['data']]
                    if data_change is not None:
                        word_buffer.append(int(data_change))
                        if len(word_buffer) == 3:
                            # Combine 3 words into a single 96-bit integer
                            combined_data = (word_buffer[2] << 64) | (word_buffer[1] << 32) | word_buffer[0]
                            for i in range(4):
                                pixel_value = (combined_data >> (24 * i)) & 0xFFFFFF
                                last_valid_pixel_value = pixel_value  # Update the last known valid pixel value
                                r = (pixel_value >> 16) & 0xFF
                                g = (pixel_value >> 8) & 0xFF
                                b = pixel_value & 0xFF
                                pixels.append([r, g, b])
                                valid_pixel_count += 1
                                if valid_pixel_count >= max_pixels:
                                    return pixels[:max_pixels]
                            word_buffer = []  # Reset buffer after extracting pixels

    # If insufficient pixel data is available, use the last valid pixel value to fill
    while valid_pixel_count < max_pixels:
        if last_valid_pixel_value is not None:
            r = (last_valid_pixel_value >> 16) & 0xFF
            g = (last_valid_pixel_value >> 8) & 0xFF
            b = last_valid_pixel_value & 0xFF
            pixels.append([r, g, b])
        else:
            pixels.append([0, 0, 0])  # Default to black if no valid data was ever received
        valid_pixel_count += 1

    print(f"Total pixels extracted: {len(pixels)}")
    return pixels[:max_pixels]

# Path to the VCD file
vcd_file = 'test.vcd'

# Resolution of 640x480
width = 640
height = 480

expected_pixels = width * height

# Parse VCD file
pixels = extract_pixel_data(vcd_file, expected_pixels)

# Convert pixel data to numpy array and reshape
pixels_array = np.array(pixels).reshape((height, width, 3))

# Create and save the image
image = pixels_array.astype(np.uint8)
cv2.imwrite('output.png', image)
print("Image saved as output.png")
