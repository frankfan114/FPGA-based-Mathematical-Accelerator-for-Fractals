from PIL import Image

def generate_mandelbrot_image(width, height, max_iter=1000):
    # Create a new image with size width x height
    img = Image.new('RGB', (width, height))
    for x in range(width):
        for y in range(height):
            # Scale coordinates to the desired range of the mandelbrot set
            c = complex(-2.5 + (x / width) * 3.5, -1.0 + (y / height) * 2.0)
            z = 0
            n = 0
            while abs(z) <= 2 and n < max_iter:
                z = z*z + c
                n += 1
            # Normalize and convert to RGB
            color = 255 - int(n * 255 / max_iter)
            img.putpixel((x, y), (color, color, color))
    img.save('mandelbrot_image.png')
    print("Mandelbrot image has been generated and saved as 'mandelbrot_image.png'")

# Generate Mandelbrot image
generate_mandelbrot_image(640, 480)
