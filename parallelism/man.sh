#!/bin/bash
DUT="man.v packer.v simulator.v" #把mandelbrot.v改名
TEST_BENCH="streamer_tb.v"
OBJ="stream"
WAVE="test.vcd"
PYTHON_SCRIPT="24pure.py"

# Function to compile Verilog files
comp() {
    echo "Compiling $DUT"
    iverilog -o $OBJ $DUT $TEST_BENCH
}

# Function to run the simulation
run() {
    echo "Running simulation"
    vvp $OBJ
}

# Function to run the Python visualization script
visualize() {
    echo "Running Python visualization script"
    python $PYTHON_SCRIPT
}

# Function to clean build directory and output files
clean() {
    echo "Cleaning build directory and output files"
    rm -f test.vcd stream output_image.png
}

# Function to view waveform using gtkwave
view() {
    echo "Opening waveform in gtkwave"
    gtkwave $WAVE
}

# Main function to handle command-line arguments
main() {
    case "$1" in
        comp)
            comp
            ;;
        run)
            run
            ;;
        visualize)
            comp
            run
            visualize
            ;;
        clean)
            clean
            ;;
        view)
            view
            ;;
        *)
            echo "Executing default tasks: clean, comp, run, visualize"
			clean
            comp
            run
            visualize
            ;;
    esac
}

main "$@"
