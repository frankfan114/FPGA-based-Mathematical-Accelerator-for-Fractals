from vcd.reader import TokenKind, tokenize
from PIL import Image

def read_vcd_file(vcd_path):
    signals = {}
    with open(vcd_path, 'r') as f:
        for token in tokenize(f):
            if token.kind == TokenKind.TIMESTAMP:
                current_time = token.timestamp
            elif token.kind == TokenKind.CHANGE_SCALAR:
                signal = token.reference
                value = token.value
                if signal not in signals:
                    signals[signal] = []
                signals[signal].append((current_time, value))
    return signals

def create_image(width, height):
    return Image.new("RGB", (width, height))

def parse_vcd_signals(signals, width, height, time_step):
    r_buf = {}
    g_buf = {}
    b_buf = {}

    for signal, changes in signals.items():
        if signal in ("r", "g", "b"):
            for change in changes:
                time, value = change
                coord = time // time_step
                if signal == "r":
                    r_buf[coord] = int(value, 2)
                elif signal == "g":
                    g_buf[coord] = int(value, 2)
                elif signal == "b":
                    b_buf[coord] = int(value, 2)

    return r_buf, g_buf, b_buf

def assign_pixels(image, r_buf, g_buf, b_buf, width):
    pixels = image.load()
    for coord in r_buf:
        x = coord % width
        y = coord // width
        pixels[x, y] = (r_buf.get(coord, 0), g_buf.get(coord, 0), b_buf.get(coord, 0))

def main(vcd_path, output_image_path, width, height, time_step):
    signals = read_vcd_file(vcd_path)
    image = create_image(width, height)
    r_buf, g_buf, b_buf = parse_vcd_signals(signals, width, height, time_step)
    assign_pixels(image, r_buf, g_buf, b_buf, width)
    image.save(output_image_path)

if __name__ == "__main__":
    main("output.vcd", "output.png", 256, 256, 10)
