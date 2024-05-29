# mandelbrot_cy.pyx

import numpy as np
cimport numpy as np
cimport cython

@cython.boundscheck(False)
@cython.wraparound(False)
def generate_mandelbrot_image_c(np.ndarray[np.int_t, ndim=2] mandelbrot_set, int max_iter, int width, int height, np.ndarray[np.uint8_t, ndim=3] image):
    cdef int x, y
    cdef int iter
    cdef float t
    cdef int r, g, b

    for x in range(width):
        for y in range(height):
            iter = mandelbrot_set[x, y]
            if iter == max_iter:
                r = g = b = 0
            else:
                t = iter / max_iter
                r = int(9 * (1 - t) * t * t * t * 255)
                g = int(15 * (1 - t) * (1 - t) * t * t * 255)
                b = int(8.5 * (1 - t) * (1 - t) * (1 - t) * t * 255)
            image[y, x, 0] = r
            image[y, x, 1] = g
            image[y, x, 2] = b
