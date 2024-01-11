# clone https://github.com/muaddib1984/gr-webspectrum to the same directory as this Dockerfile

FROM python:3.11-alpine AS build
RUN apk update
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3.11/site-packages:/usr/lib/python3.11/dist-packages:/usr/local/lib/python3.11/site-packages"
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib"
RUN apk add --no-cache cmake \
	    make \
        g++ \
	    gcc \
	    dpkg \
	    pkgconfig \
	    nano \
	    redis \
        gnuradio-dev=3.10.7.0-r4 --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community && \
	    pip install sse-starlette redis

COPY gr-webspectrum /root/gr-webspectrum

RUN	cd /root/gr-webspectrum && rm -rf build && mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	ldconfig /etc/ld.so.conf.d

FROM python:3.11-alpine AS deploy
RUN apk update
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3.11/site-packages:/usr/lib/python3.11/dist-packages:/usr/local/lib/python3.11/site-packages"
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib"
# copy python/example from oot module, install gnuradio (not gnuradio-dev), clean up some obvious, unused python libraries, delete source directories

# GNURadio,Webserver, Redis DB
COPY --from=build /root/ /root
RUN apk add --no-cache gnuradio --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    fmt=10.1.1-r0 --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main \
    fmt-dev=10.1.1-r0 --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main \
    redis && \
    pip install sse-starlette redis && \
    #copy build files from OOT
    cp -r /root/gr-webspectrum/python/webspectrum /usr/lib/python3.11/site-packages/gnuradio/ && \
    #move example from source directory
    mv /root/gr-webspectrum/examples/RTLSDR_or_fake_signal_to_fft_to_broadcaster.py /root && \
    mv /root/gr-webspectrum/server /root && \
    #delete unecessary libs from python
    rm -rf /usr/lib/python3.11/site-packages/pyqtgraph && \
    rm -rf /usr/lib/python3.11/site-packages/PyQt5 && \
    rm -rf /usr/lib/python3.11/site-packages/qt5 && \
    rm -rf /usr/lib/python3.11/site-packages/OpenGL && \
    rm -rf /usr/lib/python3.11/site-packages/qt5 && \
    #delete OOT block
    rm -rf /root/gr-webspectrum && \
    ldconfig /etc/ld.so.conf.d

ENTRYPOINT ["/bin/sh", "-c", "cd /root/server && (redis-server --port 6379 &) && (uvicorn --host 0.0.0.0 --port 8000 app.main:app &) && python3 /root/RTLSDR_or_fake_signal_to_fft_to_broadcaster.py"]

