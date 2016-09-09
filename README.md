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

A very simple implementation of the mandelbrot algorithm is also provided in the context of the the project
and the mentioned article. You can compile it by executing the ```build``` script like this:
```
 $ ./build
```
The requirement is a working Docker installation. The resulting binary has accelerator offloading enabled that
is used if the environment from which it is started, provides it.

The Docker image creating during this process, is based on Debian. Among other things, it downloads some
Debian packages. If you are using some package caching mechanism in your system environment, or need another
form of a proxy to download things, you can use the ```apt_proxy``` environment variable to direct this.
Example:

```
 $ apt_proxy=http://apt:3142 ./build
```
