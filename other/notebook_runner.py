import nbformat
from nbconvert.preprocessors import ExecutePreprocessor
from jupyter_client import KernelManager

def get_notebook_functions(notebook_path):
    with open(notebook_path) as f:
        nb = nbformat.read(f, as_version=4)

    functions = []
    for cell in nb.cells:
        if cell.cell_type == 'code':
            lines = cell.source.split('\n')
            for line in lines:
                if line.strip().startswith('def '):
                    func_name = line.split('(')[0].replace('def ', '').strip()
                    functions.append(func_name)
    return functions

def run_notebook_function(notebook_path, function_name):
    with open(notebook_path) as f:
        nb = nbformat.read(f, as_version=4)

    km = KernelManager()
    km.start_kernel()
    kc = km.client()
    kc.start_channels()

    try:
        kc.execute("print('Kernel is ready')")
        msg = kc.get_shell_msg()
        print("Kernel ready message:", msg)

        result = ""
        for cell in nb.cells:
            if cell.cell_type == 'code' and function_name in cell.source:
                kc.execute(cell.source)
                while True:
                    msg = kc.get_iopub_msg(timeout=10)
                    if 'content' in msg and 'text' in msg['content']:
                        result += msg['content']['text']
                    if msg['msg_type'] == 'execute_reply':
                        break
    except Exception as e:
        result = f"Error: {str(e)}"
    finally:
        kc.stop_channels()
        km.shutdown_kernel()

    return result
