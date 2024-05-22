from flask import Flask, render_template, request, redirect, url_for
from notebook_runner import run_notebook_function, get_notebook_functions

app = Flask(__name__)

@app.route('/')
def home():
    functions = get_notebook_functions('your_notebook.ipynb')
    return render_template('index.html', functions=functions)

@app.route('/run_function', methods=['POST'])
def run_function():
    function_name = request.form['function_name']
    return redirect(url_for('show_result', function_name=function_name))

@app.route('/result/<function_name>')
def show_result(function_name):
    result = run_notebook_function('your_notebook.ipynb', function_name)
    return render_template('result.html', function_name=function_name, result=result)

if __name__ == '__main__':
    app.run(debug=True)
