FROM resin/rpi-raspbian:jessie

MAINTAINER Philip Herron <herron.philip@googlemail.com>

RUN apt-get update; \
    apt-get install -y libraspberrypi-bin libraspberrypi-bin \
    gstreamer1.0 gstreamer1.0-tools gstreamer1.0-omx \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-tools \
    libgstreamer-plugins-base1.0-0 gstreamer1.0-plugins-good libgssdp-1.0-dev \
    v4l-utils wget ca-certificates build-essential git \
    autoconf automake libtool pkg-config
RUN apt-get upgrade

RUN git clone https://github.com/thaytan/gst-rpicamsrc.git
RUN cd gst-rpicamsrc; ./autogen.sh --prefix=/usr --libdir=/usr/lib/arm-linux-gnueabihf/; make; make install; cd -

RUN wget https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-1.4.4.tar.xz
RUN tar xvf gst-rtsp-server-1.4.4.tar.xz; cd gst-rtsp-server-1.4.4; ./configure --prefix=/usr; make; make install; cd ..

ENV PKG_CONFIG_PATH /usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH /opt/lib:/usr/lib/arm-linux-gnueabihf/:$LD_LIBRARY_PATH
ENV PATH /opt/vc/bin:$PATH
ENV INITSYSTEM on

EXPOSE 8554

COPY . /usr/src/app
WORKDIR /usr/src/app

RUN gcc -g -O2 -Wall `pkg-config --cflags --libs gstreamer-rtsp-server-1.0 gssdp-1.0` RpiCameraRtspServer.c -o RpiCameraRtspServer
RUN bash -c "echo bcm2835-v4l2 >> /etc/modules"

CMD ["bash", "start.sh"]
