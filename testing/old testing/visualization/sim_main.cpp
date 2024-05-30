#include <verilated.h>
#include "Vtest_streamer.h"
#include <iostream>
#include <fstream>

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Vtest_streamer *top = new Vtest_streamer;

    // Define image dimensions
    const int width = 640;
    const int height = 480;

    // Output file to save the image data
    std::ofstream outfile("output_image.ppm");

    // PPM header
    outfile << "P3\n"
            << width << " " << height << "\n255\n";

    // Initial reset
    top->aresetn = 0;
    top->aclk = 0;

    // Simulation loop
    int pixel_count = 0;
    int cycle_count = 0;
    while (pixel_count < width * height)
    { // 307200 pixels for a 640x480 image
        if (cycle_count == 20)
        {
            top->aresetn = 1; // Deassert reset after 20 time units
        }

        // Toggle clock
        top->aclk = !top->aclk;

        // Evaluate the model
        top->eval();

        // Capture output pixel data every cycle
        if (top->out_stream_tvalid && top->out_stream_tready)
        {
            uint32_t data = top->out_stream_tdata;
            uint32_t tkeep = top->out_stream_tkeep;

            // Handle the 24-bit RGB extraction based on tkeep
            if (tkeep == 0b1111)
            { // All 4 bytes are valid
                // Extract 3 bytes, i.e., 24-bit RGB
                uint32_t pixel1 = data & 0xFFFFFF;
                uint8_t r = (pixel1 >> 16) & 0xFF;
                uint8_t g = (pixel1 >> 8) & 0xFF;
                uint8_t b = pixel1 & 0xFF;
                outfile << (int)r << " " << (int)g << " " << (int)b << "\n";
                pixel_count++;
            }
            else if (tkeep == 0b0111)
            { // Last 3 bytes are valid
                uint32_t pixel1 = (data >> 8) & 0xFFFFFF;
                uint8_t r = (pixel1 >> 16) & 0xFF;
                uint8_t g = (pixel1 >> 8) & 0xFF;
                uint8_t b = pixel1 & 0xFF;
                outfile << (int)r << " " << (int)g << " " << (int)b << "\n";
                pixel_count++;
            }
            else if (tkeep == 0b0011)
            { // Last 2 bytes are valid
                uint32_t pixel1 = (data >> 16) & 0xFFFFFF;
                uint8_t r = (pixel1 >> 16) & 0xFF;
                uint8_t g = (pixel1 >> 8) & 0xFF;
                uint8_t b = pixel1 & 0xFF;
                outfile << (int)r << " " << (int)g << " " << (int)b << "\n";
                pixel_count++;
            }
            else if (tkeep == 0b0001)
            { // Only last byte is valid
                uint32_t pixel1 = (data >> 24) & 0xFFFFFF;
                uint8_t r = (pixel1 >> 16) & 0xFF;
                uint8_t g = (pixel1 >> 8) & 0xFF;
                uint8_t b = pixel1 & 0xFF;
                outfile << (int)r << " " << (int)g << " " << (int)b << "\n";
                pixel_count++;
            }
        }

        cycle_count++;
    }

    // Final model cleanup
    top->final();
    outfile.close(); // Close the output file
    delete top;      // Delete the top module instance

    return 0;
}
