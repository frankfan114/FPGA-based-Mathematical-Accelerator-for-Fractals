from PIL import Image

def generate_image(values, width=640, height=480):
    img = Image.new('RGB', (width, height))
    index = 0
    num_pixels = width * height

    for pixel_value in values:
        if index >= num_pixels:
            break

        # Extract the RGB components from the 32-bit pixel value
        red = (pixel_value >> 16) & 0xFF  # Red is the next highest 8 bits
        green = (pixel_value >> 8) & 0xFF  # Green follows in the next 8 bits
        blue = pixel_value & 0xFF  # Blue is the lowest 8 bits
        x = index % width
        y = index // width

        if x < width and y < height:
            img.putpixel((x, y), (red, green, blue))
            index += 1

    img.save('output_image.png')
    print(f"Image has been generated and saved as 'output_image.png', total pixels set: {index}.")

def read_vcd_signal(filename, signal_name):
    values = []
    signal_symbol = None
    with open(filename, 'r') as file:
        for line in file:
            if '$var' in line and signal_name in line:
                parts = line.split()
                signal_symbol = parts[3]
                print(f"Found signal symbol for {signal_name}: {signal_symbol}")
            elif 'b' in line and signal_symbol and signal_symbol in line:
                parts = line.split()
                binary_string = parts[0][1:]  # Remove 'b' prefix
                if 'x' not in binary_string and 'z' not in binary_string:
                    try:
                        signal_value = int(binary_string, 2)
                        values.append(signal_value)
                    except ValueError:
                        print(f"Skipping invalid binary value: {binary_string}")
                else:
                    print(f"Skipping invalid data: {binary_string}")
    return values

# Example Usage
filename = 'test.vcd'
signal_name = 'out_stream_tdata'
pixels = read_vcd_signal(filename, signal_name)

if pixels:
    generate_image(pixels, 640, 480)  # Generate image using the pixel data
else:
    print("No valid data found to generate image.")
