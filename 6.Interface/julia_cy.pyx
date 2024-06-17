import numpy as np
cimport numpy as np
cimport cython

@cython.boundscheck(False)
@cython.wraparound(False)
def compute_mandelbrot_set(np.ndarray[np.int_t, ndim=2] mandelbrot_set, double real_min, double real_max, double imag_min, double imag_max, int max_iter, int current_iter):
    cdef int width = mandelbrot_set.shape[0]
    cdef int height = mandelbrot_set.shape[1]
    cdef int x, y, n
    cdef double real, imag
    cdef double zr, zi, zr2, zi2
    cdef double cr, ci

    for x in range(width):
        for y in range(height):
            cr = real_min + (real_max - real_min) * x / (width - 1)
            ci = imag_min + (imag_max - imag_min) * y / (height - 1)
            zr = 0.0
            zi = 0.0
            n = 0
            while n < current_iter and zr*zr + zi*zi <= 4.0:
                zr2 = zr*zr - zi*zi + cr
                zi2 = 2.0*zr*zi + ci
                zr = zr2
                zi = zi2
                n += 1
            mandelbrot_set[x, y] = n

@cython.boundscheck(False)
@cython.wraparound(False)
def compute_julia_set(np.ndarray[np.int_t, ndim=2] julia_set, double real_min, double real_max, double imag_min, double imag_max, double cr, double ci, int max_iter):
    cdef int width = julia_set.shape[0]
    cdef int height = julia_set.shape[1]
    cdef int x, y, n
    cdef double real, imag
    cdef double zr, zi, zr2, zi2

    for x in range(width):
        for y in range(height):
            zr = real_min + (real_max - real_min) * x / (width - 1)
            zi = imag_min + (imag_max - imag_min) * y / (height - 1)
            n = 0
            while n < max_iter and zr*zr + zi*zi <= 4.0:
                zr2 = zr*zr - zi*zi + cr
                zi2 = 2.0*zr*zi + ci
                zr = zr2
                zi = zi2
                n += 1
            julia_set[x, y] = n

@cython.boundscheck(False)
@cython.wraparound(False)
def generate_image(np.ndarray[np.int_t, ndim=2] data_set, int max_iter, int width, int height, np.ndarray[np.uint8_t, ndim=3] image):
    cdef int x, y
    cdef int iter
    cdef float t
    cdef int r, g, b

    for x in range(width):
        for y in range(height):
            iter = data_set[x, y]
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
