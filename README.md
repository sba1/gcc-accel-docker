# gcc-accel-docker

This project consists of a Dockefile that demonstrate the steps how to get a gcc compiler that has accelerator offloading
enabled. Note that is not possible to actually run such accelerator-enabled executables
within the container. To do so, most likely, you have to perform similar steps on your target platform (or you extract
necessary runtime from the Docker container). In principle, there is also the possibility to take adavantage of accelerator
offloading within a container, but this is, at least for now, not followed here.

This project accompanies the short German article
http://www.heise.de/developer/artikel/Accelerator-Offloading-mit-GCC-3317330.html which explains the steps done within
the Dockerfile in detail.

## Example

A very simple implementation of the mandelbrot algorithm is also provided within the project. You can compile it by executing
the ```build``` example. The requirement is a Docker installation. The resulting binary has accelerator offloading enabled which
is used if the environment from which it is started, provides it.
