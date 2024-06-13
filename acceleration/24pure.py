from PIL import Image


def generate_image(values):
    # Create a new image with size 640x480
    img = Image.new('RGB', (640, 480))

    # Iterate through the first 307200 values in the array
    for i in range(min(640 * 480, len(values))):
        # Convert the 24-bit binary string to an integer value
        pixel_value = values[i]
        
        # Split the integer value into R, G, and B components
        red = (pixel_value >> 16) & 0xFF
        green = (pixel_value >> 8) & 0xFF
        blue = pixel_value & 0xFF

        # Calculate the pixel position in the image
        x = i % 640
        y = i // 640
        
        # Set the pixel value in the image
        img.putpixel((x, y), (red, green, blue))



    # Save the image as a PNG file
    img.save('output_image.png')


def read_vcd_signal(filename, signal_name_1,signal_name_2):
    values = []
    signal_symbol_1 = None # 24 bit color 
    signal_symbol_2 = None # x coordinate
    reading_values = False
    with open(filename, 'r') as file:
        for line in file:
            # search color data in definition part 
            if line.startswith('$var') and signal_name_1 in line:
                # Extract symbol from the signal definition line
                parts = line.split()
                signal_symbol_1 = parts[3]
            # search x coordinate data in definition part
            elif line.startswith('$var') and signal_name_2 in line:
                # Extract symbol from the signal definition line
                parts = line.split()
                signal_symbol_2 = parts[3]
                
            elif not reading_values and line.startswith('b') and signal_symbol_2 in line:
                reading_values = True

            elif reading_values and line.startswith('b') and signal_symbol_1 in line:
                # Extract values for the desired signal
                reading_values = False
                binary_string = line.split()[0][1:]  # Remove 'b' prefix
                binary_string = ''.join(filter(lambda char: char in '01', binary_string))  # Remove non-binary characters
                if binary_string:  # Check if binary string is not empty
                    signal_value = int(binary_string, 2)  # Convert 24-bit binary string to integer
                    values.append(signal_value)

            elif reading_values and line.startswith('b') and signal_symbol_2 in line:
                reading_values = True
                if values: 
                    values.append(values[-1])     
    
    print("Length of the array:", len(values))  # Print the length of the array
    return values

def write_values_to_file(values, output_filename):
    with open(output_filename, 'w') as file:
        for index, value in enumerate(values):
            file.write(f"Index {index}: {value}\n")
    print(f"Values have been written to {output_filename}")

# usage:
filename = 'test.vcd'
pixels = read_vcd_signal(filename,'out_stream_tdata','x')

# write_values_to_file(pixels, 'output.txt')

# Generate image using the first 640*480 values from the array
generate_image(pixels[:640*480])

print("Image has been generated and saved as 'output_image.png'")

