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

## Demo 

### Demo of Hardware Implementation

https://github.com/franfafdaf/ISAAC/assets/115477676/fd61731c-c877-496b-b345-f48573054359

### Demo of Software Implementation

https://github.com/franfafdaf/ISAAC/assets/115477676/eb6cea04-176d-470a-b49e-a0107b11116e
