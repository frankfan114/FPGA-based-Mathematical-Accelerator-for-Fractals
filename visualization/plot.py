import numpy as np
from PIL import Image

# Define image dimensions
width = 640
height = 480

# Initialize an empty array to store the pixel data
pixels = np.zeros((height, width, 3), dtype=np.uint8)

# Read pixel data from file
with open("pixel_data.txt", "r") as file:
    lines = file.readlines()

# Fill the pixel array
for i, line in enumerate(lines):
    pixel_value = int(line.strip(), 16)  # Convert hex string to integer
    r = (pixel_value >> 16) & 0xFF
    g = (pixel_value >> 8) & 0xFF
    b = pixel_value & 0xFF

    x = i % width
    y = i // width

    if y < height:
        pixels[y, x] = [r, g, b]

# Create an image from the pixel data
image = Image.fromarray(pixels, 'RGB')

# Save the image
image.save('output_image.png')

# Notify the user that the image has been saved
print("Image saved as 'output_image.png'")
