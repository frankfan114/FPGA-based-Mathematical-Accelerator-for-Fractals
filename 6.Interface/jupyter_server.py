from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/run_mandelbrot', methods=['POST'])
def run_mandelbrot():
    data = request.json
    max_real = data.get('max_real')
    min_real = data.get('min_real')
    max_imaginary = data.get('max_imaginary')
    min_imaginary = data.get('min_imaginary')
    max_iterations = data.get('max_iterations')
    height = data.get('height')
    width = data.get('width')

    result = subprocess.run(
        ['python', './main.py', str(max_real), str(min_real), str(max_imaginary), str(min_imaginary), str(max_iterations), str(height), str(width)],
        capture_output=True,
        text=True
    )

    output = result.stdout.strip().split()
    total_time = float(output[0])
    overall_throughput = float(output[1])
    latency = float(output[2])
    
    return jsonify({
        "total_time": total_time,
        "overall_throughput": overall_throughput,
        "latency": latency
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
