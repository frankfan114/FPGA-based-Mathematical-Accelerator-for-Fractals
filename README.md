# **ISAAC: An FPGA-based Mathematical Accelerator for Fractals**

## Repo Structure

`0-5`: Engineering file used for development

├── `0.Testfile` Engineering file for simulation

├── `1.Initial` Initial design for visualising the Mandelbrot and Julia set, only available in simulation

├── `2.Staged` Feasible design by applying state machine

├── `3.MMIO` MMIO file allowing for adjustment of parameters

├── `4.Combined` Enable generation of the Mandelbrot set or Julia sets

└── `5.Acceleration` Acceleration version using parallelism

`6-9`: Final Implementation

├── `6.Interface` Hardware and Software GUI

├── `7.JupyterNotebook` The final design of `pixel_generator` module, the overlay compiled from hardware design, and the Jupyter interface

├── `8.Software` The software implementation for the Mandelbrot set and Julia sets

└── `9.Simulation` Tools used for simulation

`Others` Other Materials

`src` Files needed for demo

## Instructions
- Download all files in `src` folder
- Connect to PYNQ server 
- Load `ISAAC.bit` and `ISAAC.hwh` to the Jupyter server
- Run `ISAAC.ipynb`
- Run `backupServer.py`
- For the software implementation, please first run the `setup.py` by running `python setup.py build_ext --inplace` in the terminal to compile the Cython file, then run the `app.py` for display.

## Demo 

### Demo of Hardware Implementation

https://github.com/franfafdaf/ISAAC/assets/115477676/fd61731c-c877-496b-b345-f48573054359

### Hardware using HDMI output
#### The Mandelbrot set
![hw-gui1](https://github.com/franfafdaf/ISAAC/assets/115477676/aeef2e58-2b38-45d0-950a-a0c8ea523461)
#### A Julia set
![hw-gui2](https://github.com/franfafdaf/ISAAC/assets/115477676/07afdfd2-cb14-4616-a926-af5e2785d3ef)


### Demo of Software Implementation

https://github.com/franfafdaf/ISAAC/assets/115477676/eb6cea04-176d-470a-b49e-a0107b11116e
