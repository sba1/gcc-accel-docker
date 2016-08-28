#
# A dockerfile to demonstrate the building of gcc with accelerator
# suppport for NVidia platforms.
#

FROM debian:jessie

ARG apt_proxy=""
RUN if [ -n "$apt_proxy" ]; then echo 'Acquire::http { Proxy "'$apt_proxy'"; }' >>/etc/apt/apt.conf; fi #

RUN echo "deb http://httpredir.debian.org/debian jessie-backports main contrib non-free" >>/etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
	bzip2 \
	ca-certificates \
	file \
	g++ \
	gcc \
	git \
	libgmp-dev \
	libmpc-dev \
	libmpfr-dev \
	libtool-bin \
	make \
	tar \
	wget

RUN apt-get install -y --no-install-recommends \
	nvidia-cuda-dev \
	nvidia-cuda-toolkit

RUN mkdir /setup
WORKDIR /setup

# NVPTX Tools
RUN git clone https://github.com/MentorEmbedded/nvptx-tools/
WORKDIR nvptx-tools
RUN ./configure
RUN make
RUN make install DESTDIR=$HOME/offloading

# Prepare gcc source
WORKDIR ..
RUN wget https://ftp.gnu.org/gnu/gcc/gcc-6.1.0/gcc-6.1.0.tar.bz2
RUN tar xjf gcc-6.1.0.tar.bz2
RUN mv gcc-6.1.0 gcc

# Prepare newlib
RUN git clone https://github.com/MentorEmbedded/nvptx-newlib/
WORKDIR nvptx-newlib
RUN git checkout aadc8eb0ec43b7cd0dd2dfb484bae63c8b05ef24
WORKDIR ../gcc
RUN ln -s ../nvptx-newlib/newlib newlib

# Compile accel gcc
RUN mkdir ../accel-gcc-build
WORKDIR ../accel-gcc-build
RUN ../gcc/configure --target=nvptx-none --enable-as-accelerator-for=x86_64-pc-linux-gnu --with-build-time-tools=$HOME/offloading/usr/local/nvptx-none/bin/ --disable-sjlj-exceptions --with-newlib --enable-newlib-io-long-long --enable-languages=c,c++,lto
RUN make
RUN make install DESTDIR=$HOME/offloading

# Compile host gcc
RUN mkdir ../host-gcc-build
WORKDIR ../host-gcc-build
RUN ../gcc/configure --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --disable-multilib --enable-offload-targets=nvptx-none=$HOME/offloading/usr/local/bin/ --enable-languages=c,c++,lto
RUN make
RUN make install DESTDIR=$HOME/offloading

# Expand $HOME here to /root as otherwise / is used (at least in version 1.11.2)
ENV PATH /root/offloading/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH /root/offloading/usr/local/lib64

RUN echo $PATH
RUN echo $LD_LIBRARY_PATH

# Finally, copy local sources
RUN mkdir /build
WORKDIR /build
COPY * /build/

# And compile using make
RUN make
